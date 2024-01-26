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
                  let connectionType = args["connectionType"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Mnemonic or connectionType not provided", details: nil))
                return
            }
            createWallet(mnemonic: mnemonic, connectionType: connectionType, result: result)
        case "getReceiveAddress":
            result("getReceiveAddress")
        case "getBalance":
            result("getBalance")
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
        case "getSubAccounts":
            result("getSubAccounts")
        case "getSubAccount":
            result("getSubAccount")
        case "getTransactions":
            result("getTransactions")
        case "createTransaction":
            result("createTransaction")
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
    
    private func loginWithMnemonic(mnemonic: String, connectionType: String) -> GDKWallet? {
            let wallet = try? GDKWallet.loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType)
        return wallet
    }
    
    private func createWallet(mnemonic: String, connectionType: String, result: @escaping FlutterResult) {
        do {
            let wallet = try GDKWallet.createNewWallet(mnemonic: mnemonic, connectionType: connectionType)
            do {
                let subAccount = try wallet.fetchSubaccount(subAccountName: "", subAccountType: "")
            } catch {
                result(FlutterError(code: "SUBACCOUNT_ERROR", message: "Failed to fetch subaccount", details: nil))
            };
            let walletInfo: [String: Any] = ["gaid": wallet.greenAccountID, "mnemonic": wallet.mnemonic ?? ""]
            result(walletInfo)
            
        } catch {
            result(FlutterError(code: "WALLET_CREATION_ERROR", message: "Failed to create wallet", details: nil))
        }
        
    }


    

    private func createSubAccount(result: @escaping FlutterResult, name: String, walletType: String, mnemonic: String, connectionType: String) {
//        return created wallet
//        do {
//            let wallet = loginWithMnemonic(mnemonic: mnemonic, connectionType: connectionType)
//            let createSubAccountParams = CreateSubaccountParams(name: name, type: .standard)
//            let createSubAccount: () = try? wallet.createSubAccount(params: createSubAccountParams)
//        } catch {
//            result(FlutterError(code: "SUBACCOUNT_CREATION_ERROR", message: "Failed to create subaccount", details: nil))
//        }
    }



//        do {
//            let newWallet = try GDKWallet.createNewWallet(createWith2FAEnabled: false)
//            let createSubAccountParams = CreateSubaccountParams(name: "btc1231", type: .segWit)
//            let createSubAccount = try? newWallet.createSubAccount(params: createSubAccountParams)
//            let subAccount = try? newWallet.fetchSubaccount(subAccountName: "btc123", subAccountType: AccountType.segWit.rawValue)
//            let receiveAddress = try? newWallet.getReceiveAddress()
//
//            result(receiveAddress)
//        } catch {
//            result("WALLET_CREATION_ERROR: Failed to create wallet")
//        }
}
