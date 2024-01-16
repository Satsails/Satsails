import UIKit
import Flutter
import greenaddress

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var wallet: Wallet?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        wallet = Wallet(controller: controller)

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
