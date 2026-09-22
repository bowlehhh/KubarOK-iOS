#if canImport(SwiftUI)
import SwiftUI
import KubarOKCore

struct HomeView: View {

    @ObservedObject var sessionController: AppSessionController

    var body: some View {
        List {
            Section {
                Text("KUBAR OK")
                    .font(.largeTitle.bold())
                Text("Selamat datang, \(sessionController.user?.name ?? sessionController.user?.email ?? "Pengguna")")
                    .font(.title3)
            }

            Section("Informasi akun") {
                LabeledContent("Nama", value: sessionController.user?.name ?? "-")
                LabeledContent("Email", value: sessionController.user?.email ?? "-")
                LabeledContent("Nomor HP", value: sessionController.user?.phone ?? "-")
                LabeledContent("Citizen", value: sessionController.user?.citizen?.fullName ?? "-")
                if sessionController.user?.isActivated == false {
                    NavigationLink("Verifikasi nomor HP") {
                        PhoneVerificationView(sessionController: sessionController)
                    }
                }
            }

            Section("Layanan") {
                NavigationLink("Layanan Publik") {
                    BureauListView(sessionController: sessionController)
                }
                NavigationLink("Riwayat Pengajuan") {
                    SubmissionHistoryView(sessionController: sessionController)
                }
                NavigationLink("Informasi Terbaru") {
                    InformationListView(sessionController: sessionController)
                }
                NavigationLink("Notifikasi") {
                    NotificationListView(sessionController: sessionController)
                }
            }

            Section("Pengaturan") {
                NavigationLink("Edit Akun") {
                    AccountEditView(sessionController: sessionController)
                }
                if let citizen = sessionController.user?.citizen {
                    NavigationLink("Edit Profil Warga") {
                        ProfileOnboardingView(
                            sessionController: sessionController,
                            citizen: citizen
                        )
                    }
                }
            }

            Section {
                Button("Keluar", role: .destructive) {
                    Task { await sessionController.logout() }
                }
            }
        }
        .navigationTitle("Beranda")
    }
}

struct PhoneVerificationView: View {

    @StateObject private var viewModel: PhoneVerificationViewModel

    init(sessionController: AppSessionController) {
        _viewModel = StateObject(
            wrappedValue: PhoneVerificationViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        Form {
            Section {
                Text("Kode OTP akan dikirim ke nomor HP akun Anda.")
                    .foregroundStyle(.secondary)
                if let phone = viewModel.phone {
                    LabeledContent("Nomor HP", value: phone)
                }
                if let expiresAt = viewModel.expiresAt {
                    LabeledContent("Berlaku sampai", value: expiresAt)
                }
            }

            Section("Verifikasi") {
                Button("Kirim OTP") { Task { await viewModel.requestOTP() } }
                    .disabled(viewModel.isLoading || viewModel.phone == nil)
                TextField("Kode OTP", text: $viewModel.otp)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                Button("Verifikasi nomor HP") { Task { await viewModel.verify() } }
                    .disabled(viewModel.isLoading || viewModel.otp.isEmpty)
            }

            if let message = viewModel.message {
                Section { Text(message).foregroundStyle(.green) }
            }
            if let errorMessage = viewModel.errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }
            if viewModel.isLoading {
                Section { ProgressView() }
            }
        }
        .navigationTitle("Verifikasi HP")
    }
}

@MainActor
private final class PhoneVerificationViewModel: ObservableObject {

    @Published var otp = ""
    @Published private(set) var expiresAt: String?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var message: String?

    private let sessionController: AppSessionController

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
    }

    var phone: String? {
        guard let phone = sessionController.user?.phone, !phone.isEmpty else { return nil }
        return phone
    }

    func requestOTP() async {
        guard let phone else {
            errorMessage = "Nomor HP belum tersedia pada akun."
            return
        }
        await perform {
            expiresAt = try await PasswordRecoveryService.shared.requestOTP(phone: phone).expiresAt
            message = "Kode OTP telah diminta."
        }
    }

    func verify() async {
        await perform {
            let token = try await sessionController.activeAPIToken()
            _ = try await UserService.shared.verifyPhone(apiToken: token, otp: otp)
            try await sessionController.refreshUser()
            otp = ""
            message = "Nomor HP berhasil diverifikasi."
        }
    }

    private func perform(_ operation: () async throws -> Void) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        message = nil
        defer { isLoading = false }
        do { try await operation() }
        catch { errorMessage = UserFacingErrorMapper.message(for: error) }
    }
}

private struct AccountEditView: View {

    @StateObject private var viewModel: AccountEditViewModel

    init(sessionController: AppSessionController) {
        _viewModel = StateObject(
            wrappedValue: AccountEditViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        Form {
            Section("Data akun") {
                TextField("Nama", text: $viewModel.name).textContentType(.name)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Nomor HP", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                SecureField("Password baru (opsional)", text: $viewModel.password)
                    .textContentType(.newPassword)
                Text(PasswordPolicy.guidance)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let message = viewModel.message {
                Section { Text(message).foregroundStyle(.green) }
            }
            if let errorMessage = viewModel.errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }

            Section {
                Button("Simpan perubahan") { Task { await viewModel.save() } }
                    .disabled(viewModel.isLoading)
                if viewModel.isLoading { ProgressView() }
            }
        }
        .navigationTitle("Edit Akun")
    }
}

@MainActor
private final class AccountEditViewModel: ObservableObject {

