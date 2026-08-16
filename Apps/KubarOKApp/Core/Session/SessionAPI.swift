import Foundation
import KubarOKCore

public protocol SessionAPI: Sendable {

    func login(login: String, password: String) async throws -> AuthSession
    func register(input: RegistrationInput) async throws
    func fetchUser(apiToken: String) async throws -> UserProfile
    func updateProfile(
        apiToken: String,
        request: CitizenProfileRequest
    ) async throws -> Citizen
    func logout(apiToken: String) async throws
}

public final class LiveSessionAPI: SessionAPI, Sendable {

    public init() {}

    public func login(login: String, password: String) async throws -> AuthSession {
        try await AuthService.shared.login(login: login, password: password)
    }

    public func register(input: RegistrationInput) async throws {
        _ = try await RegistrationService.shared.registerRaw(
            name: input.name,
            phone: input.phone,
            email: input.email,
            password: input.password
        )
    }

    public func fetchUser(apiToken: String) async throws -> UserProfile {
        try await UserService.shared.getUser(apiToken: apiToken)
    }

    public func updateProfile(
        apiToken: String,
        request: CitizenProfileRequest
    ) async throws -> Citizen {
        try await ProfileService.shared.updateProfile(
            apiToken: apiToken,
            request: request
        )
    }

    public func logout(apiToken: String) async throws {
        try await AuthService.shared.logout(apiToken: apiToken)
    }
}
