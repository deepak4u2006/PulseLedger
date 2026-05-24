import Combine
import Foundation
import Network

/// Live reachability via `NWPathMonitor`; publishes online state on the main queue.
public final class NetworkReachabilityMonitor: ObservableObject, @unchecked Sendable {
    @Published public private(set) var isOnline = true

    public var isOnlinePublisher: AnyPublisher<Bool, Never> {
        $isOnline.eraseToAnyPublisher()
    }

    public var isOfflinePublisher: AnyPublisher<Bool, Never> {
        $isOnline.map { !$0 }.eraseToAnyPublisher()
    }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.deepak.portfolio.pulseledger.reachability")

    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            DispatchQueue.main.async {
                self?.isOnline = online
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
