#if canImport(Security)
import Foundation
import Security

public final class KeychainTokenStore: TokenStore, Sendable {

    private let service: String
    private let account = "api-token"

    public init(service: String = "id.go.kutaibarat.kubarok") {
        self.service = service
    }

    public func save(token: String) async throws {
        let query = baseQuery
        let attributes: [CFString: Any] = [
            kSecValueData: Data(token.utf8),
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }

        guard updateStatus == errSecItemNotFound else {
            throw TokenStoreError.operationFailed
        }

        var addQuery = query
        attributes.forEach { addQuery[$0.key] = $0.value }
        guard SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess else {
            throw TokenStoreError.operationFailed
        }
    }

    public func readToken() async throws -> String? {
        var query = baseQuery
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess, let data = result as? Data else {
            throw TokenStoreError.operationFailed
        }
        guard let token = String(data: data, encoding: .utf8) else {
            throw TokenStoreError.invalidStoredValue
        }
        return token
    }

    public func deleteToken() async throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw TokenStoreError.operationFailed
        }
    }

    private var baseQuery: [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
    }
}
#endif
