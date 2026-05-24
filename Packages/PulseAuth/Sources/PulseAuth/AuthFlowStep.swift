import Foundation

public enum AuthFlowStep: Hashable, Sendable {
    case welcome
    case email(isSignup: Bool)
    case pin
    case biometrics
    case success
}
