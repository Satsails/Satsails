import Flutter

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

