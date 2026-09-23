#if canImport(SwiftUI)
import SwiftUI

struct RegistrationView: View {

    @StateObject private var viewModel: RegistrationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isPasswordVisible = false

    init(sessionController: AppSessionController) {
        _viewModel = StateObject(
            wrappedValue: RegistrationViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            registrationDecoration

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    KubarOKTopBar()
                        .overlay(alignment: .leading) {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel("Kembali")
                        }
                        .padding(.horizontal, -AppSpacing.large)

                    Label("Akun", systemImage: "person.crop.circle")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .labelStyle(.titleAndIcon)
                        .padding(.top, AppSpacing.extraLarge)

                    Text("Silahkan lengkapi data berikut")
                        .font(.subheadline.weight(.medium))
                        .padding(.bottom, AppSpacing.extraLarge)

                    KubarOKField {
                        TextField("Nama Lengkap", text: $viewModel.name)
                            .textContentType(.name)
                    }
                    KubarOKField {
                        TextField("Email", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                    }
                    KubarOKField {
                        TextField("No. Handphone", text: $viewModel.phone)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                    }
                    passwordField("Password", text: $viewModel.password)
                    passwordField("Konfirmasi password", text: $viewModel.confirmationPassword)

                    Text(PasswordPolicy.guidance)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(AppColors.red)
                            .accessibilityLabel("Kesalahan: \(errorMessage)")
                    }

                    Button {
                        Task { await viewModel.submit() }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Registrasi")
                        }
                    }
                    .buttonStyle(KubarOKButtonStyle())
                    .disabled(viewModel.isLoading)
                    .padding(.top, AppSpacing.large)

                    HStack(spacing: AppSpacing.extraSmall) {
                        Text("Sudah memiliki akun?")
                        Button("Login") { dismiss() }
                            .foregroundStyle(AppColors.green)
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, AppSpacing.large)
                .padding(.bottom, 220)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func passwordField(_ title: String, text: Binding<String>) -> some View {
        KubarOKField {
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField(title, text: text)
                    } else {
                        SecureField(title, text: text)
                    }
                }
                .textContentType(.newPassword)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPasswordVisible ? "Sembunyikan password" : "Tampilkan password")
            }
        }
    }

    private var registrationDecoration: some View {
        GeometryReader { proxy in
            Circle()
                .fill(AppColors.green.opacity(0.86))
                .frame(width: proxy.size.width * 1.12)
                .offset(x: -proxy.size.width * 0.66, y: -proxy.size.width * 0.15)
            Circle()
                .fill(AppColors.prussianBlue)
                .frame(width: proxy.size.width * 0.55)
                .offset(x: proxy.size.width * 0.80, y: proxy.size.height * 0.83)
            Circle()
                .fill(AppColors.green)
                .frame(width: proxy.size.width * 0.28)
                .offset(x: proxy.size.width * 0.72, y: proxy.size.height * 0.91)
        }
        .ignoresSafeArea()
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

@MainActor
final class RegistrationViewModel: ObservableObject {

    @Published var name = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    @Published var confirmationPassword = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let sessionController: AppSessionController

    init(sessionController: AppSessionController) {
        self.sessionController = sessionController
    }

    func submit() async {
        errorMessage = nil
        let input = RegistrationInput(
            name: name,
            email: email,
            phone: phone,
            password: password,
            confirmationPassword: confirmationPassword
        )

        if let validationError = input.validationError {
            errorMessage = UserFacingErrorMapper.message(for: validationError)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await sessionController.register(input: input)
            password = ""
            confirmationPassword = ""
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
    }
}
#endif
