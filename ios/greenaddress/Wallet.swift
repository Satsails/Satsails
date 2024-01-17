import Flutter
import Dispatch

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
        wallet.mnemonic = mnemonic ?? "floor motor waste close enforce stadium image team club conduct wife exact"
        
        // Session network name options are: testnet, mainnet.
        wallet.session = try? GDKSession()
        try? wallet.session?.connect(netParams: ["name": "testnet"])
        
        let credentials = ["mnemonic": wallet.mnemonic]
        try? wallet.session?.registerUserSW(details: credentials).call()
        try? wallet.session?.loginUserSW(details: credentials).call()
        
        if createWith2FAEnabled {
            try? wallet.twofactorAuthEnabled(true)
        }
        
        return wallet
    }
    
    
    func fetchSubaccount() throws {
        let credentials = ["mnemonic": self.mnemonic]
        guard let subaccountsCall = try? session?.getSubaccounts(details: credentials) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to fetch subaccounts"])
        }

        // Use DummyResolve to continuously check the status
        let subaccountsStatus = try DummyResolve(call: subaccountsCall)

        // Extract subaccounts data from the result
        guard let result = subaccountsStatus["result"] as? [String: Any],
              let subaccounts = result["subaccounts"] as? [[String: Any]] else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to extract subaccounts data"])
        }

        // Iterate through subaccounts and find the matching one
        for subaccount in subaccounts {
            if SUBACCOUNT_TYPE == subaccount["type"] as? String, SUBACCOUNT_NAME == subaccount["name"] as? String {
                self.subaccountPointer = subaccount["pointer"]
                return // Exit the loop once the matching subaccount is found
            }
        }

        // If no matching subaccount is found, throw an error
        throw NSError(domain: "com.example.wallet", code: 2, userInfo: ["error": "Cannot find the subaccount with name: \(SUBACCOUNT_NAME) and type: \(SUBACCOUNT_TYPE)"])
    }

    func getReceiveAddress() throws -> String {
        // Fetch the subaccount if it's not already fetched
        if subaccountPointer == nil {
            try fetchSubaccount()
        }

        let subAccount = ["subaccount": subaccountPointer]
        
        guard let receiveAddressCall = try? session?.getReceiveAddress(details: subAccount) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get receive address"])
        }

        // Use DummyResolve to continuously check the status
        let receiveAddressStatus = try DummyResolve(call: receiveAddressCall)

        // Extract the receive address from the result
        guard let result = receiveAddressStatus["result"] as? [String: Any],
              let address = result["address"] as? String else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to extract receive address"])
        }

        return address
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
            let newWallet = try GDKWallet.createNewWallet(createWith2FAEnabled: false)
            let subAccount = try? newWallet.fetchSubaccount()
            let receiveAddress = try? newWallet.getReceiveAddress()
            
            result(receiveAddress)
        } catch {
            // Handle error, possibly by sending an error message back to Flutter
            result("WALLET_CREATION_ERROR: Failed to create wallet")
        }
    }
}
