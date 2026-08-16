import Foundation
import KubarOKCore

@main
struct KubarOKAuthTest {

    static func main() async {
        let environment = ProcessInfo.processInfo.environment

        guard let login = environment["KUBAROK_LOGIN"],
              !login.isEmpty,
              let password = environment["KUBAROK_PASSWORD"],
              !password.isEmpty else {
            print("Credential belum diberikan.")
            print("")
            print("Gunakan environment:")
            print("KUBAROK_LOGIN")
            print("KUBAROK_PASSWORD")
            return
        }

        let deviceToken = environment["KUBAROK_DEVICE_TOKEN"] ?? ""

        do {
            let data = try await AuthService.shared.loginRaw(
                login: login,
                password: password,
                deviceToken: deviceToken
            )

            guard let response = String(data: data, encoding: .utf8) else {
                print("LOGIN GAGAL")
                print("")
                print("Response backend tidak dapat dibaca sebagai UTF-8.")
                return
            }

            print("LOGIN BERHASIL")
            print("")
            print("Backend Response:")
            print(redactingSensitiveValues(in: response))
        } catch let error as APIError {
            print("LOGIN GAGAL")
            print("")

            switch error {
            case .httpError(let statusCode, let body):
                print("HTTP Status:")
                print(statusCode)
                print("")
                print("Backend Response:")
                print(redactingSensitiveValues(in: body ?? "(empty response)"))
            default:
                print(error.localizedDescription)
            }
        } catch {
            print("LOGIN GAGAL")
            print("")
            print(error.localizedDescription)
        }
    }

    private static func redactingSensitiveValues(in response: String) -> String {
        guard let data = response.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data),
              JSONSerialization.isValidJSONObject(object),
              let redactedData = try? JSONSerialization.data(
                  withJSONObject: redacted(object),
                  options: [.prettyPrinted, .sortedKeys]
              ),
              let redactedResponse = String(data: redactedData, encoding: .utf8) else {
            return "Response JSON tidak dapat diproses dengan aman."
        }

        return redactedResponse
    }

    private static func redacted(_ value: Any) -> Any {
        if let dictionary = value as? [String: Any] {
            return Dictionary(uniqueKeysWithValues: dictionary.map { key, value in
                let sensitiveKeys = [
                    "api_token",
                    "access_token",
                    "refresh_token",
                    "token",
                    "device_token"
                ]
                let redactedValue = sensitiveKeys.contains(key.lowercased())
                    ? "[REDACTED]"
                    : redacted(value)

                return (key, redactedValue)
            })
        }

        if let array = value as? [Any] {
            return array.map(redacted)
        }

        return value
    }
}
