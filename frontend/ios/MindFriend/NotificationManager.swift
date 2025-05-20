import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestAuthorization() async throws {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    func scheduleNotification(for app: RestrictedApp) {
        let content = UNMutableNotificationContent()
        content.title = "Restricted App Access"
        content.body = "You're trying to access \(app.name). Tap to provide a reason."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
