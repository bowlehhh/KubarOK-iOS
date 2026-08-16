import Foundation

public struct CitizenProfileRequest: Codable, Sendable {

    public let applicableId: String
    public let name: String
    public let kkNumber: String?
    public let birthPlace: String
    public let birthDate: String
    public let sex: String
    public let citizenship: String

    public init(
        applicableId: String,
        name: String,
        kkNumber: String?,
        birthPlace: String,
        birthDate: String,
        sex: String,
        citizenship: String
    ) {
        self.applicableId = applicableId
        self.name = name
        self.kkNumber = kkNumber
        self.birthPlace = birthPlace
        self.birthDate = birthDate
        self.sex = sex
        self.citizenship = citizenship
    }

    enum CodingKeys: String, CodingKey {
        case applicableId = "applicable_id"
        case name
        case kkNumber = "kk_number"
        case birthPlace = "birth_place"
        case birthDate = "birth_date"
        case sex
        case citizenship
    }
}
