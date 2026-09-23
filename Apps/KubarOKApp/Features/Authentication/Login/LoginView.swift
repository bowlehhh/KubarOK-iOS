#if canImport(SwiftUI)
import SwiftUI
import KubarOKCore

struct LoginView: View {

    @StateObject private var viewModel: LoginViewModel
    @ObservedObject private var sessionController: AppSessionController
    @State private var isPasswordVisible = false
    private let showPublicHome: () -> Void
    private let showRegistration: () -> Void

    init(
        sessionController: AppSessionController,
        showPublicHome: @escaping () -> Void,
        showRegistration: @escaping () -> Void
    ) {
        self.sessionController = sessionController
        self.showPublicHome = showPublicHome
        self.showRegistration = showRegistration
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            KubarOKDecorativeBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppSpacing.medium) {
                    KubarOKTopBar()
                        .overlay(alignment: .leading) {
                            Button(action: showPublicHome) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel("Kembali ke Beranda")
                        }
                        .padding(.horizontal, -AppSpacing.large)

                    Image("LoginIllustration")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 162)
                        .padding(.top, AppSpacing.extraLarge)
                        .accessibilityHidden(true)

                    Text("Silahkan Login/register terlebih dahulu")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .padding(.bottom, AppSpacing.extraLarge)

                    KubarOKField {
                        TextField("Email/No. Hp:", text: $viewModel.login)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.next)
                    }

                    KubarOKField {
                        HStack {
                            Group {
                                if isPasswordVisible {
                                    TextField("Password:", text: $viewModel.password)
                                } else {
                                    SecureField("Password:", text: $viewModel.password)
                                }
                            }
                            .textContentType(.password)

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(isPasswordVisible ? "Sembunyikan password" : "Tampilkan password")
                        }
                    }

                    NavigationLink("Lupa password?") {
                        ForgotPasswordView()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    if let errorMessage = viewModel.errorMessage ?? sessionController.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(AppColors.red)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel("Kesalahan: \(errorMessage)")
                    }

                    Button {
                        Task { await viewModel.submit() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Login")
                        }
                    }
                    .buttonStyle(KubarOKButtonStyle())
                    .disabled(viewModel.isLoading || viewModel.login.isEmpty || viewModel.password.isEmpty)
                    .opacity(viewModel.login.isEmpty || viewModel.password.isEmpty ? 0.55 : 1)

                    HStack(spacing: AppSpacing.extraSmall) {
                        Text("Belum punya akun?")
                        Button("Register disini", action: showRegistration)
                            .buttonStyle(.plain)
                            .foregroundStyle(AppColors.green)
                    }
                    .font(.caption)
                }
                .padding(.horizontal, AppSpacing.large)
                .padding(.bottom, 220)
            }
            .scrollDismissesKeyboard(.interactively)
        }
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
