import Foundation
import Flutter
import UserNotifications

class NativeNotificationApiImpl: NSObject, NativeNotificationApi {

  func showNotification(payload: NotificationPayload) throws {
    let content = UNMutableNotificationContent()
    content.title = payload.title
    content.body = payload.body
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: 1,
      repeats: false
    )

    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: trigger
    )

    UNUserNotificationCenter.current().add(request)
  }
}
