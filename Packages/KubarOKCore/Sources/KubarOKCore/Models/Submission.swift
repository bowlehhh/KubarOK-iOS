import Foundation

public enum SubmissionState: Int, Codable, Sendable, CaseIterable {
    case rejected = -1
    case draft = 0
    case open = 1
    case onHold = 2
    case done = 9
}

public enum SubmissionProgressState: Int, Codable, Sendable {
    case rejected = -1
    case open = 0
    case onHold = 1
    case accepted = 9
}

public struct CreateSubmissionRequest: Codable, Sendable {
    public let serviceId: Int
    public let submitterId: Int
    public let applicableId: Int
    public let submittedAt: String

    public init(serviceId: Int, submitterId: Int, applicableId: Int, submittedAt: String) {
        self.serviceId = serviceId
        self.submitterId = submitterId
        self.applicableId = applicableId
        self.submittedAt = submittedAt
    }

    enum CodingKeys: String, CodingKey {
        case serviceId = "service_id"
        case submitterId = "submitter_id"
        case applicableId = "applicable_id"
        case submittedAt = "submitted_at"
    }
}

public struct SubmissionRequisiteCheck: Codable, Sendable, Identifiable {
    public let id: Int
    public let isCompleted: Int
    public let submissionId: Int64
    public let requisiteId: Int
    public let requisite: ServiceRequisite?

    public init(id: Int, isCompleted: Int, submissionId: Int64, requisiteId: Int, requisite: ServiceRequisite?) {
        self.id = id
        self.isCompleted = isCompleted
        self.submissionId = submissionId
        self.requisiteId = requisiteId
        self.requisite = requisite
    }

    enum CodingKeys: String, CodingKey {
        case id
        case isCompleted = "is_completed"
        case submissionId = "submission_id"
        case requisiteId = "requisite_id"
        case requisite
    }
}

public struct SubmissionHistoryItem: Codable, Sendable, Identifiable {
    public let id: String
    public let state: SubmissionState
    public let serviceId: Int
    public let submitterId: Int
    public let applicantId: Int64
    public let submittedAt: String?
    public let createdAt: String?
    public let updatedAt: String?
    public let service: GovernmentService?
    public let progress: [SubmissionProgress]?

    public init(
        id: String,
        state: SubmissionState,
        serviceId: Int,
        submitterId: Int,
        applicantId: Int64,
        submittedAt: String?,
        createdAt: String?,
        updatedAt: String?,
        service: GovernmentService?,
        progress: [SubmissionProgress]?
    ) {
        self.id = id
        self.state = state
        self.serviceId = serviceId
        self.submitterId = submitterId
        self.applicantId = applicantId
        self.submittedAt = submittedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.service = service
        self.progress = progress
    }

    enum CodingKeys: String, CodingKey {
        case id
        case state
        case serviceId = "service_id"
        case submitterId = "submitter_id"
        case applicantId = "applicant_id"
        case submittedAt = "submitted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case service
        case progress
    }
}

public struct SubmissionProgress: Codable, Sendable, Equatable, Identifiable {
    public let id: Int
    public let state: SubmissionProgressState
    public let notes: String?
    public let dispatchedAt: String?
    public let validatedAt: String?
    public let submissionId: Int64
    public let procedureId: Int
    public let validatorId: Int?

    public init(
        id: Int,
        state: SubmissionProgressState,
        notes: String?,
        dispatchedAt: String?,
        validatedAt: String?,
        submissionId: Int64,
        procedureId: Int,
        validatorId: Int?
    ) {
        self.id = id
        self.state = state
        self.notes = notes
        self.dispatchedAt = dispatchedAt
        self.validatedAt = validatedAt
        self.submissionId = submissionId
        self.procedureId = procedureId
        self.validatorId = validatorId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case state
        case notes
        case dispatchedAt = "dispatched_at"
        case validatedAt = "validated_at"
        case submissionId = "submission_id"
        case procedureId = "procedure_id"
        case validatorId = "validator_id"
    }
}

public struct SubmissionValidationProcedure: Codable, Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let description: String?
    public let sequence: Int?
    public let serviceId: Int
    public let progress: SubmissionProgress?
    public let isLatest: Bool

    public init(
        id: Int,
        name: String,
        description: String?,
        sequence: Int?,
        serviceId: Int,
        progress: SubmissionProgress?,
        isLatest: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.sequence = sequence
        self.serviceId = serviceId
        self.progress = progress
        self.isLatest = isLatest
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case sequence
        case serviceId = "service_id"
        case progress
        case isLatest = "latest"
    }
}

public struct SubmissionDetail: Codable, Sendable {
    public let id: String
    public let state: SubmissionState
    public let serviceId: Int
    public let submitterId: Int
    public let applicantId: Int64
    public let submittedAt: String?
    public let requisiteChecks: [SubmissionRequisiteCheck]
    public let latestActivity: String?
    public let closedAt: String?
    public let createdAt: String?
    public let updatedAt: String?
    public let service: GovernmentService?
    public let validation: [SubmissionValidationProcedure]
    public let products: [SubmissionProduct]
    public let submissionFiles: [SubmissionUploadedFile]
    public let submissionData: [SubmissionStoredData]

