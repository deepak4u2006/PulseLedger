import Combine
import Foundation

/// Simulates offline mode for demo; toggle via `isOffline` (Combine pipeline).
final class NetworkReachabilitySimulator: ObservableObject {
    @Published private(set) var isOffline = false

    var isOfflinePublisher: AnyPublisher<Bool, Never> {
        $isOffline.eraseToAnyPublisher()
    }

    func setOffline(_ offline: Bool) {
        isOffline = offline
    }

    func toggleOffline() {
        isOffline.toggle()
    }
}
