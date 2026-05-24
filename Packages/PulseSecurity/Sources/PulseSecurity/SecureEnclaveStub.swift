import Foundation

/// Simulator-safe placeholder for Secure Enclave key operations.
/// On device, a production app would generate non-exportable keys via `SecKeyCreateRandomKey`.
public enum SecureEnclaveStub {
    public static var isAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    public static func stubKeyIdentifier() -> String {
        "pulseledger.secure-enclave.stub.\(UUID().uuidString.prefix(8))"
    }
}
