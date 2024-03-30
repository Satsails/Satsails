import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/balance_model.dart';

// // call btc and liquid balance to udpate balance every 5 seconds
// final balanceProvider = ChangeNotifierProvider<BalanceModel>((ref) {
//   return BalanceModel(
//     btcBalance: 0,
//     liquidBalance: 0,
//     brlBalance: 0,
//     usdBalance: 0,
//     cadBalance: 0,
//     eurBalance: 0,
//   );
// });