import Foundation

public final class InformationService: Sendable {

    public static let shared = InformationService()

    private init() {}

    public func latest(
        apiToken: String,
        bureauID: Int? = nil,
        page: Int? = nil
    ) async throws -> PaginatedResponse<InformationItem> {
        var queryItems: [URLQueryItem] = []
        if let bureauID {
            queryItems.append(URLQueryItem(name: "bureau_id", value: String(bureauID)))
        }
        if let page {
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        }

        let data = try await APIClient.shared.request(
            path: "information/latest-info",
            method: "GET",
            headers: ["api-token": apiToken],
            queryItems: queryItems
        )
        return try decode(PaginatedResponse<InformationItem>.self, from: data)
    }

    public func lastAnnouncement(apiToken: String) async throws -> AnnouncementFile {
        let data = try await APIClient.shared.request(
            path: "information/last-announcement",
            method: "GET",
            headers: ["api-token": apiToken]
        )
        return try decode(APIDataResponse<AnnouncementFile>.self, from: data).data
    }

    private func decode<Response: Decodable>(_ type: Response.Type, from data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
