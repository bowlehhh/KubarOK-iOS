import Foundation

public struct AuthSession: Sendable {

    public let apiToken: String
    public let user: User

    public init(apiToken: String, user: User) {
        self.apiToken = apiToken
        self.user = user
    }
}
