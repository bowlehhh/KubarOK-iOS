#if canImport(SwiftUI)
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum AppColors {
    static let accent = Color.blue
#if canImport(UIKit)
    static let background = Color(.systemGroupedBackground)
    static let surface = Color(.secondarySystemGroupedBackground)
#else
    static let background = Color.gray.opacity(0.08)
    static let surface = Color.gray.opacity(0.16)
#endif
}

enum AppSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
}

enum AppRadius {
    static let standard: CGFloat = 12
}
#endif
