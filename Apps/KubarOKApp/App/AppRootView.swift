#if canImport(SwiftUI)
import SwiftUI

struct AppRootView: View {

    @ObservedObject var sessionController: AppSessionController

    var body: some View {
        NavigationStack {
            Group {
                switch sessionController.state {
                case .launching:
                    ProgressView("Menyiapkan aplikasi…")
                case .unauthenticated:
                    LoginView(sessionController: sessionController)
                case .authenticatedNeedsProfile:
                    ProfileOnboardingView(sessionController: sessionController)
                case .authenticated:
                    HomeView(sessionController: sessionController)
                }
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
        }
        .task {
            await sessionController.restore()
        }
    }
}
#endif
