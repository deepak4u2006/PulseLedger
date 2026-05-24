import Foundation
import Security

public enum KeychainError: Error, Equatable {
    case unexpectedStatus(OSStatus)
    case invalidData
}

public protocol KeychainStoring: Sendable {
    func save(key: String, value: String) throws
    func load(key: String) throws -> String?
    func delete(key: String) throws
}

/// Stores short secrets (PIN, session flags) in the iOS Keychain.
public final class KeychainStore: KeychainStoring, @unchecked Sendable {
    public static let pinKey = "pulseledger.auth.pin"
    public static let emailKey = "pulseledger.auth.email"
    public static let sessionKey = "pulseledger.auth.session"
    public static let biometricsEnabledKey = "pulseledger.auth.biometrics"
    public static let shared = KeychainStore()

    private let service: String

    public init(service: String = "com.deepak.portfolio.pulseledger") {
        self.service = service
    }

    public func save(key: String, value: String) throws {
        let data = Data(value.utf8)
        let base = query(account: key)
        SecItemDelete(base as CFDictionary)
        var add = base
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(add as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    public func load(key: String) throws -> String? {
        var q = query(account: key)
        q[kSecReturnData as String] = true
        q[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
        guard let data = item as? Data, let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return string
    }

    public func delete(key: String) throws {
        let status = SecItemDelete(query(account: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}
