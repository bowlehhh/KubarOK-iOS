#if canImport(SwiftUI)
import SwiftUI

struct AppRootView: View {

    private enum UnauthenticatedRoute {
        case welcome
        case login
    }

    @ObservedObject var sessionController: AppSessionController
    @State private var unauthenticatedRoute: UnauthenticatedRoute = .welcome

    var body: some View {
        NavigationStack {
            Group {
                switch sessionController.state {
                case .launching:
                    SplashView()
                case .unauthenticated:
                    switch unauthenticatedRoute {
                    case .welcome:
                        WelcomeView {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                unauthenticatedRoute = .login
                            }
                        }
                    case .login:
                        LoginView(sessionController: sessionController)
                    }
                case .authenticatedNeedsProfile:
                    ProfileOnboardingView(sessionController: sessionController)
                case .authenticated:
                    HomeView(sessionController: sessionController)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
        }
        .tint(AppColors.green)
        .task {
            await sessionController.restore()
        }
    }
}

private struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            GeometryReader { proxy in
                Circle()
                    .fill(AppColors.prussianBlue)
                    .frame(width: proxy.size.width * 1.05)
                    .offset(x: proxy.size.width * 0.42, y: -proxy.size.width * 0.62)
                Circle()
                    .fill(AppColors.green)
                    .frame(width: proxy.size.width * 0.28)
                    .offset(x: proxy.size.width * 0.71, y: -proxy.size.width * 0.16)
                Circle()
                    .fill(AppColors.prussianBlue)
                    .frame(width: proxy.size.width * 1.25)
                    .offset(x: -proxy.size.width * 0.62, y: proxy.size.height * 0.72)
                Circle()
                    .fill(AppColors.green)
                    .frame(width: proxy.size.width * 0.62)
                    .offset(x: proxy.size.width * 0.61, y: proxy.size.height * 0.83)
            }
            .clipped()
            .accessibilityHidden(true)

            Image("KubarOKLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 237, height: 240)
                .accessibilityLabel("KubarOK")
        }
        .ignoresSafeArea()
    }
}

private struct WelcomeView: View {
    let continueToLogin: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.medium) {
                ForEach(["WelcomeNews1", "WelcomeNews2", "WelcomeNews3"], id: \.self) { asset in
                    Image(asset)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.55, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                        .accessibilityHidden(true)
                }

                Button("Login", action: continueToLogin)
                    .buttonStyle(KubarOKButtonStyle())
                    .frame(maxWidth: 155)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHint("Membuka halaman login")
            }
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, AppSpacing.medium)
        }
        .background(Color.white)
    }
}
#endif
