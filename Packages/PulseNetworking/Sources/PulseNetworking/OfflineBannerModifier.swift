import PulseDesign
import SwiftUI

public extension View {
    /// Shows the shared offline banner when `isOffline` is true.
    func pulseOfflineBanner(isOffline: Bool) -> some View {
        VStack(spacing: 0) {
            if isOffline {
                OfflineBanner()
            }
            self
        }
    }
}
