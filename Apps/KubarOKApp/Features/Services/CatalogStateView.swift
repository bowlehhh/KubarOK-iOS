#if canImport(SwiftUI)
import SwiftUI

struct CatalogStateView: View {

    let title: String
    let message: String?
    let retryTitle: String?
    let retry: (() -> Void)?

    init(
        title: String,
        message: String? = nil,
        retryTitle: String? = nil,
        retry: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.retry = retry
    }

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Text(title).font(.headline)
            if let message {
                Text(message).font(.footnote).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            if let retryTitle, let retry {
                Button(retryTitle, action: retry).buttonStyle(.borderedProminent)
            }
        }
        .padding(AppSpacing.large)
    }
}
#endif
