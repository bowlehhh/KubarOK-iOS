import Testing
import KubarOKAppCore
import KubarOKCore

@Test func restoreWithoutTokenIsUnauthenticated() async throws {
    let store = InMemoryTokenStore()
    let manager = SessionManager(tokenStore: store, api: StubSessionAPI(user: nil))

    try await manager.restoreSession()

    #expect(await manager.snapshot().state == .unauthenticated)
}

@Test func validTokenWithoutCitizenNeedsProfile() async throws {
    let store = InMemoryTokenStore(token: "stored-token")
    let manager = SessionManager(
        tokenStore: store,
        api: StubSessionAPI(user: makeUser(citizen: nil))
    )

    try await manager.restoreSession()

    #expect(await manager.snapshot().state == .authenticatedNeedsProfile)
}

@Test func validTokenWithCitizenIsAuthenticated() async throws {
    let store = InMemoryTokenStore(token: "stored-token")
    let manager = SessionManager(
        tokenStore: store,
        api: StubSessionAPI(user: makeUser(citizen: makeCitizen()))
    )

    try await manager.restoreSession()

    #expect(await manager.snapshot().state == .authenticated)
}

@Test func logoutClearsLocalSessionAndToken() async throws {
    let store = InMemoryTokenStore(token: "stored-token")
    let manager = SessionManager(
        tokenStore: store,
        api: StubSessionAPI(user: makeUser(citizen: makeCitizen()))
    )

    try await manager.logout()

    #expect(await store.readToken() == nil)
    #expect(await manager.snapshot().state == .unauthenticated)
}

@Test func loginFailureDoesNotSaveToken() async throws {
    let store = InMemoryTokenStore()
    let manager = SessionManager(
        tokenStore: store,
        api: StubSessionAPI(user: nil, failsLogin: true)
    )

    await #expect(throws: StubSessionAPIError.loginFailed) {
        try await manager.login(login: "user@example.com", password: "password")
    }

    #expect(await store.readToken() == nil)
}

@Test func registrationInputValidatesPasswordConfirmation() {
    let input = RegistrationInput(
        name: "Test User",
        email: "user@example.com",
        phone: "08123456789",
        password: "password",
        confirmationPassword: "different"
    )

    #expect(input.validationError == .passwordsDoNotMatch)
}

private struct StubSessionAPI: SessionAPI {

    let user: UserProfile?
    let failsLogin: Bool

    init(user: UserProfile?, failsLogin: Bool = false) {
        self.user = user
        self.failsLogin = failsLogin
    }

    func login(login: String, password: String) async throws -> AuthSession {
        if failsLogin {
            throw StubSessionAPIError.loginFailed
        }
        return AuthSession(apiToken: "test-token", user: makeLoginUser())
    }

    func register(input: RegistrationInput) async throws {}

    func fetchUser(apiToken: String) async throws -> UserProfile {
        guard let user else {
            throw StubSessionAPIError.userUnavailable
        }
        return user
    }

    func updateProfile(
        apiToken: String,
        request: CitizenProfileRequest
    ) async throws -> Citizen {
        makeCitizen()
    }

    func logout(apiToken: String) async throws {}
}

private enum StubSessionAPIError: Error, Equatable {

    case loginFailed
    case userUnavailable
}

private func makeLoginUser() -> User {
    User(
        id: 1,
        name: "Test User",
        email: "user@example.com",
        phone: nil,
        username: nil,
        avatar: nil,
        isActivated: true,
        activatedAt: nil,
        createdAt: nil,
        updatedAt: nil,
        lastLogin: nil
    )
}

private func makeUser(citizen: Citizen?) -> UserProfile {
    UserProfile(
        id: 1,
        name: "Test User",
        email: "user@example.com",
        isActivated: true,
        activatedAt: nil,
        username: nil,
        phone: "08123456789",
        citizen: citizen,
        createdAt: nil,
        updatedAt: nil
    )
}

private func makeCitizen() -> Citizen {
    Citizen(
        id: 1,
        applicableId: "PASSPORT-123",
        fullName: "Test Citizen",
        birthPlace: "Sendawar",
        birthDate: "1990-01-01",
        sex: "M",
        citizenship: "WNA",
        kkNumber: nil,
        createdAt: nil,
        updatedAt: nil
    )
}
