import Flutter
import greenaddress

//use this just to implement sission init (with connect-
//public class GDKSession: greenaddress.Session {
//    public var ephemeral = false
//    public var netParams = [String: Any]()
//
//    public override func connect(netParams: [String: Any]) throws {
//        self.netParams = netParams
//        try super.connect(netParams: netParams)
//    }
//
//    public override init() {
//        try! super.init()
//    }
//
//    deinit {
//        super.setNotificationHandler(notificationCompletionHandler: nil)
//    }
//
//    public func loginUserSW(details: [String: Any]) throws -> TwoFactorCall {
//        try greenaddress.loginUser(details: details)
//    }
//
//    public func loginUserHW(device: [String: Any]) throws -> TwoFactorCall {
//        try greenaddress.loginUser(details: [:], hw_device: ["device": device])
//    }
//
//    public func registerUserSW(details: [String: Any]) throws -> TwoFactorCall {
//        try greenaddress.registerUser(details: details)
//    }
//
//    public func registerUserHW(device: [String: Any]) throws -> TwoFactorCall {
//        try greenaddress.registerUser(details: [:], hw_device: ["device": device])
//    }
//
//    public override func setNotificationHandler(notificationCompletionHandler: NotificationCompletionHandler?) {
//        super.setNotificationHandler(notificationCompletionHandler: notificationCompletionHandler)
//    }
//}
//
class Wallet {
    private var channel: FlutterMethodChannel?

    init(controller: FlutterViewController) {
        channel = FlutterMethodChannel(name: "ios_wallet", binaryMessenger: controller.binaryMessenger)
        channel?.setMethodCallHandler(handle)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "generateMnemonic":
            getMnemonic(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getMnemonic(result: @escaping FlutterResult) {
        do {
            let mnemonic = try greenaddress.generateMnemonic12()
            result(mnemonic)
        } catch {
            result(FlutterError(code: "UNAVAILABLE",
                                message: "Mnemonic generation failed",
                                details: nil))
        }
    }
}
