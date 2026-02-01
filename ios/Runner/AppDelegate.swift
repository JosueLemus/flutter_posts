import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Allow foreground notifications
    UNUserNotificationCenter.current().delegate = self

    // Request authorization
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound, .badge]
    ) { granted, error in
      print("Notification permission granted: \(granted)")
      if let error = error {
        print("Notification permission error: \(error)")
      }
    }

    GeneratedPluginRegistrant.register(with: self)

    // Pigeon setup
    let controller = window?.rootViewController as! FlutterViewController
    NativeNotificationApiSetup.setUp(
      binaryMessenger: controller.binaryMessenger,
      api: NativeNotificationApiImpl()
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound])
    } else {
      completionHandler([.alert, .sound])
    }
  }
}
