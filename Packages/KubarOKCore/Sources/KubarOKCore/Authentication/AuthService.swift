import Foundation

public final class AuthService: Sendable {

    public static let shared = AuthService()

    private init() {}

    public func loginRaw(
        login: String,
        password: String,
        deviceToken: String = ""
    ) async throws -> Data {
        let loginRequest = LoginRequest(
            login: login,
            password: password,
            deviceToken: deviceToken
        )
        let data = try JSONEncoder().encode(loginRequest)

        return try await APIClient.shared.request(
            path: "auth/login",
            method: "POST",
            body: data
        )
    }

    public func login(
        login: String,
        password: String,
        deviceToken: String = ""
    ) async throws -> AuthSession {
        let data = try await loginRaw(
            login: login,
            password: password,
            deviceToken: deviceToken
        )

        do {
            return try JSONDecoder().decode(LoginResponse.self, from: data).session
        } catch {
            throw APIError.decoding(error)
        }
    }

    public func logout(apiToken: String) async throws {
        _ = try await APIClient.shared.request(
            path: "auth/logout",
            method: "POST",
            headers: ["api-token": apiToken]
        )
    }
}
