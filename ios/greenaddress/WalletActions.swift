//Change error throwing from ns to expose them to flutter
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
    var greenAccountID = ""
    var blockHeight: UInt32 = 0
    var uuid = UUID()
    
    public func newNotification(notification: [String: Any]?) {
        guard let notificationEvent = notification?["event"] as? String,
              let event = EventType(rawValue: notificationEvent),
              let data = notification?[event.rawValue] as? [String: Any] else {
            return
        }
        switch event {
        case .Block:
            guard let height = data["block_height"] as? UInt32 else { break }
            self.blockHeight = height
        case .Subaccount:
            _ = SubaccountEvent.from(data) as? SubaccountEvent
            post(event: .Block, userInfo: data)
            post(event: .Transaction, userInfo: data)
        case .Transaction:
            post(event: .Transaction, userInfo: data)
            let txEvent = TransactionEvent.from(data) as? TransactionEvent
            if txEvent?.type == "incoming" {
                txEvent?.subAccounts.forEach { pointer in
                    post(event: .AddressChanged, userInfo: ["pointer": UInt32(pointer)])
                }
            }
            post(event: .Tor, userInfo: data)
        case .Ticker:
            post(event: .Ticker, userInfo: data)
        default:
            break
        }
    }
    
    public func post(event: EventType, object: Any? = nil, userInfo: [String: Any] = [:]) {
        var data = userInfo
        data["session_id"] = uuid.uuidString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: event.rawValue),
                                        object: object, userInfo: data)
    }
    
    
    func createNewWallet(mnemonic: String? = nil, connectionType: String, name: String) throws -> GDKWallet {
        self.mnemonic = mnemonic ?? ""
        self.SUBACCOUNT_NAME = name
        self.session = GDKSession()
        do {
            try self.session?.connect(netParams: ["name": connectionType])
            let credentials = ["mnemonic": self.mnemonic, "name": name]
            try self.session?.registerUserSW(details: credentials)
            try self.session?.loginUserSW(details: credentials)
            
            return self
        } catch {
            // Handle errors related to connecting, registration, or login
            throw error
        }
    }
    
    func loginWithMnemonic(mnemonic: String? = nil,  connectionType: String) throws -> GDKWallet {
        self.mnemonic = mnemonic ?? ""
        self.session = GDKSession()
        self.session?.setNotificationHandler(notificationCompletionHandler: newNotification)
        try self.session?.connect(netParams: ["name": connectionType])
        let credentials = ["mnemonic": self.mnemonic]
        try self.session?.loginUserSW(details: credentials as [String : Any])
        
        return self
    }
    
    func createSubAccount(params: CreateSubaccountParams) throws {
        self.SUBACCOUNT_NAME = params.name
        self.SUBACCOUNT_TYPE = params.type.rawValue
        let accountType = ["name": SUBACCOUNT_NAME, "type": SUBACCOUNT_TYPE]
        guard let subaccountsCreation = try? session?.createSubaccount(details: accountType) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to fetch subaccounts"])
        }
        
        _ = try? DummyResolve(call: subaccountsCreation)
    }
    
    
    func fetchSubaccount(subAccountName: String, subAccountType: String) throws {
        let credentials = ["mnemonic": self.mnemonic]
        guard let subaccountsCall = try? self.session?.getSubaccounts(details: credentials as [String : Any]) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to fetch subaccounts"])
        }
        
        let subaccountsStatus = try DummyResolve(call: subaccountsCall)
        
        guard let result = subaccountsStatus["result"] as? [String: Any],
              let subaccounts = result["subaccounts"] as? [[String: Any]] else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to extract subaccounts data"])
        }
        
        for subaccount in subaccounts {
            if subAccountType == subaccount["type"] as? String || subAccountName == subaccount["name"] as? String  {
                self.subaccountPointer = subaccount["pointer"]
                let accountCall = try? self.session?.getSubaccount(subaccount: self.subaccountPointer as! UInt32)
                let accountStatus = try DummyResolve(call: accountCall!)
                let result = accountStatus["result"] as? [String: Any]
                self.greenAccountID = result?["receiving_id"] as! String
            }
        }
    }
    
    func fetchSubAccounts() throws -> [String: Any] {
        let credentials = ["mnemonic": self.mnemonic]
        guard let subaccountsCall = try? self.session?.getSubaccounts(details: credentials as [String : Any]) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to fetch subaccounts"])
        }
        
        let subaccountsStatus = try DummyResolve(call: subaccountsCall)
        
        guard let result = subaccountsStatus["result"] as? [String: Any],
              let subaccounts = result["subaccounts"] as? [[String: Any]] else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to extract subaccounts data"])
        }
        
        return ["subaccounts": subaccounts]
    }
    
    func getReceiveAddress() throws -> [String: Any] {
        let subAccount = ["subaccount": subaccountPointer]
        
        guard let receiveAddressCall = try? session?.getReceiveAddress(details: subAccount as [String : Any]) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get receive address"])
        }
        
        let receiveAddressStatus = try DummyResolve(call: receiveAddressCall)
        
        guard let result = receiveAddressStatus["result"] as? [String: Any],
              let address = ["address": result["address"], "unconfidencial_address": result["unconfidential_address"]] as? [String: Any] else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to extract receive address"])
        }
        
        return address
    }

    func getPreviousAddresses() throws -> [String: Any] {
        let subAccount = ["subaccount": subaccountPointer]

        guard let previousAddressesCall = try? session?.getPreviousAddresses(details: subAccount as [String : Any]) else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get previous addresses"])
        }

        let previousAddressesStatus = try DummyResolve(call: previousAddressesCall)

        guard let result = previousAddressesStatus["result"] as? [String: Any],
              let addresses = result["list"] as? [[String: Any]] else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to extract previous addresses"])
        }

        return ["addresses": addresses]
    }
    
    func getWalletBalance() throws -> Any {
        let params = ["subaccount": self.subaccountPointer, "num_confs": 0]
        do{
            guard let balanceCall = try? session?.getBalance(details: params as [String : Any]) else {
                throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to balance"])
            }
            let receiveAddressStatus = try DummyResolve(call: balanceCall)
            return receiveAddressStatus["result"] ?? [:]
        }
        catch{
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "cannot get balance"])
        }
    }
    
    func getWalletTransactions(count: Int, index: Int, pointer: Int64)throws -> [String: Any] {
        let params = ["subaccount": pointer, "first": index, "count": count] as [String : Any]
        do{
            guard let transactionCall = try self.session?.getTransactions(details: params as [String : Any]) else {
                throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get transactions"])
            }
            let transactions = try DummyResolve(call: transactionCall)
            return transactions
        }catch{
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to fetch transactions"])
        }
    }
    func getUnspentOutputs(numberOfConfs: Int) throws ->  [String: Any] {
        let params = ["subaccount": self.subaccountPointer, "num_confs": numberOfConfs] as [String : Any]
        do{
            guard let unspentOutputsCall = try self.session?.getUnspentOutputs(details: params as [String : Any]) else {
                throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get unspent outputs"])
            }
            let unspentOutputsStatus = try DummyResolve(call: unspentOutputsCall)
            let result = unspentOutputsStatus["result"] as? [String: Any]
            let unspentPair = result?["unspent_outputs"] as? [String: Any] ?? [:]
            var coinType: String
            
            if unspentPair["btc"] != nil {
                coinType = "btc"
            } else {
                coinType = "liquid"
            }
            
            return ["utxos": unspentPair, "coinType": coinType]
        }catch{
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get UTXOs"])
        }
    }

    func getFeesEstimates() throws -> [UInt64] {
        guard let feeEstimates = try self.session?.getFeeEstimates() else {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get fee estimates"])
        }

        return feeEstimates["fees"] as? [UInt64] ?? []
    }
    
    func sendToAddress(address: String, amount: Int64, assetId: String) throws -> String {
        do {
            let unspentOutputs = try getUnspentOutputs(numberOfConfs: 0)
            var paramsForCreateTransaction: [String: Any]
            
            if let coinType = unspentOutputs["coinType"] as? String {
                if coinType == "btc" {
                    paramsForCreateTransaction = [
                        "addressees": [["address": address, "satoshi": amount]],
                        "utxos": unspentOutputs["utxos"]
                    ]
                } else {
                    paramsForCreateTransaction = [
                        "addressees": [["address": address, "satoshi": amount, "asset_id": assetId]],
                        "utxos": unspentOutputs["utxos"]
                    ]
                }
                
                guard let createTransactionCall = try self.session?.createTransaction(details: paramsForCreateTransaction) else {
                    throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to create transaction"])
                }
                
                guard let createTransactionResolve = try DummyResolve(call: createTransactionCall) as? [String: Any] else {
                    throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to sign or resolve transaction"])
                }
                
                var transactionResult = createTransactionResolve["result"] as? [String: Any] ?? [:]
                
                if coinType != "btc" {
                    guard let blindTransactionCall = try self.session?.blindTransaction(details: transactionResult) else {
                        throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to blind transaction"])
                    }
                    
                    guard let blindTransactionResolve = try DummyResolve(call: blindTransactionCall) as? [String: Any] else {
                        throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to sign or resolve transaction"])
                    }
                    
                    transactionResult = blindTransactionResolve["result"] as? [String: Any] ?? [:]
                }
                
                guard let signTransactionCall = try self.session?.signTransaction(details: transactionResult) else {
                    throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to sign transaction"])
                }
                
                let signTransactionResolve = try DummyResolve(call: signTransactionCall)
                
                let signTransactionResult = signTransactionResolve["result"] as? [String: Any] ?? [:]
                
                guard let sendToAddressCall = try self.session?.sendTransaction(details: signTransactionResult) else {
                    throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to send to address"])
                }
                
                let sendToAddressStatus = try DummyResolve(call: sendToAddressCall)
                let result = sendToAddressStatus["result"] as? [String: Any]
                let txid = result?["txhash"] as? String ?? ""
                
                return txid
            } else {
                throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to get coin type"])
            }
        } catch {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to send to address"])
        }
    }

    func signTransaction(transaction: [String: Any]) throws -> [String: Any] {
        do {
            guard let signTransactionCall = try self.session?.signPsbt(details: transaction) else {
                throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to sign transaction"])
            }

            let signTransactionResolve = try DummyResolve(call: signTransactionCall)

            let signTransactionResult = signTransactionResolve["result"] as? [String: Any] ?? [:]

            return signTransactionResult
        } catch {
            throw NSError(domain: "com.example.wallet", code: 1, userInfo: ["error": "Failed to sign transaction"])
        }
    }
}
