import Foundation

public struct LoginResponse: Codable, Sendable {

    public let data: LoginData

    public var session: AuthSession {
        AuthSession(apiToken: data.apiToken, user: data.user)
    }

    public struct LoginData: Codable, Sendable {

        public let id: Int
        public let name: String?
        public let email: String
        public let phone: String?
        public let username: String?
        public let avatar: String?
        public let isActivated: Bool
        public let apiToken: String
        public let activatedAt: String?
        public let createdAt: String?
        public let updatedAt: String?
        public let lastLogin: String?

        public var user: User {
            User(
                id: id,
                name: name,
                email: email,
                phone: phone,
                username: username,
                avatar: avatar,
                isActivated: isActivated,
                activatedAt: activatedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastLogin: lastLogin
            )
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case phone
            case username
            case avatar
            case isActivated = "is_activated"
            case apiToken = "api_token"
            case activatedAt = "activated_at"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case lastLogin = "last_login"
        }
    }
}
