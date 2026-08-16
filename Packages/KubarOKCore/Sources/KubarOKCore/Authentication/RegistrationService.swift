import Foundation

public final class RegistrationService: Sendable {

    public static let shared = RegistrationService()

    private init() {}

    public func registerRaw(
        name: String,
        phone: String,
        email: String,
        password: String,
        deviceToken: String = ""
    ) async throws -> Data {
        let registrationRequest = RegistrationRequest(
            name: name,
            phone: phone,
            email: email,
            password: password,
            deviceToken: deviceToken
        )
        let data = try JSONEncoder().encode(registrationRequest)

        return try await APIClient.shared.request(
            path: "auth/registration",
            method: "POST",
            body: data
        )
    }
}
