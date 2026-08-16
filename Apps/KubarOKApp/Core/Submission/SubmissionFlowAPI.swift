import Foundation
import KubarOKCore

public protocol SubmissionFlowAPI: Sendable {
    func create(apiToken: String, request: CreateSubmissionRequest) async throws -> [SubmissionRequisiteCheck]
    func agreement(apiToken: String, submissionID: Int64, requisiteID: Int, checkID: Int) async throws -> [SubmissionRequisiteCheck]
    func inputs(apiToken: String, submissionID: Int64, requisiteID: Int, values: [SubmissionInputValue]) async throws -> [SubmissionRequisiteCheck]
    func file(apiToken: String, submissionID: Int64, requisiteID: Int, documentID: Int, file: MultipartFile) async throws -> [SubmissionRequisiteCheck]
    func send(apiToken: String, submissionID: Int64) async throws -> SubmissionMessage
}

public final class LiveSubmissionFlowAPI: SubmissionFlowAPI, Sendable {
    public init() {}
    public func create(apiToken: String, request: CreateSubmissionRequest) async throws -> [SubmissionRequisiteCheck] { try await SubmissionAPI.shared.create(apiToken: apiToken, request: request) }
    public func agreement(apiToken: String, submissionID: Int64, requisiteID: Int, checkID: Int) async throws -> [SubmissionRequisiteCheck] { try await SubmissionAPI.shared.submitAgreement(apiToken: apiToken, submissionID: submissionID, requisiteID: requisiteID, request: SubmissionAgreementRequest(submissionRequisiteCheckId: checkID)) }
    public func inputs(apiToken: String, submissionID: Int64, requisiteID: Int, values: [SubmissionInputValue]) async throws -> [SubmissionRequisiteCheck] { try await SubmissionAPI.shared.submitInputs(apiToken: apiToken, submissionID: submissionID, requisiteID: requisiteID, request: SubmissionInputsRequest(requisiteInputs: values)) }
    public func file(apiToken: String, submissionID: Int64, requisiteID: Int, documentID: Int, file: MultipartFile) async throws -> [SubmissionRequisiteCheck] { try await SubmissionAPI.shared.submitFile(apiToken: apiToken, submissionID: submissionID, requisiteID: requisiteID, documentID: documentID, file: file) }
    public func send(apiToken: String, submissionID: Int64) async throws -> SubmissionMessage { try await SubmissionAPI.shared.sendSubmit(apiToken: apiToken, submissionID: submissionID) }
}
