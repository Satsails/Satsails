import Flutter

public class GDKWallet {
    var SUBACCOUNT_TYPE = "2of2"
    var SUBACCOUNT_NAME = ""
    var PIN_DATA_FILENAME = "pin_data.json"
    var mnemonic: String?
    var session: GDKSession?
    var subaccountPointer: Any?
    var lastBlockHeight = 0

    // Class method to create and return an instance of GDKWallet
    class func createNewWallet(createWith2FAEnabled: Bool, mnemonic: String? = nil) throws -> GDKWallet {
        let wallet = GDKWallet()

        // You can pass in a mnemonic generated outside GDK if you want, or have
        // GDK generate it for you by omitting it. 2FA is enabled if chosen and
        // can be enabled/disabled at any point.
        wallet.mnemonic = mnemonic ?? ""

        // Session network name options are: testnet, mainnet.
        wallet.session = try? GDKSession()
        try? wallet.session?.connect(netParams: ["name": "testnet"])

        let credentials = ["mnemonic": wallet.mnemonic]
        try? wallet.session?.registerUserSW(details: credentials).call()
        try? wallet.session?.loginUserSW(details: credentials).call()
        try? wallet.fetchBlockHeight()

        if createWith2FAEnabled {
            try? wallet.twofactorAuthEnabled(true)
        }

        return wallet
    }

    // Method to fetch block height
    func fetchBlockHeight() throws {
        // New blocks are added to notifications as they are found, so we need to
        // find the latest or, if there hasn't been one since we last checked,
        // use the value set during login in the session's login method.
        // The following provides an example of using GDK's notification queue.

//        let q = self.session?.notifications
//        while let notification = try? q?.get(block: true, timeout: 1) {
//            if let event = notification["event"] as? String, event == "block" {
//                if let blockHeight = notification["block"]?["block_height"] as? Int,
//                    blockHeight > self.lastBlockHeight {
//                    self.lastBlockHeight = blockHeight
//                }
//            }
//        }
    }

    // Method to enable/disable two-factor authentication
    func twofactorAuthEnabled(_ isEnabled: Bool) throws {
        // Implementation for enabling/disabling two-factor authentication
    }
}



public class GDKSession: Session {
    public var ephemeral = false
    public var netParams = [String: Any]()

    public override func connect(netParams: [String: Any]) throws {
        self.netParams = netParams
        try super.connect(netParams: netParams)
    }

    public override init() {
        try! super.init()
    }

    deinit {
        super.setNotificationHandler(notificationCompletionHandler: nil)
    }

    public func loginUserSW(details: [String: Any]) throws -> TwoFactorCall {
        try loginUser(details: details)
    }

    public func loginUserHW(device: [String: Any]) throws -> TwoFactorCall {
        try loginUser(details: [:], hw_device: ["device": device])
    }

    public func registerUserSW(details: [String: Any]) throws -> TwoFactorCall {
        try registerUser(details: details)
    }

    public func registerUserHW(device: [String: Any]) throws -> TwoFactorCall {
        try registerUser(details: [:], hw_device: ["device": device])
    }

    public override func setNotificationHandler(notificationCompletionHandler: NotificationCompletionHandler?) {
        super.setNotificationHandler(notificationCompletionHandler: notificationCompletionHandler)
    }
}

public struct GdkInit: Codable {
    enum CodingKeys: String, CodingKey {
        case datadir
        case tordir
        case registrydir
        case logLevel = "log_level"
    }
    public let datadir: String?
    public let tordir: String?
    public let registrydir: String?
    public let logLevel: String
    public var breezSdkDir: String { "\(datadir ?? "")/breezSdk" }
    
    public static func defaults() -> GdkInit {
        let appSupportDir = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let cacheDir = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var logLevel = "none"
#if DEBUG
        logLevel = "info"
#endif
        return GdkInit(datadir: appSupportDir?.path,
                       tordir: cacheDir?.path,
                       registrydir: cacheDir?.path,
                       logLevel: logLevel)
    }
    
    public func run() {
        try? gdkInit(config: self.toDict() ?? [:])
        
    }
}

public class Wallet {
    private var channel: FlutterMethodChannel?

    public init(controller: FlutterViewController) {
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
        let walletInit = GdkInit.defaults().run()
        
        do {
            let newWallet = try GDKWallet.createNewWallet(createWith2FAEnabled: true)
            // Handle successful creation, possibly by sending wallet data back to Flutter
            result(newWallet)
        } catch {
            // Handle error, possibly by sending an error message back to Flutter
            result("WALLET_CREATION_ERROR: Failed to create wallet")
        }
    }
}
