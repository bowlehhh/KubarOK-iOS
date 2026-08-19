import Foundation

public final class SubmissionAPI: Sendable {
    public static let shared = SubmissionAPI()
    private init() {}

    public func list(
        apiToken: String,
        state: SubmissionState? = nil,
        serviceID: Int? = nil,
        page: Int? = nil
    ) async throws -> PaginatedResponse<SubmissionHistoryItem> {
        var queryItems: [URLQueryItem] = []
        if let state {
            queryItems.append(URLQueryItem(name: "state", value: String(state.rawValue)))
        }
        if let serviceID {
            queryItems.append(URLQueryItem(name: "service_id", value: String(serviceID)))
        }
        if let page {
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        }

        let response = try await APIClient.shared.request(
            path: "submission",
            method: "GET",
            headers: CatalogAPIHeaders.authenticated(apiToken: apiToken),
            queryItems: queryItems
        )
        return try decode(PaginatedResponse<SubmissionHistoryItem>.self, from: response)
    }

    public func create(apiToken: String, request: CreateSubmissionRequest) async throws -> [SubmissionRequisiteCheck] {
        let data = try JSONEncoder().encode(request)
        let response = try await APIClient.shared.request(path: "submission/store", method: "POST", body: data, headers: CatalogAPIHeaders.authenticated(apiToken: apiToken))
        return try decode(APIDataResponse<[SubmissionRequisiteCheck]>.self, from: response).data
    }

    public func detail(apiToken: String, submissionID: Int64) async throws -> SubmissionDetail {
        let response = try await APIClient.shared.request(path: "submission/\(submissionID)", method: "GET", headers: CatalogAPIHeaders.authenticated(apiToken: apiToken))
        return try decode(APIDataResponse<SubmissionDetail>.self, from: response).data
    }

    public func submitAgreement(apiToken: String, submissionID: Int64, requisiteID: Int, request: SubmissionAgreementRequest) async throws -> [SubmissionRequisiteCheck] {
        try await postRequisite(apiToken: apiToken, path: "submission/\(submissionID)/submit-agreement/\(requisiteID)", body: try JSONEncoder().encode(request))
    }

    public func submitInputs(apiToken: String, submissionID: Int64, requisiteID: Int, request: SubmissionInputsRequest) async throws -> [SubmissionRequisiteCheck] {
        try await postRequisite(apiToken: apiToken, path: "submission/\(submissionID)/submit-inputs/\(requisiteID)", body: try JSONEncoder().encode(request))
    }

    public func submitFile(apiToken: String, submissionID: Int64, requisiteID: Int, documentID: Int, file: MultipartFile) async throws -> [SubmissionRequisiteCheck] {
        let multipart = MultipartFormData.make(fields: ["document_id": String(documentID)], files: [file])
        let response = try await APIClient.shared.request(path: "submission/\(submissionID)/submit-files/\(requisiteID)", method: "POST", body: multipart.data, headers: CatalogAPIHeaders.authenticated(apiToken: apiToken), contentType: multipart.contentType)
        return try decode(APIDataResponse<[SubmissionRequisiteCheck]>.self, from: response).data
    }

    public func sendSubmit(apiToken: String, submissionID: Int64) async throws -> SubmissionMessage {
        let response = try await APIClient.shared.request(path: "submission/\(submissionID)/send-submit", method: "POST", headers: CatalogAPIHeaders.authenticated(apiToken: apiToken))
        return try decode(APIDataResponse<SubmissionMessage>.self, from: response).data
    }

    private func postRequisite(apiToken: String, path: String, body: Data) async throws -> [SubmissionRequisiteCheck] {
        let response = try await APIClient.shared.request(path: path, method: "POST", body: body, headers: CatalogAPIHeaders.authenticated(apiToken: apiToken))
        return try decode(APIDataResponse<[SubmissionRequisiteCheck]>.self, from: response).data
    }

    private func decode<Response: Decodable>(_ type: Response.Type, from data: Data) throws -> Response {
        do { return try JSONDecoder().decode(type, from: data) }
        catch { throw APIError.decoding(error) }
    }
}
