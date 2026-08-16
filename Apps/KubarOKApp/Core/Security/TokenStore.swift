import Foundation

public protocol TokenStore: Sendable {

    func save(token: String) async throws
    func readToken() async throws -> String?
    func deleteToken() async throws
}

public enum TokenStoreError: Error, Equatable {

    case operationFailed
    case invalidStoredValue
}

public actor InMemoryTokenStore: TokenStore {

    private var token: String?

    public init(token: String? = nil) {
        self.token = token
    }

    public func save(token: String) {
        self.token = token
    }

    public func readToken() -> String? {
        token
    }

    public func deleteToken() {
        token = nil
    }
}
