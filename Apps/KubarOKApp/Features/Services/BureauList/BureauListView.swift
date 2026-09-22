#if canImport(SwiftUI)
import SwiftUI
import KubarOKCore

struct BureauListView: View {

    @StateObject private var viewModel: BureauListViewModel
    @ObservedObject private var sessionController: AppSessionController

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
        _viewModel = StateObject(
            wrappedValue: BureauListViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.bureaus.isEmpty {
                ProgressView("Memuat daftar dinas…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.bureaus.isEmpty {
                CatalogStateView(
                    title: "Daftar dinas tidak tersedia",
                    message: errorMessage,
                    retryTitle: "Coba lagi",
                    retry: { Task { await viewModel.loadFirstPage() } }
                )
            } else if viewModel.bureaus.isEmpty {
                CatalogStateView(title: "Belum ada dinas")
            } else {
                List {
                    ForEach(viewModel.bureaus) { bureau in
                        NavigationLink {
                            ServiceListView(sessionController: sessionController, bureau: bureau)
                        } label: {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text(bureau.name)
                                if let shortName = bureau.shortName {
                                    Text(shortName).font(.footnote).foregroundStyle(.secondary)
                                }
                                if let servicesCount = bureau.servicesCount {
                                    Text("\(servicesCount) layanan").font(.footnote).foregroundStyle(.secondary)
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
        .navigationTitle("Dinas")
        .searchable(text: $viewModel.query, prompt: "Cari dinas")
        .onSubmit(of: .search) { Task { await viewModel.loadFirstPage() } }
        .onChange(of: viewModel.query) { value in
            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Task { await viewModel.loadFirstPage() }
            }
        }
        .refreshable { await viewModel.loadFirstPage() }
        .task { await viewModel.loadFirstPage() }
    }
}

@MainActor
final class BureauListViewModel: ObservableObject {

    @Published private(set) var bureaus: [Bureau] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var query = ""

    private let sessionController: AppSessionController
    private let catalogAPI: any ServiceCatalogAPI
    private var pagination: PaginationMeta?

    init(
        sessionController: AppSessionController,
        catalogAPI: any ServiceCatalogAPI = LiveServiceCatalogAPI()
    ) {
        self.sessionController = sessionController
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
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let token = try await sessionController.activeAPIToken()
            let search = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let response = if search.isEmpty {
                try await catalogAPI.fetchBureaus(apiToken: token, page: page)
            } else {
                try await catalogAPI.searchBureaus(
                    apiToken: token,
                    name: search,
                    page: page
                )
            }
            bureaus = replacingExisting ? response.data : bureaus + response.data
            pagination = response.meta
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}
#endif
