import Foundation

/// Legacy placeholder — sequential step gating was removed for dashboard stability.
/// All sections are visible as soon as their data or skeleton is on screen.
@MainActor
public final class HomeRevealCoordinator: ObservableObject {
    public enum Step: Int, CaseIterable, Sendable {
        case idle
        case carousel
        case balance
        case weeklySpend
        case chart
        case transactions
        case complete
    }

    public init() {}

    public func shouldShow(_ step: Step) -> Bool { true }

    public func beginIfIdle() {}

    public func sectionAnimationDidComplete(for step: Step) {}

    public func reset() {}
}
