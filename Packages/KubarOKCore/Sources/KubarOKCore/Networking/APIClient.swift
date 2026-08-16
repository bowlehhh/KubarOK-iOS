import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class APIClient: Sendable {

    public static let shared = APIClient()

    private init() {}

    public func testConnection() async throws -> String {
        let data = try await request(path: "", method: "GET")

        guard let result = String(data: data, encoding: .utf8) else {
            throw APIError.invalidData
        }

        return result
    }

    public func request(
        path: String,
        method: String,
        body: Data? = nil,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        contentType: String? = nil
    ) async throws -> Data {
        let url = url(for: path, queryItems: queryItems)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if body != nil {
            request.setValue(
                contentType ?? "application/json",
                forHTTPHeaderField: "Content-Type"
            )
        }

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw APIError.httpError(
                    statusCode: httpResponse.statusCode,
                    body: String(data: data, encoding: .utf8)
                )
            }

            return data
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.network(error)
        }
    }

    func url(for path: String) -> URL {
        url(for: path, queryItems: [])
    }

    func url(for path: String, queryItems: [URLQueryItem]) -> URL {
        guard !path.isEmpty else {
            return APIConfig.baseURL
        }

        let pathURL = APIConfig.baseURL.appendingPathComponent(path)
        guard !queryItems.isEmpty else {
            return pathURL
        }

        var components = URLComponents(url: pathURL, resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems
        return components?.url ?? pathURL
    }
}
