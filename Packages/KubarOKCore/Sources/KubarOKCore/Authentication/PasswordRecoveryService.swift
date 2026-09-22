import Foundation

public final class PasswordRecoveryService: Sendable {

    public static let shared = PasswordRecoveryService()

    private init() {}

    public func requestOTP(phone: String) async throws -> OTPExpiration {
        let response = try await perform(
            path: "auth/otp/request",
            request: OTPPhoneRequest(phone: phone),
            response: APIDataResponse<OTPExpiration>.self
        )
        return response.data
    }

    public func checkOTP(_ otp: String) async throws -> APIMessage {
        let response = try await perform(
            path: "auth/forgot-password/check-otp",
            request: OTPCodeRequest(otp: otp),
            response: APIDataResponse<APIMessage>.self
        )
        return response.data
    }

    public func resetPassword(otp: String, password: String) async throws {
        let body = try JSONEncoder().encode(
            ResetPasswordRequest(otp: otp, password: password)
        )
        _ = try await APIClient.shared.request(
            path: "auth/forgot-password/reset-password",
            method: "POST",
            body: body
        )
    }

    private func perform<Request: Encodable, Response: Decodable>(
        path: String,
        request: Request,
        response: Response.Type
    ) async throws -> Response {
        let body = try JSONEncoder().encode(request)
        let data = try await APIClient.shared.request(
            path: path,
            method: "POST",
            body: body
        )

        do {
            return try JSONDecoder().decode(response, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
