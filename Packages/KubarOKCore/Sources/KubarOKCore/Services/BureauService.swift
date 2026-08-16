import Foundation

enum CatalogAPIHeaders {

    static func authenticated(apiToken: String) -> [String: String] {
        ["api-token": apiToken]
    }
}

public final class BureauService: Sendable {

    public static let shared = BureauService()

    private init() {}

    public func getBureaus(
        apiToken: String,
        page: Int? = nil
    ) async throws -> PaginatedResponse<Bureau> {
        let data = try await APIClient.shared.request(
            path: "bureau",
            method: "GET",
            headers: CatalogAPIHeaders.authenticated(apiToken: apiToken),
            queryItems: page.map { [URLQueryItem(name: "page", value: String($0))] } ?? []
        )

        return try decode(PaginatedResponse<Bureau>.self, from: data)
    }

    public func getBureau(apiToken: String, id: Int) async throws -> Bureau {
        let data = try await APIClient.shared.request(
            path: "bureau/\(id)",
            method: "GET",
            headers: CatalogAPIHeaders.authenticated(apiToken: apiToken)
        )

        return try decode(APIDataResponse<Bureau>.self, from: data).data
    }

    private func decode<Response: Decodable>(_ type: Response.Type, from data: Data) throws -> Response {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
