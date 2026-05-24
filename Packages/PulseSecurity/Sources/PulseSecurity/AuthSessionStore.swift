import Foundation

/// High-level auth session backed by Keychain.
public final class AuthSessionStore: @unchecked Sendable {
    private let keychain: KeychainStoring

    public init(keychain: KeychainStoring = KeychainStore.shared) {
        self.keychain = keychain
    }

    public var isLoggedIn: Bool {
        get { (try? keychain.load(key: KeychainStore.sessionKey)) == "true" }
        set {
            try? keychain.save(key: KeychainStore.sessionKey, value: newValue ? "true" : "false")
        }
    }

    public var pin: String? {
        get { try? keychain.load(key: KeychainStore.pinKey) }
        set {
            if let newValue {
                try? keychain.save(key: KeychainStore.pinKey, value: newValue)
            } else {
                try? keychain.delete(key: KeychainStore.pinKey)
            }
        }
    }

    public var email: String? {
        get { try? keychain.load(key: KeychainStore.emailKey) }
        set {
            if let newValue {
                try? keychain.save(key: KeychainStore.emailKey, value: newValue)
            } else {
                try? keychain.delete(key: KeychainStore.emailKey)
            }
        }
    }

    public var isBiometricsEnabled: Bool {
        get { (try? keychain.load(key: KeychainStore.biometricsEnabledKey)) == "true" }
        set {
            try? keychain.save(key: KeychainStore.biometricsEnabledKey, value: newValue ? "true" : "false")
        }
    }

    public func signOut() {
        isLoggedIn = false
        pin = nil
        email = nil
        isBiometricsEnabled = false
    }
}
