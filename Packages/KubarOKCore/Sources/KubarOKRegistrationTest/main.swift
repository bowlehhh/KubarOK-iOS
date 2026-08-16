import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

import KubarOKCore

@main
struct KubarOKRegistrationTest {

    static func main() async {
        let environment = ProcessInfo.processInfo.environment

        guard let name = environment["KUBAROK_REGISTER_NAME"],
              !name.isEmpty,
              let phone = environment["KUBAROK_REGISTER_PHONE"],
              !phone.isEmpty,
              let email = environment["KUBAROK_REGISTER_EMAIL"],
              !email.isEmpty,
              let password = environment["KUBAROK_REGISTER_PASSWORD"],
              !password.isEmpty else {
            print("Data registrasi belum lengkap.")
            print("")
            print("Gunakan environment:")
            print("KUBAROK_REGISTER_NAME")
            print("KUBAROK_REGISTER_PHONE")
            print("KUBAROK_REGISTER_EMAIL")
            print("KUBAROK_REGISTER_PASSWORD")
            exit(1)
        }

        let deviceToken = environment["KUBAROK_DEVICE_TOKEN"] ?? ""

        do {
            let data = try await RegistrationService.shared.registerRaw(
                name: name,
                phone: phone,
                email: email,
                password: password,
                deviceToken: deviceToken
            )

            guard let response = String(data: data, encoding: .utf8) else {
                print("REGISTRASI GAGAL")
                print("")
                print("Response backend tidak dapat dibaca sebagai UTF-8.")
                exit(1)
            }

            print("✅ REGISTRASI BERHASIL")
            print("")
            print("Backend Response:")
            print(redactingSensitiveValues(in: response))
        } catch let error as APIError {
            print("REGISTRASI GAGAL")
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

            exit(1)
        } catch {
            print("REGISTRASI GAGAL")
            print("")
            print(error.localizedDescription)
            exit(1)
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
