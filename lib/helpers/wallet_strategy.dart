import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import '../../../helpers/networks.dart';
import '../../services/sideswap/sideswap_peg.dart';


class WalletStrategy{
  late SideswapPeg _webSocketService;
  late int fee;


  void dispose() {
    _webSocketService.close();
  }

 void convertForTransaction(String sendingAsset, String receivingAsset, bool pegIn) async {
    await checkSideswapType(sendingAsset, receivingAsset, pegIn);
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
    } else if (sendingAsset == 'BTC' && receivingAsset == 'L-BTC'){
      pegIn = false;
      Map<String, dynamic> getReceiveAddress = await greenwallet.Channel('ios_wallet').getReceiveAddress(mnemonic: mnemonic, connectionType: NetworkSecurityCase.bitcoinSS.network);
      _webSocketService = SideswapPeg();
      _webSocketService.connect(
        recv_addr: getReceiveAddress["address"],
        peg_in: pegIn,
      );
    }
  }

  Future<void> checkPegStatus(String order_id, bool pegIn) async {
    _webSocketService = SideswapPeg();
    _webSocketService.connect(
      order_id: order_id,
      peg_in: pegIn,
    );
  }
}