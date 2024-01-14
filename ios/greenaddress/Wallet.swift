import Flutter
import greenaddress

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
