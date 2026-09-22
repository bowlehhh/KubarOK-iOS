import Foundation
import KubarOKCore

public protocol SubmissionTrackingAPI: Sendable {
    func fetchHistory(
        apiToken: String,
        state: SubmissionState?,
        serviceID: Int?,
        page: Int?
    ) async throws -> PaginatedResponse<SubmissionHistoryItem>
    func fetchDetail(apiToken: String, submissionID: Int64) async throws -> SubmissionDetail
    func deleteSubmission(apiToken: String, submissionID: Int64) async throws -> APIMessage
}

public final class LiveSubmissionTrackingAPI: SubmissionTrackingAPI, Sendable {
    public init() {}

    public func fetchHistory(
        apiToken: String,
        state: SubmissionState?,
        serviceID: Int?,
        page: Int?
    ) async throws -> PaginatedResponse<SubmissionHistoryItem> {
        try await SubmissionAPI.shared.list(
            apiToken: apiToken,
            state: state,
            serviceID: serviceID,
            page: page
        )
    }

    public func fetchDetail(apiToken: String, submissionID: Int64) async throws -> SubmissionDetail {
        try await SubmissionAPI.shared.detail(apiToken: apiToken, submissionID: submissionID)
    }

    public func deleteSubmission(apiToken: String, submissionID: Int64) async throws -> APIMessage {
        try await SubmissionAPI.shared.deleteSubmission(apiToken: apiToken, submissionID: submissionID)
    }
}
