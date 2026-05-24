import Foundation

@MainActor
public final class PINAuthViewModel: ObservableObject {
    private weak var coordinator: AuthCoordinator?

    public init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }

    public var pin: String { coordinator?.pinDraft ?? "" }
    public var errorMessage: String? { coordinator?.errorMessage }

    public func digit(_ value: String) { coordinator?.appendPinDigit(value) }
    public func delete() { coordinator?.deletePinDigit() }
    public func continueTapped() { coordinator?.submitPIN() }
}
