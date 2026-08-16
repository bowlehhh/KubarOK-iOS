#if canImport(SwiftUI) && canImport(Security)
import SwiftUI

@main
struct KubarOKApp: App {

    @StateObject private var sessionController = AppSessionController(
        sessionManager: SessionManager(
            tokenStore: KeychainTokenStore(),
            api: LiveSessionAPI()
        )
    )

    var body: some Scene {
        WindowGroup {
            AppRootView(sessionController: sessionController)
        }
    }
}
#endif
