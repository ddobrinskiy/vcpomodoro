import Foundation
import UserNotifications

class NotificationService {
    private var useNativeNotifications = true
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if granted {
                print("✅ Notification permission granted")
                self?.useNativeNotifications = true
            } else {
                print("⚠️ Using fallback notifications (osascript)")
                self?.useNativeNotifications = false
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        if useNativeNotifications {
            sendNativeNotification(title: title, body: body)
        } else {
            sendFallbackNotification(title: title, body: body)
        }
    }
    
    private func sendNativeNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if error != nil {
                // Fallback if native fails
                self?.sendFallbackNotification(title: title, body: body)
            }
        }
    }
    
    private func sendFallbackNotification(title: String, body: String) {
        // Use osascript to display notification (always works)
        let script = """
            display notification "\(body)" with title "\(title)"
        """
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        
        do {
            try process.run()
        } catch {
            print("Failed to send fallback notification: \(error)")
        }
    }
}


