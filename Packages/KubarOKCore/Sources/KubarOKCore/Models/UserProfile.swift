import Foundation

public struct UserProfile: Codable, Sendable {

    public let id: Int
    public let name: String?
    public let email: String
    public let isActivated: Bool
    public let activatedAt: String?
    public let username: String?
    public let phone: String?
    public let citizen: Citizen?
    public let createdAt: String?
    public let updatedAt: String?

    public init(
        id: Int,
        name: String?,
        email: String,
        isActivated: Bool,
        activatedAt: String?,
        username: String?,
        phone: String?,
        citizen: Citizen?,
        createdAt: String?,
        updatedAt: String?
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.isActivated = isActivated
        self.activatedAt = activatedAt
        self.username = username
        self.phone = phone
        self.citizen = citizen
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case isActivated = "is_activated"
        case activatedAt = "activated_at"
        case username
        case phone
        case citizen
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct UserProfileResponse: Codable, Sendable {

    public let data: UserProfile

    public init(data: UserProfile) {
        self.data = data
    }
}
