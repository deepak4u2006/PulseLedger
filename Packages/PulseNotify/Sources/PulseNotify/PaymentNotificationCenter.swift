import Foundation
import UserNotifications

public enum PulseNotificationCategory: String {
    case payment = "PAYMENT_ALERT"
}

@MainActor
public final class PaymentNotificationCenter: NSObject, ObservableObject {
    @Published public private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published public var alertsEnabled: Bool {
        didSet { UserDefaults.standard.set(alertsEnabled, forKey: Self.alertsKey) }
    }

    private static let alertsKey = "pulseledger.notifications.enabled"
    private let center = UNUserNotificationCenter.current()

    public override init() {
        alertsEnabled = UserDefaults.standard.object(forKey: Self.alertsKey) as? Bool ?? true
        super.init()
        center.delegate = self
        registerCategories()
    }

    public func refreshStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    @discardableResult
    public func requestAuthorizationIfNeeded() async -> Bool {
        await refreshStatus()
        if authorizationStatus == .authorized { return true }
        if authorizationStatus == .denied { return false }
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await refreshStatus()
            return granted
        } catch {
            return false
        }
    }

    public func schedulePaymentReceived(title: String, amount: String) async {
        guard alertsEnabled else { return }
        let authorized = await requestAuthorizationIfNeeded()
        guard authorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Payment received"
        content.body = "\(amount) from \(title) · Tap to view"
        content.sound = .default
        content.categoryIdentifier = PulseNotificationCategory.payment.rawValue

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let id = "payment-\(UUID().uuidString)"
        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func registerCategories() {
        let view = UNNotificationAction(identifier: "VIEW", title: "View", options: .foreground)
        let dismiss = UNNotificationAction(identifier: "DISMISS", title: "Dismiss", options: .destructive)
        let payment = UNNotificationCategory(
            identifier: PulseNotificationCategory.payment.rawValue,
            actions: [view, dismiss],
            intentIdentifiers: []
        )
        center.setNotificationCategories([payment])
    }
}

extension PaymentNotificationCenter: UNUserNotificationCenterDelegate {
    nonisolated public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
