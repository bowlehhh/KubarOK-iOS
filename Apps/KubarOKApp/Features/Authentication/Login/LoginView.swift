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

            NavigationLink("Lupa password?", destination: {
                ForgotPasswordView()
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

private struct ForgotPasswordView: View {

    @StateObject private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        Form {
            switch viewModel.phase {
            case .requestOTP:
                Section("Nomor HP terdaftar") {
                    TextField("Nomor HP", text: $viewModel.phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    Button("Kirim OTP") { Task { await viewModel.requestOTP() } }
                        .disabled(viewModel.phone.isEmpty || viewModel.isLoading)
                }
            case .verifyOTP:
                Section("Kode OTP") {
                    Text("Kode berlaku sampai \(viewModel.expiresAt ?? "waktu yang ditentukan server").")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    TextField("Kode OTP", text: $viewModel.otp)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                    Button("Verifikasi OTP") { Task { await viewModel.checkOTP() } }
                        .disabled(viewModel.otp.isEmpty || viewModel.isLoading)
                    Button("Kirim ulang OTP") { Task { await viewModel.requestOTP() } }
                        .disabled(viewModel.isLoading)
                }
            case .resetPassword:
                Section("Password baru") {
                    SecureField("Password baru", text: $viewModel.password)
                        .textContentType(.newPassword)
                    SecureField("Konfirmasi password", text: $viewModel.confirmationPassword)
                        .textContentType(.newPassword)
                    Text(PasswordPolicy.guidance)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Simpan password") { Task { await viewModel.resetPassword() } }
                        .disabled(viewModel.isLoading)
                }
            case .complete:
                Section {
                    Label("Password berhasil diubah. Silakan kembali dan masuk.", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }
            if viewModel.isLoading {
                Section { ProgressView() }
            }
        }
        .navigationTitle("Lupa Password")
    }
}

@MainActor
private final class ForgotPasswordViewModel: ObservableObject {

    enum Phase { case requestOTP, verifyOTP, resetPassword, complete }

    @Published var phone = ""
    @Published var otp = ""
    @Published var password = ""
    @Published var confirmationPassword = ""
    @Published private(set) var phase: Phase = .requestOTP
    @Published private(set) var expiresAt: String?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service = PasswordRecoveryService.shared

    func requestOTP() async {
        await perform {
            let expiration = try await service.requestOTP(phone: phone)
            expiresAt = expiration.expiresAt
            phase = .verifyOTP
        }
    }

    func checkOTP() async {
        await perform {
            _ = try await service.checkOTP(otp)
            phase = .resetPassword
        }
    }

    func resetPassword() async {
        guard password == confirmationPassword else {
            errorMessage = "Konfirmasi password tidak sama."
            return
        }
        guard PasswordPolicy.isValid(password) else {
            errorMessage = PasswordPolicy.guidance
            return
        }
        await perform {
            try await service.resetPassword(otp: otp, password: password)
            password = ""
            confirmationPassword = ""
            phase = .complete
        }
    }

    private func perform(_ operation: () async throws -> Void) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await operation()
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}
#endif
