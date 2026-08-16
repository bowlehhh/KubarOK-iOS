#if canImport(SwiftUI)
import SwiftUI
import KubarOKCore

struct ServiceListView: View {

    let bureau: Bureau
    @StateObject private var viewModel: ServiceListViewModel
    @ObservedObject private var sessionController: AppSessionController

    init(sessionController: AppSessionController, bureau: Bureau) {
        self.bureau = bureau
        self.sessionController = sessionController
        _viewModel = StateObject(
            wrappedValue: ServiceListViewModel(
                sessionController: sessionController,
                bureauID: bureau.id
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.services.isEmpty {
                ProgressView("Memuat layanan…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.services.isEmpty {
                CatalogStateView(
                    title: "Layanan tidak tersedia",
                    message: errorMessage,
                    retryTitle: "Coba lagi",
                    retry: { Task { await viewModel.loadFirstPage() } }
                )
            } else if viewModel.services.isEmpty {
                CatalogStateView(title: "Belum ada layanan")
            } else {
                List {
                    ForEach(viewModel.services) { service in
                        NavigationLink {
                            ServiceDetailView(sessionController: sessionController, serviceID: service.id)
                        } label: {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text(service.name)
                                if let description = service.description, !description.isEmpty {
                                    Text(description).font(.footnote).foregroundStyle(.secondary).lineLimit(2)
                                }
                                if let requisitesCount = service.requisitesCount {
                                    Text("\(requisitesCount) persyaratan").font(.footnote).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    if viewModel.canLoadNextPage {
                        Button(viewModel.isLoading ? "Memuat…" : "Muat lebih banyak") {
                            Task { await viewModel.loadNextPage() }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
        }
        .navigationTitle(bureau.shortName ?? "Layanan")
        .task { await viewModel.loadFirstPage() }
    }
}

@MainActor
final class ServiceListViewModel: ObservableObject {

    @Published private(set) var services: [GovernmentService] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let sessionController: AppSessionController
    private let catalogAPI: any ServiceCatalogAPI
    private let bureauID: Int
    private var pagination: PaginationMeta?

    init(
        sessionController: AppSessionController,
        bureauID: Int,
        catalogAPI: any ServiceCatalogAPI = LiveServiceCatalogAPI()
    ) {
        self.sessionController = sessionController
        self.bureauID = bureauID
        self.catalogAPI = catalogAPI
    }

    var canLoadNextPage: Bool {
        guard let pagination else { return false }
        return pagination.currentPage < pagination.lastPage
    }

    func loadFirstPage() async {
        await load(page: 1, replacingExisting: true)
    }

    func loadNextPage() async {
        guard let pagination, pagination.currentPage < pagination.lastPage else { return }
        await load(page: pagination.currentPage + 1, replacingExisting: false)
    }

    private func load(page: Int, replacingExisting: Bool) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let token = try await sessionController.activeAPIToken()
            let response = try await catalogAPI.fetchServices(
                apiToken: token,
                bureauID: bureauID,
                page: page
            )
            services = replacingExisting ? response.data : services + response.data
            pagination = response.meta
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}
#endif
