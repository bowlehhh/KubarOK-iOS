#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum AppColors {
    static let prussianBlue = Color(red: 0, green: 49 / 255, blue: 82 / 255)
    static let green = Color(red: 27 / 255, green: 155 / 255, blue: 78 / 255)
    static let red = Color(red: 213 / 255, green: 20 / 255, blue: 43 / 255)
    static let field = Color(red: 243 / 255, green: 243 / 255, blue: 243 / 255)
    static let accent = green
#if canImport(UIKit)
    static let background = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemBackground)
#else
    static let background = Color.white
    static let groupedBackground = Color.gray.opacity(0.08)
    static let surface = Color.gray.opacity(0.16)
#endif
}

enum AppSpacing {
    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let regular: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

enum AppRadius {
    static let small: CGFloat = 4
    static let standard: CGFloat = 10
    static let card: CGFloat = 12
    static let large: CGFloat = 18
}

enum AppShadow {
    static let color = Color.black.opacity(0.14)
    static let radius: CGFloat = 2
    static let y: CGFloat = 2
}

struct KubarOKButtonStyle: ButtonStyle {
    var isDestructive = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .tracking(1.1)
            .textCase(.uppercase)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(isDestructive ? AppColors.red : AppColors.green)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
            .opacity(configuration.isPressed ? 0.78 : 1)
    }
}

struct KubarOKField<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .font(.subheadline)
            .padding(.horizontal, AppSpacing.medium)
            .frame(minHeight: 44)
            .background(AppColors.field)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.standard, style: .continuous))
    }
}

struct KubarOKTopBar: View {
    var body: some View {
        ZStack {
            AppColors.prussianBlue
            Image("KubarOKLogoWhite")
                .resizable()
                .scaledToFit()
                .frame(width: 73, height: 40)
                .accessibilityLabel("KubarOK")
        }
        .frame(height: 50)
    }
}

struct KubarOKDecorativeBackground: View {
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(AppColors.prussianBlue)
                .frame(width: proxy.size.width * 1.05)
                .offset(x: -proxy.size.width * 0.62, y: proxy.size.height * 0.68)
            Circle()
                .fill(AppColors.green)
                .frame(width: proxy.size.width * 0.58)
                .offset(x: proxy.size.width * 0.68, y: proxy.size.height * 0.84)
        }
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
#endif
