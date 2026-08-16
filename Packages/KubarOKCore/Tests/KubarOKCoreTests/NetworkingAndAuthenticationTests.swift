import Foundation
import Testing
@testable import KubarOKCore

@Test func loginRequestUsesBackendCodingKeys() throws {
    let request = LoginRequest(
        login: "user@example.com",
        password: "test-password",
        deviceToken: "device-token"
    )
    let data = try JSONEncoder().encode(request)
    let payload = try #require(
        JSONSerialization.jsonObject(with: data) as? [String: String]
    )

    #expect(payload["login"] == "user@example.com")
    #expect(payload["password"] == "test-password")
    #expect(payload["device_token"] == "device-token")
    #expect(payload["deviceToken"] == nil)
}

@Test func registrationRequestUsesBackendCodingKeys() throws {
    let request = RegistrationRequest(
        name: "Test User",
        phone: "08123456789",
        email: "user@example.com",
        password: "test-password",
        deviceToken: "device-token"
    )
    let data = try JSONEncoder().encode(request)
    let payload = try #require(
        JSONSerialization.jsonObject(with: data) as? [String: String]
    )

    #expect(payload["name"] == "Test User")
    #expect(payload["phone"] == "08123456789")
    #expect(payload["email"] == "user@example.com")
    #expect(payload["password"] == "test-password")
    #expect(payload["device_token"] == "device-token")
    #expect(payload["deviceToken"] == nil)
}

@Test func apiClientBuildsPathsFromTheConfiguredBaseURL() {
    let rootURL = APIClient.shared.url(for: "")
    let loginURL = APIClient.shared.url(for: "auth/login")

    #expect(rootURL == APIConfig.baseURL)
    #expect(loginURL.absoluteString == "https://kubarok.kutaibaratkab.go.id/v1/auth/login")
}

@Test func logoutUsesTheVerifiedBackendPath() {
    let logoutURL = APIClient.shared.url(for: "auth/logout")

    #expect(logoutURL.absoluteString == "https://kubarok.kutaibaratkab.go.id/v1/auth/logout")
}

@Test func httpErrorPreservesStatusAndResponseBody() {
    let error = APIError.httpError(
        statusCode: 401,
        body: #"{"message":"Unauthorized"}"#
    )

    #expect(error.errorDescription?.contains("401") == true)
    #expect(error.errorDescription?.contains("Unauthorized") == true)
}

@Test func loginResponseExtractsTokenAndMapsToAuthSession() throws {
    let data = Data(
        #"""
        {
          "data": {
            "activated_at": "2026-08-14 19:00:45",
            "api_token": "dummy-token-for-test",
            "avatar": null,
            "created_at": "2026-08-14 19:00:45",
            "email": "user@example.com",
            "id": 1506,
            "is_activated": true,
            "last_login": "2026-08-14 19:00:47",
            "name": "Test User",
            "phone": "081234567890",
            "updated_at": "2026-08-14 19:00:47",
            "username": "testuser"
          }
        }
        """#.utf8
    )

    let response = try JSONDecoder().decode(LoginResponse.self, from: data)
    let session = response.session

    #expect(session.apiToken == "dummy-token-for-test")
    #expect(session.user.id == 1506)
    #expect(session.user.name == "Test User")
    #expect(session.user.email == "user@example.com")
    #expect(session.user.phone == "081234567890")
    #expect(session.user.username == "testuser")
    #expect(session.user.avatar == nil)
    #expect(session.user.isActivated)
    #expect(session.user.activatedAt == "2026-08-14 19:00:45")
    #expect(session.user.lastLogin == "2026-08-14 19:00:47")
}

@Test func userDecodesBackendSnakeCaseKeys() throws {
    let data = Data(
        #"""
        {
          "activated_at": null,
          "avatar": "https://example.com/avatar.png",
          "created_at": "2026-08-14 19:00:45",
          "email": "user@example.com",
          "id": 1506,
          "is_activated": false,
          "last_login": null,
          "name": null,
          "phone": null,
          "updated_at": "2026-08-14 19:00:47",
          "username": null
        }
        """#.utf8
    )

    let user = try JSONDecoder().decode(User.self, from: data)

    #expect(user.id == 1506)
    #expect(user.name == nil)
    #expect(user.avatar == "https://example.com/avatar.png")
    #expect(user.isActivated == false)
    #expect(user.createdAt == "2026-08-14 19:00:45")
    #expect(user.updatedAt == "2026-08-14 19:00:47")
    #expect(user.activatedAt == nil)
    #expect(user.lastLogin == nil)
}