    public init(
        id: String,
        state: SubmissionState,
        serviceId: Int,
        submitterId: Int,
        applicantId: Int64,
        submittedAt: String?,
        requisiteChecks: [SubmissionRequisiteCheck],
        latestActivity: String? = nil,
        closedAt: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        service: GovernmentService? = nil,
        validation: [SubmissionValidationProcedure] = [],
        products: [SubmissionProduct] = [],
        submissionFiles: [SubmissionUploadedFile] = [],
        submissionData: [SubmissionStoredData] = []
    ) {
        self.id = id
        self.state = state
        self.serviceId = serviceId
        self.submitterId = submitterId
        self.applicantId = applicantId
        self.submittedAt = submittedAt
        self.requisiteChecks = requisiteChecks
        self.latestActivity = latestActivity
        self.closedAt = closedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.service = service
        self.validation = validation
        self.products = products
        self.submissionFiles = submissionFiles
        self.submissionData = submissionData
    }

    enum CodingKeys: String, CodingKey {
        case id
        case state
        case serviceId = "service_id"
        case submitterId = "submitter_id"
        case applicantId = "applicant_id"
        case submittedAt = "submitted_at"
        case requisiteChecks = "requisite_check"
        case latestActivity = "latest_activity"
        case closedAt = "closed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case service
        case validation
        case products
        case submissionFiles = "submission_files"
        case submissionData = "submission_data"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        state = try container.decode(SubmissionState.self, forKey: .state)
        serviceId = try container.decode(Int.self, forKey: .serviceId)
        submitterId = try container.decode(Int.self, forKey: .submitterId)
        applicantId = try container.decode(Int64.self, forKey: .applicantId)
        submittedAt = try container.decodeIfPresent(String.self, forKey: .submittedAt)
        requisiteChecks = try container.decodeIfPresent([SubmissionRequisiteCheck].self, forKey: .requisiteChecks) ?? []
        latestActivity = try container.decodeIfPresent(String.self, forKey: .latestActivity)
        closedAt = try container.decodeIfPresent(String.self, forKey: .closedAt)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        service = try container.decodeIfPresent(GovernmentService.self, forKey: .service)
        validation = try container.decodeIfPresent([SubmissionValidationProcedure].self, forKey: .validation) ?? []
        products = try container.decodeIfPresent([SubmissionProduct].self, forKey: .products) ?? []
        submissionFiles = try container.decodeIfPresent([SubmissionUploadedFile].self, forKey: .submissionFiles) ?? []
        submissionData = try container.decodeIfPresent([SubmissionStoredData].self, forKey: .submissionData) ?? []
    }
}

public struct SubmissionProduct: Codable, Sendable, Identifiable {
    public let id: Int
    public let reference: String?
    public let issueDate: String?
    public let notes: String?
    public let submissionId: Int64?
    public let issuer: Bureau?
    public let file: RemoteFile?

    enum CodingKeys: String, CodingKey {
        case id
        case reference = "ref"
        case issueDate = "issue_date"
        case notes
        case submissionId = "submission_id"
        case issuer
        case file
    }
}

public struct SubmissionUploadedFile: Codable, Sendable, Identifiable {
    public let id: Int
    public let notes: String?
    public let submissionId: Int64
    public let documentId: Int
    public let fileId: Int?
    public let document: RequisiteDocument?
    public let file: RemoteFile?

    enum CodingKeys: String, CodingKey {
        case id
        case notes
        case submissionId = "submission_id"
        case documentId = "document_id"
        case fileId = "file_id"
        case document
        case file
    }
}

public struct SubmissionStoredData: Codable, Sendable, Identifiable {
    public let id: Int
    public let value: String
    public let submissionId: Int64
    public let inputId: Int
    public let input: RequisiteInput?

    enum CodingKeys: String, CodingKey {
        case id
        case value
        case submissionId = "submission_id"
        case inputId = "input_id"
        case input
    }
}

public struct SubmissionInputValue: Codable, Sendable, Equatable {
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public struct SubmissionInputsRequest: Codable, Sendable {
    public let requisiteInputs: [SubmissionInputValue]

    public init(requisiteInputs: [SubmissionInputValue]) {
        self.requisiteInputs = requisiteInputs
    }

    enum CodingKeys: String, CodingKey {
        case requisiteInputs = "requisites_inputs"
    }
}

public struct SubmissionAgreementRequest: Codable, Sendable {
    public let submissionRequisiteCheckId: Int

    public init(submissionRequisiteCheckId: Int) {
        self.submissionRequisiteCheckId = submissionRequisiteCheckId
    }

    enum CodingKeys: String, CodingKey {
        case submissionRequisiteCheckId = "submission_requisite_check_id"
    }
}

public struct SubmissionMessage: Codable, Sendable {
    public let message: String
}
