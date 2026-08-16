import Foundation

public final class ProfileService: Sendable {

    public static let shared = ProfileService()

    private init() {}

    public func getProfileRaw(apiToken: String) async throws -> Data {
        try await APIClient.shared.request(
            path: "profile",
            method: "GET",
            headers: ["api-token": apiToken]
        )
    }

    public func getProfile(apiToken: String) async throws -> Citizen {
        let data = try await getProfileRaw(apiToken: apiToken)

        do {
            return try JSONDecoder().decode(CitizenResponse.self, from: data).data
        } catch {
            throw APIError.decoding(error)
        }
    }

    public func updateProfile(
        apiToken: String,
        request: CitizenProfileRequest
    ) async throws -> Citizen {
        let body = try JSONEncoder().encode(request)
        let data = try await APIClient.shared.request(
            path: "profile",
            method: "PATCH",
            body: body,
            headers: ["api-token": apiToken]
        )

        do {
            return try JSONDecoder().decode(CitizenResponse.self, from: data).data
        } catch {
            throw APIError.decoding(error)
        }
    }
}
