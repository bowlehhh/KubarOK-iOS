import Foundation

public struct RegistrationInput: Sendable, Equatable {

    public let name: String
    public let email: String
    public let phone: String
    public let password: String
    public let confirmationPassword: String

    public init(
        name: String,
        email: String,
        phone: String,
        password: String,
        confirmationPassword: String
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
        self.confirmationPassword = confirmationPassword
    }

    public var validationError: RegistrationValidationError? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingName
        }
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingEmail
        }
        if phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingPhone
        }
        if password.isEmpty {
            return .missingPassword
        }
        if password != confirmationPassword {
            return .passwordsDoNotMatch
        }
        return nil
    }
}

public enum RegistrationValidationError: Error, Equatable {

    case missingName
    case missingEmail
    case missingPhone
    case missingPassword
    case passwordsDoNotMatch
}
