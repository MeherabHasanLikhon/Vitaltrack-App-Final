import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let reminderIdentifier = "VitalTrackHydrationReminder"
    private var permissionRequested = false

    private init() {}

    func requestPermission() {
        guard !permissionRequested else { return }
        permissionRequested = true

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            // no action needed; future scheduling asks settings again so nothing else is required.
        }
    }

    func scheduleHydrationReminderIfNeeded(waterIntake: Double, target: Double) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }

            guard let self = self else { return }

            if target <= 0 || waterIntake >= target {
                center.removePendingNotificationRequests(withIdentifiers: [self.reminderIdentifier])
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "Hydration reminder"
            content.body = "You're at \(Int(waterIntake)) ml. Keep sipping toward \(Int(target)) ml today."
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60, repeats: true)
            let request = UNNotificationRequest(identifier: self.reminderIdentifier, content: content, trigger: trigger)

            center.removePendingNotificationRequests(withIdentifiers: [self.reminderIdentifier])
            center.add(request) { _ in }
        }
    }
}
