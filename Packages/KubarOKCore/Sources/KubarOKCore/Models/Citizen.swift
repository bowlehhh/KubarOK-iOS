import Foundation

public struct Citizen: Codable, Sendable, Equatable {

    public let id: Int
    public let applicableId: String
    public let fullName: String
    public let birthPlace: String
    public let birthDate: String?
    public let sex: String
    public let citizenship: String
    public let kkNumber: String?
    public let createdAt: String?
    public let updatedAt: String?

    public init(
        id: Int,
        applicableId: String,
        fullName: String,
        birthPlace: String,
        birthDate: String?,
        sex: String,
        citizenship: String,
        kkNumber: String?,
        createdAt: String?,
        updatedAt: String?
    ) {
        self.id = id
        self.applicableId = applicableId
        self.fullName = fullName
        self.birthPlace = birthPlace
        self.birthDate = birthDate
        self.sex = sex
        self.citizenship = citizenship
        self.kkNumber = kkNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case applicableId = "applicable_id"
        case fullName = "full_name"
        case birthPlace = "birth_place"
        case birthDate = "birth_date"
        case sex
        case citizenship
        case kkNumber = "kk_number"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct CitizenResponse: Codable, Sendable {

    public let data: Citizen

    public init(data: Citizen) {
        self.data = data
    }
}
