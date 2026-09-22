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
        if !Self.isValidEmail(email) {
            return .invalidEmail
        }
        if phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .missingPhone
        }
        if !Self.isValidPhone(phone) {
            return .invalidPhone
        }
        if password.isEmpty {
            return .missingPassword
        }
        if password != confirmationPassword {
            return .passwordsDoNotMatch
        }
        if !PasswordPolicy.isValid(password) {
            return .weakPassword
        }
        return nil
    }

    private static func isValidEmail(_ value: String) -> Bool {
        let parts = value.split(separator: "@", omittingEmptySubsequences: false)
        return parts.count == 2 && parts[1].contains(".")
    }

    private static func isValidPhone(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (8...13).contains(normalized.count) else { return false }
        return normalized.enumerated().allSatisfy { index, character in
            character.isNumber || (index == 0 && character == "+")
        }
    }
}

public enum RegistrationValidationError: Error, Equatable {

    case missingName
    case missingEmail
    case invalidEmail
    case missingPhone
    case invalidPhone
    case missingPassword
    case weakPassword
    case passwordsDoNotMatch
}

public enum PasswordPolicy {

    public static let guidance = "Minimal 7 karakter, dengan huruf besar, angka, dan simbol."

    public static func isValid(_ password: String) -> Bool {
        password.count >= 7
            && password.contains(where: \Character.isUppercase)
            && password.contains(where: \Character.isNumber)
            && password.contains { !$0.isLetter && !$0.isNumber }
    }
}
