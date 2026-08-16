#if canImport(SwiftUI)
import SwiftUI

struct LoginView: View {

    @StateObject private var viewModel: LoginViewModel
    @ObservedObject private var sessionController: AppSessionController

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            VStack(spacing: AppSpacing.small) {
                Text("KUBAR OK")
                    .font(.largeTitle.bold())
                Text("Masuk untuk melanjutkan layanan Anda.")
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: AppSpacing.medium) {
                TextField("Email atau nomor HP", text: $viewModel.login)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
            }

            if let errorMessage = viewModel.errorMessage ?? sessionController.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button("Masuk") {
                Task { await viewModel.submit() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.login.isEmpty || viewModel.password.isEmpty)

            if viewModel.isLoading {
                ProgressView()
            }

            NavigationLink("Belum punya akun? Daftar", destination: {
                RegistrationView(sessionController: sessionController)
            })
        }
        .navigationTitle("Masuk")
    }
}

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var login = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let sessionController: AppSessionController

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
    }

    func submit() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await sessionController.login(login: login, password: password)
            password = ""
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}
#endif
