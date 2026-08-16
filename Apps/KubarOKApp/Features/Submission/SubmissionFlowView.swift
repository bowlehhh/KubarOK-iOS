#if canImport(SwiftUI) && canImport(UniformTypeIdentifiers)
import SwiftUI
import UniformTypeIdentifiers
import KubarOKCore

struct SubmissionFlowView: View {
    @StateObject private var viewModel: SubmissionFlowViewModel
    @State private var isFileImporterPresented = false
    @State private var uploadTarget: SubmissionUploadTarget?

    init(sessionController: AppSessionController, serviceID: Int) {
        _viewModel = StateObject(wrappedValue: SubmissionFlowViewModel(sessionController: sessionController, serviceID: serviceID))
    }

    var body: some View {
        Group {
            switch viewModel.stage {
            case .start:
                CatalogStateView(title: "Siapkan pengajuan", message: "Buat draft untuk mengisi persyaratan.", retryTitle: viewModel.isLoading ? "Memuat…" : "Buat Draft", retry: { Task { await viewModel.createDraft() } })
            case .editing:
                List {
                    Section("Persyaratan") {
                        ForEach(viewModel.checks) { check in
                            requisiteRow(check)
                        }
                    }
                    Section("Review") {
                        Text(viewModel.allRequiredComplete ? "Persyaratan wajib telah tersimpan." : "Lengkapi semua persyaratan wajib sebelum mengirim.")
                        Button(viewModel.isSubmitting ? "Mengirim…" : "Kirim Pengajuan") { Task { await viewModel.send() } }
                            .disabled(!viewModel.allRequiredComplete || viewModel.isSubmitting)
                    }
                    if let error = viewModel.errorMessage { Section { Text(error).foregroundStyle(.red) } }
                }
            case .success(let message):
                CatalogStateView(title: "Pengajuan berhasil dikirim", message: message)
            }
        }
        .navigationTitle("Pengajuan")
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.data]) { result in
            guard case let .success(url) = result, let target = uploadTarget else { return }
            Task { await viewModel.upload(url: url, target: target) }
        }
    }

    @ViewBuilder private func requisiteRow(_ check: SubmissionRequisiteCheck) -> some View {
        let requisite = check.requisite
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(requisite?.title ?? "Persyaratan")
            if requisite?.isRequired != 0 { Text("Wajib").font(.footnote).foregroundStyle(.secondary) }
            if requisite?.kind == 0 {
                Button(check.isCompleted != 0 ? "Ubah persetujuan" : "Setujui persyaratan") { Task { await viewModel.saveAgreement(check) } }
            } else if requisite?.kind == 2, let inputs = requisite?.inputs {
                ForEach(inputs) { input in
                    TextField(input.label, text: viewModel.binding(for: input.key))
                        .textFieldStyle(.roundedBorder)
                }
                Button("Simpan isian") { Task { await viewModel.saveInputs(check) } }
            } else if requisite?.kind == 1, let document = requisite?.documents?.first {
                Button("Pilih dan unggah berkas") {
                    uploadTarget = SubmissionUploadTarget(requisiteID: check.requisiteId, documentID: document.id)
                    isFileImporterPresented = true
                }
            }
            if check.isCompleted != 0 { Text("Tersimpan").font(.footnote).foregroundStyle(.green) }
        }
    }
}

fileprivate struct SubmissionUploadTarget { let requisiteID: Int; let documentID: Int }

@MainActor
final class SubmissionFlowViewModel: ObservableObject {
    enum Stage { case start, editing, success(String) }
    @Published private(set) var stage: Stage = .start
    @Published private(set) var checks: [SubmissionRequisiteCheck] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage: String?
    @Published private var inputValues: [String: String] = [:]

    private let sessionController: AppSessionController
    private let serviceID: Int
    private let api: any SubmissionFlowAPI
    private var submissionID: Int64?

    init(sessionController: AppSessionController, serviceID: Int, api: any SubmissionFlowAPI = LiveSubmissionFlowAPI()) { self.sessionController = sessionController; self.serviceID = serviceID; self.api = api }
    var allRequiredComplete: Bool { checks.allSatisfy { $0.requisite?.isRequired == 0 || $0.isCompleted != 0 } }
    func binding(for key: String) -> Binding<String> { Binding(get: { self.inputValues[key, default: ""] }, set: { self.inputValues[key] = $0 }) }

    func createDraft() async {
        guard let user = sessionController.user, let citizen = user.citizen else { errorMessage = "Profil warga harus dilengkapi terlebih dahulu."; return }
        isLoading = true; errorMessage = nil; defer { isLoading = false }
        do {
            let token = try await sessionController.activeAPIToken()
            let checks = try await api.create(apiToken: token, request: CreateSubmissionRequest(serviceId: serviceID, submitterId: user.id, applicableId: citizen.id, submittedAt: Self.dateFormatter.string(from: Date())))
            guard let submissionID = checks.first?.submissionId else { errorMessage = "Backend tidak mengembalikan ID draft karena layanan tidak memiliki persyaratan."; return }
            self.submissionID = submissionID; self.checks = checks; stage = .editing
        } catch { errorMessage = UserFacingErrorMapper.message(for: error) }
    }

    func saveAgreement(_ check: SubmissionRequisiteCheck) async { await persist(check) { token, id in try await self.api.agreement(apiToken: token, submissionID: id, requisiteID: check.requisiteId, checkID: check.id) } }
    func saveInputs(_ check: SubmissionRequisiteCheck) async {
        let values = (check.requisite?.inputs ?? []).map { SubmissionInputValue(key: $0.key, value: inputValues[$0.key, default: ""]) }
        guard !values.contains(where: { $0.value.isEmpty }) else { errorMessage = "Lengkapi semua isian yang ditampilkan."; return }
        await persist(check) { token, id in try await self.api.inputs(apiToken: token, submissionID: id, requisiteID: check.requisiteId, values: values) }
    }
    fileprivate func upload(url: URL, target: SubmissionUploadTarget) async {
        guard let check = checks.first(where: { $0.requisiteId == target.requisiteID }) else { return }
        do {
            let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }
            let file = MultipartFile(fieldName: "value", filename: url.lastPathComponent, mimeType: UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream", data: try Data(contentsOf: url))
            await persist(check) { token, id in try await self.api.file(apiToken: token, submissionID: id, requisiteID: target.requisiteID, documentID: target.documentID, file: file) }
        } catch { errorMessage = "Berkas tidak dapat dibaca." }
    }
    func send() async {
        guard let submissionID, allRequiredComplete, !isSubmitting else { return }
        isSubmitting = true; errorMessage = nil; defer { isSubmitting = false }
        do { let token = try await sessionController.activeAPIToken(); stage = .success(try await api.send(apiToken: token, submissionID: submissionID).message) }
        catch { errorMessage = UserFacingErrorMapper.message(for: error) }
    }
    private func persist(_ check: SubmissionRequisiteCheck, operation: (String, Int64) async throws -> [SubmissionRequisiteCheck]) async {
        guard let submissionID else { return }; isLoading = true; errorMessage = nil; defer { isLoading = false }
        do { let token = try await sessionController.activeAPIToken(); checks = try await operation(token, submissionID) } catch { errorMessage = UserFacingErrorMapper.message(for: error) }
    }
    private static let dateFormatter: DateFormatter = { let f = DateFormatter(); f.calendar = Calendar(identifier: .gregorian); f.locale = Locale(identifier: "en_US_POSIX"); f.dateFormat = "yyyy-MM-dd HH:mm:ss"; return f }()
}
#endif
