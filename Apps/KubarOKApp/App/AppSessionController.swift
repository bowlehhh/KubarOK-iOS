#if canImport(SwiftUI)
import SwiftUI
import KubarOKCore

@MainActor
final class AppSessionController: ObservableObject {

    @Published private(set) var state: AppSessionState = .launching
    @Published private(set) var user: UserProfile?
    @Published private(set) var errorMessage: String?

    private let sessionManager: SessionManager

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    func restore() async {
        errorMessage = nil
        do {
            try await sessionManager.restoreSession()
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
        await synchronize()
    }

    func login(login: String, password: String) async throws {
        errorMessage = nil
        do {
            try await sessionManager.login(login: login, password: password)
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
            await synchronize()
            throw error
        }
        await synchronize()
    }

    func register(input: RegistrationInput) async throws {
        errorMessage = nil
        do {
            try await sessionManager.register(input: input)
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
            await synchronize()
            throw error
        }
        await synchronize()
    }

    func completeProfile(request: CitizenProfileRequest) async throws {
        errorMessage = nil
        do {
            try await sessionManager.completeProfile(request: request)
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
            await synchronize()
            throw error
        }
        await synchronize()
    }

    func logout() async {
        errorMessage = nil
        do {
            try await sessionManager.logout()
        } catch {
            errorMessage = UserFacingErrorMapper.message(for: error)
        }
        await synchronize()
    }

    private func synchronize() async {
        let snapshot = await sessionManager.snapshot()
        state = snapshot.state
        user = snapshot.user
    }
}
#endif
