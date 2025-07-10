import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';

final transactionNotifierProvider =
AsyncNotifierProvider<TransactionNotifier, Transaction>(
  TransactionNotifier.new,
);




final getFiatPurchasesProvider = FutureProvider.autoDispose<void>((ref) async {
  await Future.wait([
    ref.read(getNoxUserPurchasesProvider.future).catchError((e) {
      return null;
    }),
    ref.read(getEulenUserPurchasesProvider.future).catchError((e) {
      return null;
    }),
  ]);
});