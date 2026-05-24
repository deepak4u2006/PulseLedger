import Foundation

@MainActor
public final class WelcomeViewModel: ObservableObject {
    private weak var coordinator: AuthCoordinator?

    public init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }

    public func loginTapped() { coordinator?.startLogin() }
    public func signupTapped() { coordinator?.startSignup() }
}
