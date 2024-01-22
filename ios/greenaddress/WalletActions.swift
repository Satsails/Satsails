import Flutter

public struct CreateSubaccountParams: Codable {
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case type = "type"
        case recoveryMnemonic = "recovery_mnemonic"
        case recoveryXpub = "recovery_xpub"
    }

    public let name: String
    public let type: AccountType
    public let recoveryMnemonic: String?
    public let recoveryXpub: String?

    public init(name: String, type: AccountType, recoveryMnemonic: String? = nil, recoveryXpub: String? = nil) {
        self.name = name
        self.type = type
        self.recoveryMnemonic = recoveryMnemonic
        self.recoveryXpub = recoveryXpub
    }
}

public class GDKWallet {
    var SUBACCOUNT_TYPE = ""
    var SUBACCOUNT_NAME = ""
    var PIN_DATA_FILENAME = "pin_data.json"
    var mnemonic: String?
    var session: GDKSession?
    var subaccountPointer: Any?
    var lastBlockHeight = 0
    
    class func createNewWallet(createWith2FAEnabled: Bool, mnemonic: String? = nil, connectionType: NetworkSecurityCase) throws -> GDKWallet {
        let wallet = GDKWallet()
        wallet.mnemonic = mnemonic ?? ""
        wallet.session = try? GDKSession()
        try? wallet.session?.connect(netParams: ["name": ""])
        let credentials = ["mnemonic": wallet.mnemonic]
        try? wallet.session?.registerUserSW(details: credentials).call()
        try? wallet.session?.loginUserSW(details: credentials).call()
        if createWith2FAEnabled {
            try? wallet.twofactorAuthEnabled(true)
        }
        
        return wallet
    }
    
    func createSubAccount(params: CreateSubaccountParams) throws {
        self.SUBACCOUNT_NAME = params.name
        self.SUBACCOUNT_TYPE = params.type.rawValue
        let accountType = ["name": params.name, "type": params.type.rawValue]
        guard let subaccountsCreation = try? session?.createSubaccount(details: accountType) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to fetch subaccounts"])
        }

        let receiveAddressStatus = try? DummyResolve(call: subaccountsCreation)
}
    
    
    func fetchSubaccount(subAccountName: String, subAccountType: String) throws {
        let credentials = ["mnemonic": self.mnemonic]
        guard let subaccountsCall = try? session?.getSubaccounts(details: credentials) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to fetch subaccounts"])
        }

        let subaccountsStatus = try DummyResolve(call: subaccountsCall)

        guard let result = subaccountsStatus["result"] as? [String: Any],
              let subaccounts = result["subaccounts"] as? [[String: Any]] else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to extract subaccounts data"])
        }

        for subaccount in subaccounts {
            if subAccountType == subaccount["type"] as? String {
                self.subaccountPointer = subaccount["pointer"]
                return
            }
        }
    }

    func getReceiveAddress() throws -> String {
        let subAccount = ["subaccount": subaccountPointer]
        
        guard let receiveAddressCall = try? session?.getReceiveAddress(details: subAccount) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get receive address"])
        }

        let receiveAddressStatus = try DummyResolve(call: receiveAddressCall)

        guard let result = receiveAddressStatus["result"] as? [String: Any],
              let address = result["address"] as? String else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to extract receive address"])
        }

        return address
    }

    func twofactorAuthEnabled(_ isEnabled: Bool) throws {
        // Implementation for enabling/disabling two-factor authentication
    }
}
