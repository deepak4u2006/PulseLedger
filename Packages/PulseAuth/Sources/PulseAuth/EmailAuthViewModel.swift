import Foundation

@MainActor
public final class EmailAuthViewModel: ObservableObject {
    public let isSignup: Bool
    private weak var coordinator: AuthCoordinator?

    public init(isSignup: Bool, coordinator: AuthCoordinator) {
        self.isSignup = isSignup
        self.coordinator = coordinator
    }

    public var email: String {
        get { coordinator?.emailDraft ?? "" }
        set { coordinator?.emailDraft = newValue }
    }

    public var errorMessage: String? { coordinator?.errorMessage }

    public func continueTapped() { coordinator?.submitEmail() }
}
