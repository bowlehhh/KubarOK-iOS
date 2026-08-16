#if canImport(SwiftUI)
import SwiftUI
import KubarOKCore

struct ServiceDetailView: View {

    @StateObject private var viewModel: ServiceDetailViewModel

    init(sessionController: AppSessionController, serviceID: Int) {
        _viewModel = StateObject(
            wrappedValue: ServiceDetailViewModel(
                sessionController: sessionController,
                serviceID: serviceID
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Memuat detail layanan…")
            } else if let errorMessage = viewModel.errorMessage {
                CatalogStateView(
                    title: "Detail layanan tidak tersedia",
                    message: errorMessage,
                    retryTitle: "Coba lagi",
                    retry: { Task { await viewModel.load() } }
                )
            } else if let service = viewModel.service {
                List {
                    Section {
                        Text(service.name).font(.title2.bold())
                        if let bureauName = service.bureau?.name {
                            Text(bureauName).foregroundStyle(.secondary)
                        }
                        if let description = service.description, !description.isEmpty {
                            Text(description)
                        }
                    }

                    if let procedures = service.procedures, !procedures.isEmpty {
                        Section("Prosedur") {
                            ForEach(procedures) { procedure in
                                VStack(alignment: .leading, spacing: AppSpacing.small) {
                                    Text(procedure.name)
                                    if let description = procedure.description, !description.isEmpty {
                                        Text(description).font(.footnote).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    Section("Persyaratan") {
                        if let requisites = service.requisites, !requisites.isEmpty {
                            ForEach(requisites) { requisite in
                                VStack(alignment: .leading, spacing: AppSpacing.small) {
                                    Text(requisite.title)
                                    Text(requisiteKindTitle(requisite.kind))
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    if let description = requisite.description, !description.isEmpty {
                                        Text(description).font(.footnote).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } else {
                            Text("Tidak ada persyaratan.").foregroundStyle(.secondary)
                        }
                    }

                    Section {
                        NavigationLink("Ajukan Layanan") {
                            SubmissionFlowView(sessionController: viewModel.sessionController, serviceID: service.id)
                        }
                    }
                }
            } else {
                CatalogStateView(title: "Detail layanan tidak tersedia")
            }
        }
        .navigationTitle("Detail Layanan")
        .task { await viewModel.load() }
    }

    private func requisiteKindTitle(_ kind: Int) -> String {
        switch kind {
        case 0: return "Persetujuan"
        case 1: return "Dokumen"
        case 2: return "Borang"
        default: return "Persyaratan"
        }
    }
}

@MainActor
final class ServiceDetailViewModel: ObservableObject {

    @Published private(set) var service: GovernmentService?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let sessionController: AppSessionController
    private let catalogAPI: any ServiceCatalogAPI
    private let serviceID: Int

    init(
        sessionController: AppSessionController,
        serviceID: Int,
        catalogAPI: any ServiceCatalogAPI = LiveServiceCatalogAPI()
    ) {
        self.sessionController = sessionController
        self.serviceID = serviceID
        self.catalogAPI = catalogAPI
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let token = try await sessionController.activeAPIToken()
            service = try await catalogAPI.fetchServiceDetail(
                apiToken: token,
                serviceID: serviceID
            )
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}
#endif
