import Foundation

public final class GovernmentServiceAPI: Sendable {

    public static let shared = GovernmentServiceAPI()

    private init() {}

    public func getServices(
        apiToken: String,
        bureauID: Int? = nil,
        page: Int? = nil
    ) async throws -> PaginatedResponse<GovernmentService> {
        var queryItems: [URLQueryItem] = []
        if let bureauID {
            queryItems.append(URLQueryItem(name: "bureau_id", value: String(bureauID)))
        }
        if let page {
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        }

        let data = try await APIClient.shared.request(
            path: "service",
            method: "GET",
            headers: CatalogAPIHeaders.authenticated(apiToken: apiToken),
            queryItems: queryItems
        )

        return try decode(PaginatedResponse<GovernmentService>.self, from: data)
    }

    public func getServiceDetail(
        apiToken: String,
        id: Int
    ) async throws -> GovernmentService {
        let data = try await APIClient.shared.request(
            path: "service/\(id)",
            method: "GET",
            headers: CatalogAPIHeaders.authenticated(apiToken: apiToken)
        )

        return try decode(APIDataResponse<GovernmentService>.self, from: data).data
    }

    public func searchServices(
        apiToken: String,
        name: String,
        bureauID: Int? = nil,
        orderBy: String = "name",
        page: Int? = nil
    ) async throws -> PaginatedResponse<GovernmentService> {
        var queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "orderBy", value: orderBy),
        ]
        if let bureauID {
            queryItems.append(URLQueryItem(name: "bureau_id", value: String(bureauID)))
        }
        if let page {
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        }

        let data = try await APIClient.shared.request(
            path: "service/search",
            method: "GET",
            headers: CatalogAPIHeaders.authenticated(apiToken: apiToken),
            queryItems: queryItems
        )
        return try decode(PaginatedResponse<GovernmentService>.self, from: data)
    }

    private func decode<Response: Decodable>(_ type: Response.Type, from data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
