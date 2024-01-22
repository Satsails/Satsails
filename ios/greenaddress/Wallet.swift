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
        case "generateMnemonic":
            getMnemonic(result: result)
        case "newWalletSession":
            newWalletSession(result: result)
        case "createWallet":
            result("createWallet")
        case "getReceiveAddress":
            result("getReceiveAddress")
        case "getBalance":
            result("getBalance")
        case "createSubAccount":
            result("createSubAccount")
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
        let walletInit = GdkInit.defaults().run()
    }

    private func getMnemonic(result: @escaping FlutterResult) {
        let mnemonic = try? generateMnemonic12()
        result(mnemonic)
    }
    
    private func newWalletSession(result: @escaping FlutterResult){
        
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
