import Foundation

public struct LoginRequest: Codable, Sendable {

    public let login: String
    public let password: String
    public let deviceToken: String

    public init(
        login: String,
        password: String,
        deviceToken: String = ""
    ) {
        self.login = login
        self.password = password
        self.deviceToken = deviceToken
    }

    enum CodingKeys: String, CodingKey {
        case login
        case password
        case deviceToken = "device_token"
    }
}
