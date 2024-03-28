import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails_wallet/models/bitcoin_model.dart';

final bitcoinProvider = ChangeNotifierProvider<BitcoinModel>((ref) {
  return BitcoinModel();
});