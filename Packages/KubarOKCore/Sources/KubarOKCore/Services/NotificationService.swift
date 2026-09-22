import Foundation

public final class NotificationService: Sendable {

    public static let shared = NotificationService()

    private init() {}

    public func list(
        apiToken: String,
        page: Int? = nil
    ) async throws -> PaginatedResponse<UserNotification> {
        let queryItems = page.map {
            [URLQueryItem(name: "page", value: String($0))]
        } ?? []
        let data = try await request(
            path: "notification",
            method: "GET",
            apiToken: apiToken,
            queryItems: queryItems
        )
        return try decode(PaginatedResponse<UserNotification>.self, from: data)
    }

    public func unreadCount(apiToken: String) async throws -> Int {
        let data = try await request(
            path: "notification/total-unread",
            method: "GET",
            apiToken: apiToken
        )
        return try decode(APIDataResponse<Int>.self, from: data).data
    }

    /// The backend marks a notification as read when its detail is requested.
    public func detail(apiToken: String, id: Int) async throws -> UserNotification {
        let data = try await request(
            path: "notification/\(id)",
            method: "GET",
            apiToken: apiToken
        )
        return try decode(APIDataResponse<UserNotification>.self, from: data).data
    }

    public func markAllRead(apiToken: String) async throws -> APIMessage {
        try await message(
            path: "notification/mark-all-read",
            method: "POST",
            apiToken: apiToken
        )
    }

    public func delete(apiToken: String, id: Int) async throws -> APIMessage {
        try await message(
            path: "notification/\(id)/delete",
            method: "DELETE",
            apiToken: apiToken
        )
    }

    public func deleteAll(apiToken: String) async throws -> APIMessage {
        try await message(
            path: "notification/delete-all",
            method: "DELETE",
            apiToken: apiToken
        )
    }

    private func message(path: String, method: String, apiToken: String) async throws -> APIMessage {
        let data = try await request(path: path, method: method, apiToken: apiToken)
        return try decode(APIDataResponse<APIMessage>.self, from: data).data
    }

    private func request(
        path: String,
        method: String,
        apiToken: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> Data {
        try await APIClient.shared.request(
            path: path,
            method: method,
            headers: ["api-token": apiToken],
            queryItems: queryItems
        )
    }

    private func decode<Response: Decodable>(_ type: Response.Type, from data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
