#if canImport(SwiftUI)
import SwiftUI

struct AppRootView: View {

    private enum AppRoute: Equatable {
        case splash
        case publicHome
        case login
        case registration
        case profileOnboarding
        case authenticatedHome
    }

    @ObservedObject var sessionController: AppSessionController
    @State private var route: AppRoute = .splash
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch route {
                case .splash:
                    SplashView()
                case .publicHome:
                    PublicHomeView(
                        showLogin: { transition(to: .login) },
                        showRegistration: { transition(to: .registration) }
                    )
                case .login:
                    LoginView(
                        sessionController: sessionController,
                        showPublicHome: { transition(to: .publicHome) },
                        showRegistration: { transition(to: .registration) }
                    )
                case .registration:
                    RegistrationView(
                        sessionController: sessionController,
                        showLogin: { transition(to: .login) },
                        showPublicHome: { transition(to: .publicHome) }
                    )
                case .profileOnboarding:
                    ProfileOnboardingView(sessionController: sessionController)
                case .authenticatedHome:
                    HomeView(sessionController: sessionController)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
        }
        .tint(AppColors.green)
        .task {
            await restoreSessionFromSplash()
        }
        .onChange(of: sessionController.state) { state in
            guard route != .splash else { return }
            transition(to: route(for: state))
        }
    }

    private func restoreSessionFromSplash() async {
        async let restore: Void = sessionController.restore()
        try? await Task.sleep(nanoseconds: 900_000_000)
        await restore
        transition(to: route(for: sessionController.state))
    }

    private func route(for sessionState: AppSessionState) -> AppRoute {
        switch sessionState {
        case .launching, .unauthenticated:
            return .publicHome
        case .authenticatedNeedsProfile:
            return .profileOnboarding
        case .authenticated:
            return .authenticatedHome
        }
    }

    private func transition(to destination: AppRoute) {
        guard route != destination else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            navigationPath = NavigationPath()
            route = destination
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

private struct PublicHomeView: View {
    let showLogin: () -> Void
    let showRegistration: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                PublicHomeDecoration()
                    .ignoresSafeArea(edges: .top)

                ScrollView {
                    LazyVStack(spacing: AppSpacing.medium) {
                        ForEach(["WelcomeNews1", "WelcomeNews2", "WelcomeNews3"], id: \.self) { asset in
                            let cardWidth = max(proxy.size.width - (AppSpacing.small * 2), 0)

                            Image(asset)
                                .resizable()
                                .frame(width: cardWidth, height: cardWidth * 267 / 385)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                                .contentShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                                .accessibilityHidden(true)
                        }

                        HStack(spacing: AppSpacing.regular) {
                            Button("Login", action: showLogin)
                                .buttonStyle(KubarOKButtonStyle())

                            Button("Daftar", action: showRegistration)
                                .buttonStyle(KubarOKOutlinedButtonStyle())
                        }
                        .frame(maxWidth: 322)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.regular)
                        .padding(.bottom, AppSpacing.large)
                    }
                    .padding(.top, AppSpacing.medium)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color.white)
        }
        .background(Color.white.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct PublicHomeDecoration: View {
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(AppColors.prussianBlue)
                .frame(width: proxy.size.width * 1.05)
                .offset(x: proxy.size.width * 0.42, y: -proxy.size.width * 0.86)
            Circle()
                .fill(AppColors.green)
                .frame(width: proxy.size.width * 0.28)
                .offset(x: proxy.size.width * 0.71, y: -proxy.size.width * 0.13)
        }
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
#endif
