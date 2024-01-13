import UIKit
import Flutter
import greenaddress

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let helloWorldChannel = FlutterMethodChannel(name: "com.example/hello_world",
                                              binaryMessenger: controller.binaryMessenger)
    helloWorldChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
      // Handle battery messages.
      if call.method == "getHelloWorld" {
        self.receiveHelloWorld(call, result: result)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

private func receiveHelloWorld(_ call: FlutterMethodCall, result: FlutterResult) {
    do {
        let mnemonic = try greenaddress.generateMnemonic()
        result(mnemonic)
    } catch {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Failed to generate mnemonic",
                            details: nil))
    }
}
}
