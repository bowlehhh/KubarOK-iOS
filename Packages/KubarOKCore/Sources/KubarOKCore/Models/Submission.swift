import Foundation

public enum SubmissionState: Int, Codable, Sendable {
    case rejected = -1
    case draft = 0
    case open = 1
    case onHold = 2
    case done = 9
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

public struct SubmissionDetail: Codable, Sendable {
    public let id: String
    public let state: SubmissionState
    public let serviceId: Int
    public let submitterId: Int
    public let applicantId: Int64
    public let submittedAt: String?
    public let requisiteChecks: [SubmissionRequisiteCheck]

    enum CodingKeys: String, CodingKey {
        case id
        case state
        case serviceId = "service_id"
        case submitterId = "submitter_id"
        case applicantId = "applicant_id"
        case submittedAt = "submitted_at"
        case requisiteChecks = "requisite_check"
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