    @Published var name: String
    @Published var email: String
    @Published var phone: String
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var message: String?

    private let sessionController: AppSessionController

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
        name = sessionController.user?.name ?? ""
        email = sessionController.user?.email ?? ""
        phone = sessionController.user?.phone ?? ""
    }

    func save() async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Nama, email, dan nomor HP wajib diisi."
            return
        }
        if !password.isEmpty && !PasswordPolicy.isValid(password) {
            errorMessage = PasswordPolicy.guidance
            return
        }

        isLoading = true
        errorMessage = nil
        message = nil
        defer { isLoading = false }

        do {
            let token = try await sessionController.activeAPIToken()
            _ = try await UserService.shared.updateUser(
                apiToken: token,
                request: UpdateUserRequest(
                    name: name,
                    email: email,
                    phone: phone,
                    password: password.isEmpty ? nil : password
                )
            )
            try await sessionController.refreshUser()
            password = ""
            message = "Data akun berhasil diperbarui."
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}

private struct InformationListView: View {

    @StateObject private var viewModel: InformationListViewModel

    init(sessionController: AppSessionController) {
        _viewModel = StateObject(
            wrappedValue: InformationListViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.items.isEmpty {
                ProgressView("Memuat informasi…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
                CatalogStateView(
                    title: "Informasi tidak tersedia",
                    message: errorMessage,
                    retryTitle: "Coba lagi",
                    retry: { Task { await viewModel.loadFirstPage() } }
                )
            } else if viewModel.items.isEmpty {
                CatalogStateView(title: "Belum ada informasi")
            } else {
                List {
                    if let announcementURL = viewModel.announcementURL {
                        Section("Pengumuman terbaru") {
                            Link("Buka pengumuman", destination: announcementURL)
                        }
                    }
                    ForEach(viewModel.items) { item in
                        NavigationLink {
                            InformationDetailView(item: item)
                        } label: {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                HStack {
                                    Text(item.title).font(.headline)
                                    if item.isAnnouncement != 0 {
                                        Text("Pengumuman")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.orange)
                                    }
                                }
                                Text(item.plainDescription)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                                if let bureau = item.bureau?.shortName ?? item.bureau?.name {
                                    Text(bureau).font(.caption).foregroundStyle(.secondary)
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
                .refreshable { await viewModel.loadFirstPage() }
            }
        }
        .navigationTitle("Informasi")
        .task {
            await viewModel.loadFirstPage()
            await viewModel.loadAnnouncementIfNeeded()
        }
    }
}

private struct InformationDetailView: View {

    let item: InformationItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                if let path = item.file?.path, let url = URL(string: path) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 160)
                    }
                }
                Text(item.title).font(.title2.bold())
                if let bureau = item.bureau?.name {
                    Text(bureau).foregroundStyle(.secondary)
                }
                Text(item.plainDescription)
                if let path = item.contentFile?.path, let url = URL(string: path) {
                    Link("Buka lampiran", destination: url)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.medium)
        }
        .navigationTitle("Detail Informasi")
    }
}

@MainActor
private final class InformationListViewModel: ObservableObject {

    @Published private(set) var items: [InformationItem] = []
    @Published private(set) var announcementURL: URL?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let sessionController: AppSessionController
    private var pagination: PaginationMeta?
    private var didLoadAnnouncement = false

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
    }

    var canLoadNextPage: Bool {
        guard let pagination else { return false }
        return pagination.currentPage < pagination.lastPage
    }

    func loadFirstPage() async { await load(page: 1, replacing: true) }

    func loadNextPage() async {
        guard let pagination, pagination.currentPage < pagination.lastPage else { return }
        await load(page: pagination.currentPage + 1, replacing: false)
    }

    func loadAnnouncementIfNeeded() async {
        guard !didLoadAnnouncement else { return }
        didLoadAnnouncement = true
        do {
            let token = try await sessionController.activeAPIToken()
            let announcement = try await InformationService.shared.lastAnnouncement(apiToken: token)
            announcementURL = URL(string: announcement.path)
        } catch {
            // This endpoint currently returns HTTP 500 when no announcement exists.
            // The regular information list remains usable in that condition.
        }
    }

    private func load(page: Int, replacing: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let token = try await sessionController.activeAPIToken()
            let response = try await InformationService.shared.latest(apiToken: token, page: page)
            items = replacing ? response.data : items + response.data
            pagination = response.meta
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}

private struct NotificationListView: View {

    @StateObject private var viewModel: NotificationListViewModel
    @State private var confirmsDeleteAll = false

