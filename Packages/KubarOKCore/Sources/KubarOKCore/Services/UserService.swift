import Foundation

public final class UserService: Sendable {

    public static let shared = UserService()

    private init() {}

    public func getUser(apiToken: String) async throws -> UserProfile {
        let data = try await APIClient.shared.request(
            path: "user",
            method: "GET",
            headers: ["api-token": apiToken]
        )

        do {
            return try JSONDecoder().decode(UserProfileResponse.self, from: data).data
        } catch {
            throw APIError.decoding(error)
        }
    }
}
