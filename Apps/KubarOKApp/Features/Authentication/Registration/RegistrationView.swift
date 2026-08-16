#if canImport(SwiftUI)
import SwiftUI

struct RegistrationView: View {

    @StateObject private var viewModel: RegistrationViewModel

    init(sessionController: AppSessionController) {
        _viewModel = StateObject(
            wrappedValue: RegistrationViewModel(sessionController: sessionController)
        )
    }

    var body: some View {
        Form {
            Section("Data akun") {
                TextField("Nama", text: $viewModel.name)
                    .textContentType(.name)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                TextField("Nomor HP", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword)
                SecureField("Konfirmasi password", text: $viewModel.confirmationPassword)
                    .textContentType(.newPassword)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red)
                }
            }

            Section {
                Button("Daftar") {
                    Task { await viewModel.submit() }
                }
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
        .navigationTitle("Daftar")
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
