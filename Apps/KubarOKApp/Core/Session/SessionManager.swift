import Foundation
import KubarOKCore

public enum AppSessionState: Sendable, Equatable {

    case launching
    case unauthenticated
    case authenticatedNeedsProfile
    case authenticated
}

public struct AppSessionSnapshot: Sendable {

    public let state: AppSessionState
    public let user: UserProfile?

    public init(state: AppSessionState, user: UserProfile?) {
        self.state = state
        self.user = user
    }
}

public enum SessionError: Error, Equatable {

    case missingSession
    case profileNotLinked
    case registrationValidation(RegistrationValidationError)
    case remoteLogoutFailed
}

public actor SessionManager {

    private let tokenStore: any TokenStore
    private let api: any SessionAPI
    private var state: AppSessionState = .launching
    private var user: UserProfile?

    public init(tokenStore: any TokenStore, api: any SessionAPI) {
        self.tokenStore = tokenStore
        self.api = api
    }

    public func snapshot() -> AppSessionSnapshot {
        AppSessionSnapshot(state: state, user: user)
    }

    public func restoreSession() async throws {
        guard let token = try await tokenStore.readToken() else {
            transition(to: nil)
            return
        }

        do {
            let user = try await api.fetchUser(apiToken: token)
            transition(to: user)
        } catch {
            if isInvalidToken(error) {
                try? await tokenStore.deleteToken()
            }
            transition(to: nil)
            throw error
        }
    }

    public func login(login: String, password: String) async throws {
        let session = try await api.login(login: login, password: password)
        try await establishSession(apiToken: session.apiToken)
    }

    public func register(input: RegistrationInput) async throws {
        if let validationError = input.validationError {
            throw SessionError.registrationValidation(validationError)
        }

        try await api.register(input: input)
        let session = try await api.login(login: input.email, password: input.password)
        try await establishSession(apiToken: session.apiToken)
    }

    public func completeProfile(request: CitizenProfileRequest) async throws {
        guard let token = try await tokenStore.readToken() else {
            transition(to: nil)
            throw SessionError.missingSession
        }

        _ = try await api.updateProfile(apiToken: token, request: request)
        let updatedUser = try await api.fetchUser(apiToken: token)
        guard updatedUser.citizen != nil else {
            transition(to: updatedUser)
            throw SessionError.profileNotLinked
        }
        transition(to: updatedUser)
    }

    public func logout() async throws {
        guard let token = try await tokenStore.readToken() else {
            transition(to: nil)
            return
        }

        do {
            try await api.logout(apiToken: token)
        } catch {
            try await clearLocalSession()
            throw SessionError.remoteLogoutFailed
        }

        try await clearLocalSession()
    }

    private func establishSession(apiToken: String) async throws {
        try await tokenStore.save(token: apiToken)

        do {
            let user = try await api.fetchUser(apiToken: apiToken)
            transition(to: user)
        } catch {
            try? await tokenStore.deleteToken()
            transition(to: nil)
            throw error
        }
    }

    private func clearLocalSession() async throws {
        try await tokenStore.deleteToken()
        transition(to: nil)
    }

    private func transition(to user: UserProfile?) {
        self.user = user
        guard let user else {
            state = .unauthenticated
            return
        }
        state = user.citizen == nil ? .authenticatedNeedsProfile : .authenticated
    }

    private func isInvalidToken(_ error: Error) -> Bool {
        guard case let APIError.httpError(statusCode, _) = error else {
            return false
        }
        return statusCode == 401 || statusCode == 403
    }
}
