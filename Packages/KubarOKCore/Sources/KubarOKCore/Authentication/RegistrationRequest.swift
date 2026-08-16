import Foundation

public struct RegistrationRequest: Codable, Sendable {

    public let name: String
    public let phone: String
    public let email: String
    public let password: String
    public let deviceToken: String

    public init(
        name: String,
        phone: String,
        email: String,
        password: String,
        deviceToken: String = ""
    ) {
        self.name = name
        self.phone = phone
        self.email = email
        self.password = password
        self.deviceToken = deviceToken
    }

    enum CodingKeys: String, CodingKey {
        case name
        case phone
        case email
        case password
        case deviceToken = "device_token"
    }
}
