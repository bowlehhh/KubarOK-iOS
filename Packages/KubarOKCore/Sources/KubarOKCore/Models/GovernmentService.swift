import Foundation

public struct GovernmentService: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let name: String
    public let description: String?
    public let isEnabled: Int
    public let sortOrder: Int
    public let bureauId: Int
    public let externalLink: String?
    public let isExternal: Int
    public let bureau: Bureau?
    public let proceduresCount: Int?
    public let requisitesCount: Int?
    public let procedures: [ServiceProcedure]?
    public let requisites: [ServiceRequisite]?
    public let createdAt: String?
    public let updatedAt: String?

    public init(
        id: Int,
        name: String,
        description: String?,
        isEnabled: Int,
        sortOrder: Int,
        bureauId: Int,
        externalLink: String?,
        isExternal: Int,
        bureau: Bureau?,
        proceduresCount: Int?,
        requisitesCount: Int?,
        procedures: [ServiceProcedure]?,
        requisites: [ServiceRequisite]?,
        createdAt: String?,
        updatedAt: String?
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.isEnabled = isEnabled
        self.sortOrder = sortOrder
        self.bureauId = bureauId
        self.externalLink = externalLink
        self.isExternal = isExternal
        self.bureau = bureau
        self.proceduresCount = proceduresCount
        self.requisitesCount = requisitesCount
        self.procedures = procedures
        self.requisites = requisites
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case isEnabled = "is_enable"
        case sortOrder = "sort_order"
        case bureauId = "bureau_id"
        case externalLink = "external_link"
        case isExternal = "is_external"
        case bureau
        case proceduresCount = "procedures_count"
        case requisitesCount = "requisites_count"
        case procedures
        case requisites
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct ServiceProcedure: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let name: String
    public let description: String?
    public let sequence: Int?
    public let serviceId: Int

    public init(id: Int, name: String, description: String?, sequence: Int?, serviceId: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.sequence = sequence
        self.serviceId = serviceId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case sequence
        case serviceId = "service_id"
    }
}

public struct ServiceRequisite: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let serviceId: Int
    public let documentTypeId: Int?
    public let title: String
    public let description: String?
    public let isRequired: Int
    public let kind: Int
    public let sequence: Int
    public let externalLink: String?
    public let documents: [RequisiteDocument]?
    public let inputs: [RequisiteInput]?

    public init(
        id: Int,
        serviceId: Int,
        documentTypeId: Int?,
        title: String,
        description: String?,
        isRequired: Int,
        kind: Int,
        sequence: Int,
        externalLink: String?,
        documents: [RequisiteDocument]?,
        inputs: [RequisiteInput]?
    ) {
        self.id = id
        self.serviceId = serviceId
        self.documentTypeId = documentTypeId
        self.title = title
        self.description = description
        self.isRequired = isRequired
        self.kind = kind
        self.sequence = sequence
        self.externalLink = externalLink
        self.documents = documents
        self.inputs = inputs
    }

    enum CodingKeys: String, CodingKey {
        case id
        case serviceId = "service_id"
        case documentTypeId = "doc_type_id"
        case title
        case description
        case isRequired = "is_required"
        case kind
        case sequence
        case externalLink = "external_link"
        case documents
        case inputs
    }
}

public struct RequisiteDocument: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let requisiteId: Int
    public let documentTypeId: Int
    public let comment: String?

    public init(id: Int, requisiteId: Int, documentTypeId: Int, comment: String?) {
        self.id = id
        self.requisiteId = requisiteId
        self.documentTypeId = documentTypeId
        self.comment = comment
    }

    enum CodingKeys: String, CodingKey {
        case id
        case requisiteId = "requisite_id"
        case documentTypeId = "doc_type_id"
        case comment
    }
}

public struct RequisiteInput: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let label: String
    public let key: String
    public let type: String
    public let comment: String?

    public init(id: Int, label: String, key: String, type: String, comment: String?) {
        self.id = id
        self.label = label
        self.key = key
        self.type = type
        self.comment = comment
    }
}
