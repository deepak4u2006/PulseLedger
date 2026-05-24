# PulseSecurity

Keychain-backed session storage, biometric unlock (`BiometricGate`), and a simulator-safe Secure Enclave stub.

## Components

| Type | Role |
|------|------|
| `KeychainStore` | Generic password items for PIN, email, session flags |
| `AuthSessionStore` | Login state, biometrics preference |
| `BiometricGate` | `LAContext` wrapper for Face ID / Touch ID |
| `SecureEnclaveStub` | No-op on simulator; documents real SE integration path |

## Notes

- PINs are stored locally for demo only — never ship production credentials this way.
- Secure Enclave key generation is stubbed; use `SecKeyCreateRandomKey` with `kSecAttrTokenIDSecureEnclave` on device builds.
