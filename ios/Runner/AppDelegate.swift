import UIKit
import Flutter
import Firebase
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure() // <-- Initialize Firebase

    GeneratedPluginRegistrant.register(with: self)

    // This is required to make any communication available in the background isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // This is required to handle silent push notifications.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // THIS IS THE CRUCIAL FUNCTION FOR BACKGROUND NOTIFICATIONS
  // It's called by iOS when a remote notification arrives, allowing background processing.
  override func application(_ application: UIApplication,
  didReceiveRemoteNotification userInfo: [AnyHashable : Any],
  fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    // This line hands the notification payload to the Firebase SDK,
    // which then triggers your Dart background handler.
    Messaging.messaging().appDidReceiveMessage(userInfo)

    // We must call the completion handler to tell iOS our background task is complete.
    completionHandler(.newData)
  }
}