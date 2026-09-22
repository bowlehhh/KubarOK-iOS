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

    public func updateUser(
        apiToken: String,
        request: UpdateUserRequest
    ) async throws -> UserProfile {
        let body = try JSONEncoder().encode(request)
        let data = try await APIClient.shared.request(
            path: "user",
            method: "PATCH",
            body: body,
            headers: ["api-token": apiToken]
        )
        return try decodeProfile(from: data)
    }

    public func verifyPhone(apiToken: String, otp: String) async throws -> UserProfile {
        let body = try JSONEncoder().encode(OTPCodeRequest(otp: otp))
        let data = try await APIClient.shared.request(
            path: "user/verify-phone",
            method: "POST",
            body: body,
            headers: ["api-token": apiToken]
        )
        return try decodeProfile(from: data)
    }

    private func decodeProfile(from data: Data) throws -> UserProfile {
        do {
            return try JSONDecoder().decode(UserProfileResponse.self, from: data).data
        } catch {
            throw APIError.decoding(error)
        }
    }
}
