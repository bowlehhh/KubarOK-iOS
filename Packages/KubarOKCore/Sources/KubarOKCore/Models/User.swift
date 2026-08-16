import Foundation

public struct User: Codable, Sendable {

    public let id: Int
    public let name: String?
    public let email: String
    public let phone: String?
    public let username: String?
    public let avatar: String?
    public let isActivated: Bool
    public let activatedAt: String?
    public let createdAt: String?
    public let updatedAt: String?
    public let lastLogin: String?

    public init(
        id: Int,
        name: String?,
        email: String,
        phone: String?,
        username: String?,
        avatar: String?,
        isActivated: Bool,
        activatedAt: String?,
        createdAt: String?,
        updatedAt: String?,
        lastLogin: String?
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.username = username
        self.avatar = avatar
        self.isActivated = isActivated
        self.activatedAt = activatedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastLogin = lastLogin
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case username
        case avatar
        case isActivated = "is_activated"
        case activatedAt = "activated_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case lastLogin = "last_login"
    }
}
