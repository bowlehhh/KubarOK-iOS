import Foundation

public struct Bureau: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let name: String
    public let shortName: String?
    public let address: String?
    public let phone: String?
    public let email: String?
    public let backgroundImage: String?
    public let thumbImage: String?
    public let servicesCount: Int?
    public let createdAt: String?
    public let updatedAt: String?

    public init(
        id: Int,
        name: String,
        shortName: String?,
        address: String?,
        phone: String?,
        email: String?,
        backgroundImage: String?,
        thumbImage: String?,
        servicesCount: Int?,
        createdAt: String?,
        updatedAt: String?
    ) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.address = address
        self.phone = phone
        self.email = email
        self.backgroundImage = backgroundImage
        self.thumbImage = thumbImage
        self.servicesCount = servicesCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortName = "short_name"
        case address
        case phone
        case email
        case backgroundImage = "background_image"
        case thumbImage = "thumb_image"
        case servicesCount = "services_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
