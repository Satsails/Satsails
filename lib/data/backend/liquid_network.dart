import 'package:satsails_wallet/wallet.dart';
import 'package:satsails_wallet/data/models/gdk_models.dart';

class LiquidNetwork extends WalletService {
  LiquidNetwork() : super() {
    networkName = 'Liquid';
  }

  @override
  Future<bool> connect({
    GdkConnectionParams connectionParams = const GdkConnectionParams(
      name: 'electrum-testnet-liquid',
    ),
  }) async {
    return super.connect(connectionParams: connectionParams);
  }
}
