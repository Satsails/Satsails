import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../helpers/asset_mapper.dart';
import '../../services/sideswap/sideswap_peg.dart';
import '../../services/sideswap/sideswap_exchange.dart';


class WalletStrategy {
  late SideswapPeg _webSocketService = SideswapPeg();
  late SideswapPegStatus _webSocketServiceStatus = SideswapPegStatus();
  late SideswapStreamPrices _webSocketPriceStream = SideswapStreamPrices();
  late SideswapStartExchange _webSocketStartExchange = SideswapStartExchange();
  late SideswapUploadData uploadData = SideswapUploadData();
  late int fee;
  late String orderId;
  late String pegAddress;
  late String sendToAddr;

  Stream<dynamic> get pegMessageStream => _webSocketService.messageStream;
  Stream<dynamic> get pegMessageStreamStatus => _webSocketServiceStatus.messageStream;

  void dispose() {
    _webSocketService.close();
    _webSocketServiceStatus.close();
    _webSocketPriceStream.close();
    _webSocketStartExchange.close();

  }

  Future<Map<String, dynamic>> checkSideswapType(String sendingAsset, String receivingAsset, bool pegIn, int amount) async {
    const storage = FlutterSecureStorage();
    String mnemonic = await storage.read(key: 'mnemonic') ?? '';

    if (sendingAsset == "L-BTC" && receivingAsset == "BTC") {
      pegIn = false;
      // Map<String, dynamic> getReceiveAddress = await greenwallet.Channel('ios_wallet').getReceiveAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.bitcoinSS.network);
      Map<String, dynamic> getReceiveAddress = {};
      _webSocketService.connect(
        recv_addr: getReceiveAddress["address"],
        peg_in: pegIn,
      );
      Map<String, dynamic> message = await _webSocketService.messageStream.first;
      orderId = message["result"]["order_id"];
      pegAddress = message["result"]["peg_addr"];
      // sendToAddr = await greenwallet.Channel('ios_wallet').sendToAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network, address: pegAddress, amount: amount, assetId: AssetMapper().reverseMapTicker('L-BTC'));
      sendToAddr = '';
    } else if (sendingAsset == 'BTC' && receivingAsset == 'L-BTC') {
      pegIn = true;
      // Map<String, dynamic> getReceiveAddress = await greenwallet.Channel('ios_wallet').getReceiveAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network);
      Map<String, dynamic> getReceiveAddress = {};
      _webSocketService.connect(
        recv_addr: getReceiveAddress["address"],
        peg_in: pegIn,
      );
      Map<String, dynamic> message = await _webSocketService.messageStream.first;
      orderId = message["result"]["order_id"];
      pegAddress = message["result"]["peg_addr"];
      // sendToAddr = await greenwallet.Channel('ios_wallet').sendToAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.bitcoinSS.network, address: pegAddress, amount: amount);
    }
    return {
      "order_id": orderId,
      "peg_addr": pegAddress,
      "txid": sendToAddr,
    };
  }

  Stream <dynamic> checkPegStatus(String orderId, bool pegIn) {
    _webSocketServiceStatus.connect(
      orderId: orderId,
      pegIn: pegIn,
    );
     return _webSocketServiceStatus.messageStream;
  }

  Stream<dynamic> startSwap(bool sendBitcoins, int sendAmount,int recvAmount, String asset, double price) {
    _webSocketStartExchange.connect(
      asset: asset,
      sendBitcoins: sendBitcoins,
      price: price,
      recvAmount: recvAmount,
      sendAmount: sendAmount,
    );
    return _webSocketStartExchange.messageStream;
  }

  Future<Map<String, dynamic>> inputBuilder(String mnemonic, String asset, int valueToSend) async {
    // Map<String, dynamic> inputs = await greenwallet.Channel('ios_wallet').getUTXOS(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network);
    Map<String, dynamic> inputs = {};
    int totalValue = 0;

    Map<String, dynamic> utxos = {
      "utxos": [],
    };

    if (inputs["utxos"][asset].length > 0) {
      for (var j = 0; j < inputs["utxos"][asset].length; j++) {
        utxos["utxos"].add({
          "asset": inputs["utxos"][asset][j]["asset_id"],
          "asset_bf": inputs["utxos"][asset][j]["assetblinder"],
          "redeem_script": inputs["utxos"][asset][j]["prevout_script"],
          "txid": inputs["utxos"][asset][j]["txhash"],
          "value": inputs["utxos"][asset][j]["satoshi"],
          "value_bf": inputs["utxos"][asset][j]["amountblinder"],
          "vout": inputs["utxos"][asset][j]["pt_idx"],
        });
        totalValue += inputs["utxos"][asset][j]["satoshi"] as int;

        if (totalValue > valueToSend) {
          break;
        }
      }
    }
    return utxos;
  }

  Future<void> uploadAndSignInputs(Map<String, dynamic> params) async {
    const storage = FlutterSecureStorage();
    String mnemonic = await storage.read(key: 'mnemonic') ?? '';
    // Map<String, dynamic> returnAddress = await greenwallet.Channel('ios_wallet').getReceiveAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network, isInternal: true);
    // Map<String, dynamic> receiveAddress = await greenwallet.Channel('ios_wallet').getReceiveAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network);
    Map<String, dynamic> returnAddress = {};
    Map<String, dynamic> receiveAddress = {};
    // change here to make it work if it fails
    // Map<String, dynamic> previousAddresses = await greenwallet.Channel('ios_wallet').getPreviousAddresses(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network);
    Map<String, dynamic> inputs = await inputBuilder(mnemonic, params["result"]["send_asset"], params["result"]["send_amount"]);
    await uploadData.uploadInputs(params,  returnAddress["address"], inputs, receiveAddress);
  }

  Future<void> signInputs(Map<String, dynamic> params, String orderId, Uri uri, String asset) async {
    const storage = FlutterSecureStorage();
    String mnemonic = await storage.read(key: 'mnemonic') ?? '';
    // Map<String, dynamic> signedTransaction = await greenwallet.Channel('ios_wallet').signTransaction(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network, transaction: params["result"]["pset"], asset: asset);
    Map<String, dynamic> signedTransaction = {};
    // check ammounts in previous call as problem might be there, otherwise contact the guy
    await uploadData.signInputs(signedTransaction["psbt"], orderId, params["result"]["submit_id"], uri);
  }
}
