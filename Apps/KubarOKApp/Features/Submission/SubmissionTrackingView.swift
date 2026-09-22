#if canImport(SwiftUI)
import SwiftUI
import KubarOKCore

struct SubmissionHistoryView: View {

    @StateObject private var viewModel: SubmissionHistoryViewModel
    @ObservedObject private var sessionController: AppSessionController
    @State private var pendingDeletion: SubmissionHistoryItem?
    @State private var confirmsDeletion = false

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
        _viewModel = StateObject(wrappedValue: SubmissionHistoryViewModel(sessionController: sessionController))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.history.submissions.isEmpty {
                ProgressView("Memuat riwayat pengajuan…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.history.submissions.isEmpty {
                CatalogStateView(
                    title: "Riwayat tidak tersedia",
                    message: errorMessage,
                    retryTitle: "Coba lagi",
                    retry: { Task { await viewModel.loadFirstPage() } }
                )
            } else if viewModel.history.submissions.isEmpty {
                CatalogStateView(title: "Belum ada pengajuan")
            } else {
                List {
                    ForEach(viewModel.history.submissions) { submission in
                        NavigationLink {
                            SubmissionTrackingDetailView(
                                sessionController: sessionController,
                                submissionID: submission.id
                            )
                        } label: {
                            SubmissionHistoryRow(submission: submission)
                        }
                        .swipeActions {
                            if submission.state == .draft {
                                Button("Hapus", role: .destructive) {
                                    pendingDeletion = submission
                                    confirmsDeletion = true
                                }
                            }
                        }
                    }

                    if viewModel.history.canLoadNextPage {
                        Button(viewModel.isLoading ? "Memuat…" : "Muat lebih banyak") {
                            Task { await viewModel.loadNextPage() }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
        .confirmationDialog(
            "Hapus draft pengajuan?",
            isPresented: $confirmsDeletion,
            titleVisibility: .visible
        ) {
            Button("Hapus draft", role: .destructive) {
                guard let pendingDeletion else { return }
                Task { await viewModel.delete(pendingDeletion) }
            }
        }
        .navigationTitle("Riwayat Pengajuan")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Semua status") { Task { await viewModel.selectFilter(nil) } }
                    ForEach(SubmissionState.allCases, id: \.rawValue) { state in
                        Button(state.title) { Task { await viewModel.selectFilter(state) } }
                    }
                } label: {
                    Label("Filter status", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .task { await viewModel.loadFirstPage() }
    }
}

private struct SubmissionHistoryRow: View {
    let submission: SubmissionHistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .firstTextBaseline) {
                Text(submission.service?.name ?? "Layanan #\(submission.serviceId)")
                    .font(.headline)
                Spacer()
                SubmissionStateBadge(state: submission.state)
            }
            Text("Pengajuan #\(submission.id)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let submittedAt = submission.submittedAt {
                Text("Diajukan: \(submittedAt)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppSpacing.extraSmall)
    }
}

struct SubmissionTrackingDetailView: View {

    @StateObject private var viewModel: SubmissionTrackingDetailViewModel

    init(sessionController: AppSessionController, submissionID: String) {
        _viewModel = StateObject(
            wrappedValue: SubmissionTrackingDetailViewModel(
                sessionController: sessionController,
                submissionID: submissionID
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Memuat detail pengajuan…")
            } else if let errorMessage = viewModel.errorMessage {
                CatalogStateView(
                    title: "Detail tidak tersedia",
                    message: errorMessage,
                    retryTitle: "Coba lagi",
                    retry: { Task { await viewModel.load() } }
                )
            } else if let detail = viewModel.detail {
                List {
                    Section("Pengajuan") {
                        LabeledContent("Layanan", value: detail.service?.name ?? "Layanan #\(detail.serviceId)")
                        LabeledContent("Nomor pengajuan", value: detail.id)
                        HStack {
                            Text("Status")
                            Spacer()
                            SubmissionStateBadge(state: detail.state)
                        }
                        if let submittedAt = detail.submittedAt {
                            LabeledContent("Diajukan", value: submittedAt)
                        }
                        if let latestActivity = detail.latestActivity {
                            LabeledContent("Aktivitas terakhir", value: latestActivity)
                        }
                    }

                    Section("Persyaratan") {
                        let completed = detail.requisiteChecks.filter { $0.isCompleted != 0 }.count
                        LabeledContent("Terpenuhi", value: "\(completed) dari \(detail.requisiteChecks.count)")
                    }

                    if detail.state == .draft,
                       let submissionID = Int64(detail.id) {
                        Section {
                            if viewModel.sessionController.user?.isActivated == true {
                                NavigationLink("Lanjutkan Draft") {
                                    SubmissionFlowView(
                                        sessionController: viewModel.sessionController,
                                        serviceID: detail.serviceId,
                                        submissionID: submissionID
                                    )
                                }
                            } else {
                                NavigationLink("Verifikasi nomor HP untuk melanjutkan") {
                                    PhoneVerificationView(
                                        sessionController: viewModel.sessionController
                                    )
                                }
                            }
                        }
                    }

                    if !detail.products.isEmpty {
                        Section("Dokumen Hasil") {
                            ForEach(detail.products) { product in
                                VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                                    Text(product.reference ?? "Dokumen hasil")
                                    if let issueDate = product.issueDate {
                                        Text(issueDate).font(.footnote).foregroundStyle(.secondary)
                                    }
                                    if let path = product.file?.path, let url = URL(string: path) {
                                        Link("Buka dokumen", destination: url)
                                    }
                                }
                            }
                        }
                    }

                    Section("Progress") {
                        let timeline = SubmissionTimelineMapper.items(from: detail)
                        if timeline.isEmpty {
                            Text("Progress belum tersedia.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(timeline) { item in
                                SubmissionTimelineRow(item: item)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Tracking Pengajuan")
        .task { await viewModel.load() }
    }
}

private struct SubmissionTimelineRow: View {
    let item: SubmissionTimelineItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
            HStack {
                Text(item.title).font(.headline)
                Spacer()
                if let state = item.state {
                    SubmissionProgressStateBadge(state: state)
                } else if item.isLatest {
                    Text("Saat ini")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tint)
                }
            }
            if let description = item.description, !description.isEmpty {
                Text(description).font(.footnote).foregroundStyle(.secondary)
            }
            if let note = item.note, !note.isEmpty {
                Text(note).font(.footnote)
            }
            if let occurredAt = item.occurredAt {
                Text(occurredAt).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppSpacing.extraSmall)
    }
}

private struct SubmissionStateBadge: View {
    let state: SubmissionState

    var body: some View {
        Text(state.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(state.tint)
    }
}

private struct SubmissionProgressStateBadge: View {
    let state: SubmissionProgressState

    var body: some View {
        Text(state.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(state.tint)
    }
}

@MainActor
private final class SubmissionHistoryViewModel: ObservableObject {
    @Published private(set) var history = SubmissionHistoryState()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let sessionController: AppSessionController
    private let trackingAPI: any SubmissionTrackingAPI

    init(sessionController: AppSessionController, trackingAPI: any SubmissionTrackingAPI = LiveSubmissionTrackingAPI()) {
        self.sessionController = sessionController
        self.trackingAPI = trackingAPI
    }

    func selectFilter(_ state: SubmissionState?) async {
        history.setStateFilter(state)
        await loadFirstPage()
    }

    func loadFirstPage() async {
        await load(page: 1, replacingExisting: true)
    }

    func loadNextPage() async {
        guard let nextPage = history.nextPage else { return }
        await load(page: nextPage, replacingExisting: false)
    }

    func delete(_ submission: SubmissionHistoryItem) async {
        guard submission.state == .draft,
              let submissionID = Int64(submission.id),
              !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let token = try await sessionController.activeAPIToken()
            _ = try await trackingAPI.deleteSubmission(
                apiToken: token,
                submissionID: submissionID
            )
            isLoading = false
            await loadFirstPage()
        } catch {
            isLoading = false
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }

    private func load(page: Int, replacingExisting: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let token = try await sessionController.activeAPIToken()
            let response = try await trackingAPI.fetchHistory(
                apiToken: token,
                state: history.stateFilter,
                serviceID: nil,
                page: page
            )
            if replacingExisting {
                history.replace(with: response)
            } else {
                history.append(response)
            }
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}

@MainActor
private final class SubmissionTrackingDetailViewModel: ObservableObject {
    @Published private(set) var detail: SubmissionDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let sessionController: AppSessionController
    private let trackingAPI: any SubmissionTrackingAPI
    private let submissionID: String

    init(
        sessionController: AppSessionController,
        submissionID: String,
        trackingAPI: any SubmissionTrackingAPI = LiveSubmissionTrackingAPI()
    ) {
        self.sessionController = sessionController
        self.submissionID = submissionID
        self.trackingAPI = trackingAPI
    }

    func load() async {
        guard !isLoading else { return }
        guard let numericID = Int64(submissionID) else {
            errorMessage = "Nomor pengajuan tidak valid."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let token = try await sessionController.activeAPIToken()
            detail = try await trackingAPI.fetchDetail(apiToken: token, submissionID: numericID)
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}

private extension SubmissionState {
    var title: String {
        switch self {
        case .rejected: return "Ditolak"
        case .draft: return "Draft"
        case .open: return "Dalam proses"
        case .onHold: return "Tunda"
        case .done: return "Selesai"
        }
    }

    var tint: Color {
        switch self {
        case .rejected: return .red
        case .draft: return .secondary
        case .open: return .blue
        case .onHold: return .orange
        case .done: return .green
        }
    }
}

private extension SubmissionProgressState {
    var title: String {
        switch self {
        case .rejected: return "Ditolak"
        case .open: return "Diproses"
        case .onHold: return "Ditunda"
        case .accepted: return "Disetujui"
        }
    }

    var tint: Color {
        switch self {
        case .rejected: return .red
        case .open: return .blue
        case .onHold: return .orange
        case .accepted: return .green
        }
    }
}
#endif
