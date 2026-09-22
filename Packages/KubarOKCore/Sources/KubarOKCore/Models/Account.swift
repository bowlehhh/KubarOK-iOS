import Foundation

public struct UpdateUserRequest: Codable, Sendable, Equatable {

    public let name: String
    public let email: String
    public let phone: String
    public let password: String?

    public init(name: String, email: String, phone: String, password: String? = nil) {
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
    }
}

public struct OTPPhoneRequest: Codable, Sendable, Equatable {

    public let phone: String

    public init(phone: String) {
        self.phone = phone
    }
}

public struct OTPCodeRequest: Codable, Sendable, Equatable {

    public let otp: String

    public init(otp: String) {
        self.otp = otp
    }
}

public struct ResetPasswordRequest: Codable, Sendable, Equatable {

    public let otp: String
    public let password: String

    public init(otp: String, password: String) {
        self.otp = otp
        self.password = password
    }
}

public struct OTPExpiration: Codable, Sendable, Equatable {

    public let expiresAt: String

    public init(expiresAt: String) {
        self.expiresAt = expiresAt
    }

    enum CodingKeys: String, CodingKey {
        case expiresAt = "otp_expired_at"
    }
}
