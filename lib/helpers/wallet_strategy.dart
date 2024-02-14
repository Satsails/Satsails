import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import '../../../helpers/networks.dart';
import '../../services/sideswap/sideswap_peg.dart';

class WalletStrategy {
  late SideswapPeg _webSocketService;
  late SideswapPegStatus _webSocketServiceStatus;
  late int fee;
  late String orderId;
  late String pegAddress;

  Stream<dynamic> get pegMessageStream => _webSocketService.messageStream;
  Stream<dynamic> get pegMessageStreamStatus => _webSocketServiceStatus.messageStream;

  void dispose() {
    _webSocketService.close();
  }

  Future<void> checkSideswapType(String sendingAsset, String receivingAsset, bool pegIn) async {
    const storage = FlutterSecureStorage();
    // String mnemonic = await storage.read(key: 'mnemonic') ?? '';
    String mnemonic = 'visa hole fiscal already fuel keen girl vault hand antique lesson tattoo';
    if (sendingAsset == "L-BTC" && receivingAsset == "BTC") {
      pegIn = true;
      Map<String, dynamic> getReceiveAddress = await greenwallet.Channel('ios_wallet').getReceiveAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network);
      _webSocketService = SideswapPeg();
      _webSocketService.connect(
        recv_addr: getReceiveAddress["address"],
        peg_in: pegIn,
      );
      Map<String, dynamic> message = await _webSocketService.messageStream.first;
      Map<String, dynamic> result = message["result"];
      orderId = result["order_id"];
      pegAddress = result["peg_addr"];

    } else if (sendingAsset == 'BTC' && receivingAsset == 'L-BTC') {
      pegIn = false;
      Map<String, dynamic> getReceiveAddress = await greenwallet.Channel('ios_wallet').getReceiveAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.bitcoinSS.network);
      _webSocketService = SideswapPeg();
      _webSocketService.connect(
        recv_addr: getReceiveAddress["address"],
        peg_in: pegIn,
      );
      Map<String, dynamic> message = await _webSocketService.messageStream.first;
      Map<String, dynamic> result = message["result"];
      orderId = result["order_id"];
      pegAddress = result["peg_addr"];
    }
  }

  // need to set the max to send as the balance of each type of asset
  // stream pegStatus to the frontend as text
  // on checkPegStatus initiate the transaction
  // stream to the frontend changes while having a spinner.
  // on success, stream to the frontend the success message (and store the exhange with all the data for the transactions)
  //
  // Future<void> checkPegStatus(String orderId, bool pegIn) async {
  //   _webSocketService = SideswapPegStatus();
  //   _webSocketService.connect(
  //     order_id: orderId,
  //     peg_in: pegIn,
  //   );
  //   await _webSocketService.messageStream.first; // Wait for the first message
  // }

//   Subscribe to price stream and return the price to the user on button click of convert
//   on click start conversion and check for swap done
//   Before swap is done need to upload utxos to the server of asset to be sent

// For transactions you need to have a checkbox of "i want to convert dollars if needed" where a sideswap transfer from usd to l-btc is done
// if the user has l-btc and wants to send btc or vice versa you will use sideswap to convert the asset.
// After asset is converted in sufficient amount you will use the wallet to send the asset
// for lightening addr you will use boltz api to convert btc and lbtc to lightening

// ----
}
