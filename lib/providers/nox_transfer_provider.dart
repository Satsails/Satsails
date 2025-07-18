import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noxTransferProvider = StateNotifierProvider<NoxTransferNotifier, List<NoxTransfer>>((ref) {
  return NoxTransferNotifier();
});


final selectedNoxTransferIdProvider = StateProvider<int>((ref) => 0);

final singleNoxTransfersDetailsProvider = StateProvider.autoDispose<NoxTransfer>((ref) {
  final purchases = ref.watch(noxTransferProvider.notifier);
  final id = ref.watch(selectedNoxTransferIdProvider);
  final purchase = purchases.getPurchaseById(id);
  return purchase;
});


final getNoxUserPurchasesProvider = FutureProvider.autoDispose<List<NoxTransfer>>((ref) async {
  final auth = ref.read(userProvider).jwt;
  final transactions = await NoxService.getTransfers(auth);

  if (transactions.isSuccess && transactions.data != null) {
    ref.read(noxTransferProvider.notifier).mergePurchases(transactions.data!);
    return transactions.data!;
  } else {
    throw transactions.error!;
  }
});


final createNoxTransferRequestProvider = FutureProvider.autoDispose.family<String, ({int amount, String address})>((ref, params) async {
  final auth = ref.read(userProvider).jwt;
  final result = await NoxService.createTransaction(auth, params.address, params.amount * 100);
  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});