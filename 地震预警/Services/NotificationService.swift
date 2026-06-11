import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    @Published private(set) var isAuthorized = false

    private let center = UNUserNotificationCenter.current()
    private var notifiedWarningIDs: Set<String> = []

    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            if granted {
                await registerCategories()
            }
        } catch {
            isAuthorized = false
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func notifyIfNeeded(for activeWarning: ActiveWarning) async {
        guard isAuthorized else { return }

        let warningID = activeWarning.warning.id
        guard !notifiedWarningIDs.contains(warningID) else { return }
        notifiedWarningIDs.insert(warningID)

        let content = UNMutableNotificationContent()
        content.title = "地震注意（非公式）"
        content.subtitle = activeWarning.warning.hypocenter
        content.body = "第三者データ · M\(activeWarning.warning.magnitudeLabel) · 約\(activeWarning.estimatedArrivalSeconds)秒後に到達（推定）"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "EEW_ALERT"

        let request = UNNotificationRequest(
            identifier: "eew-\(warningID)",
            content: content,
            trigger: nil
        )

        try? await center.add(request)
    }

    private func registerCategories() async {
        let dismiss = UNNotificationAction(identifier: "DISMISS", title: "知道了", options: [])
        let category = UNNotificationCategory(
            identifier: "EEW_ALERT",
            actions: [dismiss],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        center.setNotificationCategories([category])
    }
}

private extension EarlyWarning {
    var magnitudeLabel: String {
        String(format: "%.1f", magnitude)
    }
}
