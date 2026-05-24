import Foundation

/// High-level auth session backed by Keychain.
public final class AuthSessionStore: @unchecked Sendable {
    private let keychain: KeychainStoring

    public init(keychain: KeychainStoring = KeychainStore.shared) {
        self.keychain = keychain
        reconcileStaleSession()
    }

    /// Session is valid only when logged-in flag and a PIN exist in Keychain.
    public var hasValidSession: Bool {
        reconcileStaleSession()
        guard isLoggedIn else { return false }
        guard let pin, pin.count >= 4 else { return false }
        return true
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

    /// Clears Keychain auth keys and notification-related UserDefaults (DEBUG / QA reset).
    public func resetAppState() {
        signOut()
        for key in [
            KeychainStore.pinKey,
            KeychainStore.emailKey,
            KeychainStore.sessionKey,
            KeychainStore.biometricsEnabledKey,
        ] {
            try? keychain.delete(key: key)
        }
        UserDefaults.standard.removeObject(forKey: "pulseledger.notifications.enabled")
        UserDefaults.standard.removeObject(forKey: "pulseledger.hasLaunchedBefore")
    }

    private func reconcileStaleSession() {
        let pinValid = (pin?.count ?? 0) >= 4
        if isLoggedIn && !pinValid {
            signOut()
        }
    }
}
