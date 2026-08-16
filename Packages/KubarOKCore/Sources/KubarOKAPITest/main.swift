import Foundation
import KubarOKCore

@main
struct KubarOKAPITest {

    static func main() async {
        print("")
        print("======================================")
        print("       KUBAROK API CONNECTION TEST")
        print("======================================")
        print("")

        print("Base URL:")
        print(APIConfig.baseURL.absoluteString)

        print("")
        print("Menghubungkan ke backend KubarOK...")
        print("")

        do {
            let response = try await APIClient.shared.testConnection()

            print("✅ KONEKSI BERHASIL")
            print("")
            print("Response backend:")
            print("--------------------------------------")
            print(response)
            print("--------------------------------------")
        } catch {
            print("❌ KONEKSI GAGAL")
            print("")

            if let localizedError = error as? LocalizedError,
               let description = localizedError.errorDescription {
                print(description)
            } else {
                print(error.localizedDescription)
            }
        }

        print("")
    }
}