    init(sessionController: AppSessionController) {
        _viewModel = StateObject(
            wrappedValue: NotificationListViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                ProgressView("Memuat notifikasi…")
            } else if let errorMessage = viewModel.errorMessage, viewModel.notifications.isEmpty {
                CatalogStateView(
                    title: "Notifikasi tidak tersedia",
                    message: errorMessage,
                    retryTitle: "Coba lagi",
                    retry: { Task { await viewModel.loadFirstPage() } }
                )
            } else if viewModel.notifications.isEmpty {
                CatalogStateView(title: "Belum ada notifikasi")
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        NavigationLink {
                            NotificationDetailView(
                                sessionController: viewModel.sessionController,
                                notificationID: notification.id
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                HStack {
                                    Text(notification.title).font(.headline)
                                    if notification.isRead == 0 {
                                        Circle().fill(.blue).frame(width: 8, height: 8)
                                    }
                                }
                                Text(notification.description)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                if let createdAt = notification.createdAt {
                                    Text(createdAt).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .swipeActions {
                            Button("Hapus", role: .destructive) {
                                Task { await viewModel.delete(notification) }
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
                .refreshable { await viewModel.loadFirstPage() }
            }
        }
        .navigationTitle(viewModel.unreadCount > 0 ? "Notifikasi (\(viewModel.unreadCount))" : "Notifikasi")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Tandai semua dibaca") { Task { await viewModel.markAllRead() } }
                    Button("Hapus semua", role: .destructive) { confirmsDeleteAll = true }
                } label: {
                    Label("Aksi notifikasi", systemImage: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            "Hapus semua notifikasi?",
            isPresented: $confirmsDeleteAll,
            titleVisibility: .visible
        ) {
            Button("Hapus semua", role: .destructive) { Task { await viewModel.deleteAll() } }
        }
        .task { await viewModel.loadFirstPage() }
    }
}

private struct NotificationDetailView: View {

    @StateObject private var viewModel: NotificationDetailViewModel

    init(sessionController: AppSessionController, notificationID: Int) {
        _viewModel = StateObject(
            wrappedValue: NotificationDetailViewModel(
                sessionController: sessionController,
                notificationID: notificationID
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Memuat notifikasi…")
            } else if let errorMessage = viewModel.errorMessage {
                CatalogStateView(
                    title: "Notifikasi tidak tersedia",
                    message: errorMessage,
                    retryTitle: "Coba lagi",
                    retry: { Task { await viewModel.load() } }
                )
            } else if let notification = viewModel.notification {
                List {
                    Section {
                        Text(notification.title).font(.title3.bold())
                        Text(notification.description)
                        if let createdAt = notification.createdAt {
                            Text(createdAt).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    if let submissionID = notification.submissionId {
                        Section {
                            NavigationLink("Lihat pengajuan") {
                                SubmissionTrackingDetailView(
                                    sessionController: viewModel.sessionController,
                                    submissionID: submissionID
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Detail Notifikasi")
        .task { await viewModel.load() }
    }
}

@MainActor
private final class NotificationListViewModel: ObservableObject {

    @Published private(set) var notifications: [UserNotification] = []
    @Published private(set) var unreadCount = 0
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let sessionController: AppSessionController
    private var pagination: PaginationMeta?

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
    }

    var canLoadNextPage: Bool {
        guard let pagination else { return false }
        return pagination.currentPage < pagination.lastPage
    }

    func loadFirstPage() async { await load(page: 1, replacing: true) }

    func loadNextPage() async {
        guard let pagination, pagination.currentPage < pagination.lastPage else { return }
        await load(page: pagination.currentPage + 1, replacing: false)
    }

    func markAllRead() async {
        await mutate {
            let token = try await sessionController.activeAPIToken()
            _ = try await NotificationService.shared.markAllRead(apiToken: token)
        }
    }

    func delete(_ notification: UserNotification) async {
        await mutate {
            let token = try await sessionController.activeAPIToken()
            _ = try await NotificationService.shared.delete(apiToken: token, id: notification.id)
        }
    }

    func deleteAll() async {
        await mutate {
            let token = try await sessionController.activeAPIToken()
            _ = try await NotificationService.shared.deleteAll(apiToken: token)
        }
    }

    private func mutate(_ operation: () async throws -> Void) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await operation()
            isLoading = false
            await loadFirstPage()
        } catch {
            isLoading = false
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }

    private func load(page: Int, replacing: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let token = try await sessionController.activeAPIToken()
            async let pageResponse = NotificationService.shared.list(apiToken: token, page: page)
            async let countResponse = NotificationService.shared.unreadCount(apiToken: token)
            let (response, count) = try await (pageResponse, countResponse)
            notifications = replacing ? response.data : notifications + response.data
            pagination = response.meta
            unreadCount = count
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}

@MainActor
private final class NotificationDetailViewModel: ObservableObject {

    @Published private(set) var notification: UserNotification?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    let sessionController: AppSessionController
    private let notificationID: Int

    init(sessionController: AppSessionController, notificationID: Int) {
        self.sessionController = sessionController
        self.notificationID = notificationID
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let token = try await sessionController.activeAPIToken()
            notification = try await NotificationService.shared.detail(
                apiToken: token,
                id: notificationID
            )
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}

private extension InformationItem {
    var plainDescription: String {
        description
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
    }
}
#endif
