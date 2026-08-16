import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

import KubarOKCore

@main
struct KubarOKAuthFlowTest {

    static func main() async {
        let environment = ProcessInfo.processInfo.environment

        guard let login = environment["KUBAROK_LOGIN"],
              !login.isEmpty,
              let password = environment["KUBAROK_PASSWORD"],
              !password.isEmpty else {
            print("Credential belum diberikan.")
            exit(1)
        }

        let deviceToken = environment["KUBAROK_DEVICE_TOKEN"] ?? ""

        do {
            let session = try await AuthService.shared.login(
                login: login,
                password: password,
                deviceToken: deviceToken
            )

            print("✅ LOGIN BERHASIL")
            let user = try await UserService.shared.getUser(
                apiToken: session.apiToken
            )
            print("✅ USER BERHASIL DIAMBIL")

            if user.citizen == nil {
                print("ℹ️ CITIZEN BELUM DIISI")
                print("➡️ ONBOARDING PROFILE DIPERLUKAN")
            } else {
                print("✅ CITIZEN SUDAH DIISI")
                print("✅ PROFILE LENGKAP")
            }

            print("========================================")
            print("✅ AUTHENTICATED FLOW BERHASIL")
            print("========================================")
        } catch let error as APIError {
            print("AUTHENTICATED FLOW GAGAL")
            print("")

            switch error {
            case .httpError(let statusCode, _):
                print("HTTP Status:")
                print(statusCode)
            default:
                print(error.localizedDescription)
            }

            exit(1)
        } catch {
            print("AUTHENTICATED FLOW GAGAL")
            print("")
            print(error.localizedDescription)
            exit(1)
        }
    }

}
