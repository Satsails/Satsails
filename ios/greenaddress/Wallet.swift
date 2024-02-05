import Flutter
import Dispatch

public class Wallet {
    private var channel: FlutterMethodChannel?
    
    public init(controller: FlutterViewController) {
        channel = FlutterMethodChannel(name: "ios_wallet", binaryMessenger: controller.binaryMessenger)
        channel?.setMethodCallHandler(handle)
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "walletInit":
            walletInit(result: result)
        case "getMnemonic":
            getMnemonic(result: result)
        case "createWallet":
            guard let args = call.arguments as? [String: Any],
                  let mnemonic = args["mnemonic"] as? String,
                  let name = args["name"] as? String,
                  let connectionType = args["connectionType"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Mnemonic or connectionType not provided", details: nil))
                return
            }
            createWallet(mnemonic: mnemonic, connectionType: connectionType, name: name, result: result)
        case "getReceiveAddress":
            guard let args = call.arguments as? [String: Any],
                  let mnemonic = args["mnemonic"] as? String,
                  let connectionType = args["connectionType"] as? String,
                  let pointer = args["pointer"] as? Int64 else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Mnemonic or connectionType not provided", details: nil))
                return
            }
            getReceiveAddress(result: result, pointer: pointer, mnemonic: mnemonic, connectionType: connectionType)
        case "getBalance":
            guard let args = call.arguments as? [String: Any],
                  let mnemonic = args["mnemonic"] as? String,
                  let connectionType = args["connectionType"] as? String,
                  let pointer = args["pointer"] as? Int64 else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Mnemonic or connectionType not provided", details: nil))
                return
            }
            getBalance(result: result, connectionType: connectionType, pointer: pointer, mnemonic: mnemonic)
        case "createSubAccount":
            guard let args = call.arguments as? [String: Any],
                  let name = args["name"] as? String,
                  let mnemonic = args["mnemonic"] as? String,
                  let connectionType = args["connectionType"] as? String,
                  let walletType = args["walletType"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Incorrect arguments", details: nil))
                return
            }
            createSubAccount(result: result, name: name, walletType: walletType, mnemonic: mnemonic, connectionType: connectionType)
        case "getTransactions":
            guard let args = call.arguments as? [String: Any],
                  let mnemonic = args["mnemonic"] as? String,
                  let pointer = args["pointer"] as? Int64,
                  let connectionType = args["connectionType"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Mnemonic or connectionType not provided", details: nil))
                return
            }
            getTransactions(result: result, connectionType: connectionType, mnemonic: mnemonic, pointer: pointer)
        case "sendToAddress":
            guard let args = call.arguments as? [String: Any],
                  let mnemonic = args["mnemonic"] as? String,
                  let pointer = args["pointer"] as? Int64,
                  let connectionType = args["connectionType"] as? String,
                  let address = args["address"] as? String,
                  let amount = args["amount"] as? Int64,
                  let assetId = args["assetId"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Incorrect arguments", details: nil))
                return
            }
            sendToAddress(result: result, mnemonic: mnemonic, pointer: pointer, connectionType: connectionType, address: address, amount: amount, assetId: assetId)
        case "getPointer":
            guard let args = call.arguments as? [String: Any],
                  let name = args["name"] as? String,
                  let mnemonic = args["mnemonic"] as? String,
                  let connectionType = args["connectionType"] as? String,
                  let walletType = args["walletType"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Incorrect arguments", details: nil))
                return
            }
            getPointer(result: result,  connectionType: connectionType, mnemonic: mnemonic, name: name, walletType: walletType)
            return
        case "fetchAllSubAccounts":
            guard let args = call.arguments as? [String: Any],
                  let mnemonic = args["mnemonic"] as? String,
                  let connectionType = args["connectionType"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Mnemonic or connectionType not provided", details: nil))
                return
            }
            fetchAllSubAccounts(result: result, mnemonic: mnemonic, connectionType: connectionType)
            return
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func walletInit(result: @escaping FlutterResult) {
        GdkInit.defaults().run()
    }
    
    private func getMnemonic(result: @escaping FlutterResult) {
        let mnemonic = try? generateMnemonic12()
        result(mnemonic)
    }
    
    private func loginWithMnemonic(mnemonic: String, connectionType: String) throws -> GDKWallet? {
        let wallet =  GDKWallet()
        try wallet.loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType)
        return wallet
    }
    
    private func createWallet(mnemonic: String, connectionType: String, name: String, result: @escaping FlutterResult) {
        do {
            let wallet =  GDKWallet()
            try wallet.createNewWallet(mnemonic: mnemonic, connectionType: connectionType, name: name)
            do {
                _ = try wallet.fetchSubaccount(subAccountName: "", subAccountType: "")
            } catch {
                result(FlutterError(code: "SUBACCOUNT_ERROR", message: "Failed to fetch subaccount", details: nil))
            };
            let walletInfo: [String: Any] = ["gaid": wallet.greenAccountID, "mnemonic": wallet.mnemonic ?? "", "pointer": wallet.subaccountPointer as Any]
            result(walletInfo)
            
        } catch {
            result(FlutterError(code: "WALLET_CREATION_ERROR", message: "Failed to create wallet", details: nil))
        }
        
    }
    
    
    private func createSubAccount(result: @escaping FlutterResult, name: String, walletType: String, mnemonic: String, connectionType: String) {
        do {
            guard let accountType = AccountType(rawValue: walletType) else {
                result(FlutterError(code: "INVALID_WALLET_TYPE", message: "Invalid wallet type", details: nil))
                return
            }
            guard let wallet = try loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType) else {
                result(FlutterError(code: "LOGIN_ERROR", message: "Failed to login with mnemonic", details: nil))
                return
            }
            let createSubAccountParams = CreateSubaccountParams(name: name, type: accountType)
            let _: () = try wallet.createSubAccount(params: createSubAccountParams)
            _ = try wallet.fetchSubaccount(subAccountName: name, subAccountType: walletType)
            let walletInfo: [String: Any] = ["gaid": wallet.greenAccountID, "mnemonic": wallet.mnemonic ?? "", "pointer": wallet.subaccountPointer as Any]
            result(walletInfo)
        } catch {
            result(FlutterError(code: "SUBACCOUNT_CREATION_ERROR", message: "Failed to create subaccount", details: nil))
        }
    }
    
    private func getReceiveAddress(result: @escaping FlutterResult, pointer: Int64, mnemonic: String, connectionType: String) {
        do {
            let wallet = try loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType)
            wallet?.subaccountPointer = pointer
            let receiveAddress = try wallet?.getReceiveAddress()
            
            guard let address = receiveAddress else {
                result(FlutterError(code: "ADDRESS_ERROR", message: "Failed to get receive address", details: nil))
                return
            }
            
            result(address)
        } catch let error as NSError {
            result(FlutterError(code: "LOGIN_ERROR", message: "Failed to login with mnemonic: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func getBalance(result: @escaping FlutterResult,  connectionType: String, pointer: Int64, mnemonic: String) {
        do{
            let wallet = try loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType)
            wallet?.subaccountPointer = pointer
            let balance = try wallet?.getWalletBalance()
            result(balance)
        }catch let error as NSError {
            result(FlutterError(code: "BALANCE_ERROR", message: "Error fetching balance: \(error.localizedDescription)", details: nil))
        }
        
    }
    
    private func getPointer(result: @escaping FlutterResult, connectionType: String, mnemonic: String, name: String, walletType: String) {
        do{
            guard let wallet = try loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType) else {
                result(FlutterError(code: "LOGIN_ERROR", message: "Failed to login with mnemonic", details: nil))
                return
            }
            guard let accountType = AccountType(rawValue: walletType) else {
                result(FlutterError(code: "INVALID_WALLET_TYPE", message: "Invalid wallet type", details: nil))
                return
            }
            let createSubAccountParams = CreateSubaccountParams(name: name, type: accountType);
            let _: () = try wallet.createSubAccount(params: createSubAccountParams);
            _ = try wallet.fetchSubaccount(subAccountName: name, subAccountType: walletType);
            result(wallet.subaccountPointer as Any)
        }catch let error as NSError {
            result(FlutterError(code: "POINTER_ERROR", message: "Error getting pointer: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func getTransactions(result: @escaping FlutterResult, connectionType: String, mnemonic: String, pointer: Int64) {
        var confirmationStatus: String = "UNCONFIRMED"
        var allTxs: [[String: Any]] = []
        var index: Int = 0
        let count: Int = 30
        
        do {
            guard let wallet = try loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType) else {
                result(FlutterError(code: "LOGIN_ERROR", message: "Failed to login with mnemonic", details: nil))
                return
            }
            
            while true {
                let transactions = try wallet.getWalletTransactions(count: count, index: index, pointer: pointer)
                
                if let result = transactions["result"] as? [String: Any],
                   let transactionsArray = result["transactions"] as? [[String: Any]] {
                    
                    for var transaction in transactionsArray {
                        confirmationStatus = "UNCONFIRMED"
                        if let transactionBlockHeight = transaction["block_height"] as? Int, transactionBlockHeight > 0 {
                            let depthFromTip = UInt32(wallet.blockHeight) - UInt32(transactionBlockHeight)
                            
                            if depthFromTip == 0 {
                                confirmationStatus = "CONFIRMED"
                            }
                            if depthFromTip > 0 {
                                confirmationStatus = "FINAL"
                            }
                        }
                        transaction["confirmation_status"] = confirmationStatus
                        allTxs.append(transaction)
                    }
                    
                    if transactionsArray.count < count {
                        break
                    }
                    index += 1
                    
                } else {
                    result(FlutterError(code: "Invalid Transactions Format", message: "Transactions format is not as expected.", details: nil))
                    return
                }
            }
            
            result(allTxs)
            
        } catch let error as NSError {
            result(FlutterError(code: "Error Getting transactions", message: "Error getting transaction: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func sendToAddress(result: @escaping FlutterResult, mnemonic: String, pointer: Int64, connectionType: String, address: String, amount: Int64, assetId: String) {
        do {
            guard let wallet = try loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType) else {
                result(FlutterError(code: "LOGIN_ERROR", message: "Failed to login with mnemonic", details: nil))
                return
            }
            wallet.subaccountPointer = pointer
            let transaction = try wallet.sendToAddress(address: address, amount: amount, assetId: assetId)
            result(transaction)
        } catch let error as NSError {
            result(FlutterError(code: "SEND_ERROR", message: "Error sending transaction: \(error.localizedDescription)", details: nil))
        }
    }

    private func fetchAllSubAccounts(result: @escaping FlutterResult, mnemonic: String, connectionType: String) {
        do {
            guard let wallet = try loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType) else {
                result(FlutterError(code: "LOGIN_ERROR", message: "Failed to login with mnemonic", details: nil))
                return
            }
            let subAccounts = try wallet.fetchSubAccounts()
            result(subAccounts)
        } catch let error as NSError {
            result(FlutterError(code: "SUBACCOUNT_ERROR", message: "Error fetching subaccounts: \(error.localizedDescription)", details: nil))
        }
    }
}
