import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eulenTransferProvider = StateNotifierProvider<EulenTransferNotifier, List<EulenTransfer>>((ref) {
  return EulenTransferNotifier();
});


final selectedEulenTransferIdProvider = StateProvider<int>((ref) => 0);

final singleEulenTransfersDetailsProvider = StateProvider.autoDispose<EulenTransfer>((ref) {
  final purchases = ref.watch(eulenTransferProvider.notifier);
  final id = ref.watch(selectedEulenTransferIdProvider);
  final purchase = purchases.getPurchaseById(id);
  return purchase;
});


final getEulenUserPurchasesProvider = FutureProvider.autoDispose<List<EulenTransfer>>((ref) async {
  final auth = ref.read(userProvider).jwt;
  final transactions = await EulenService.getTransfers(auth);

  if (transactions.isSuccess && transactions.data != null) {
    ref.read(eulenTransferProvider.notifier).mergePurchases(transactions.data!);
    return transactions.data!;
  } else {
    throw transactions.error!;
  }
});

final getAmountPurchasedProvider = FutureProvider.autoDispose<String>((ref) async {
  final auth = ref.read(userProvider).jwt;
  final amountTransferred = await EulenService.getAmountTransferred(auth);

  if (amountTransferred.isSuccess && amountTransferred.data != null) {
    return amountTransferred.data!;
  } else {
    throw amountTransferred.error!;
  }
});

final createEulenTransferRequestProvider = FutureProvider.autoDispose.family<EulenTransfer, int>((ref, amount) async {
  final auth = ref.read(userProvider).jwt;
  final liquidAddress = ref.read(addressProvider).liquidAddress;
  final result = await EulenService.createTransaction(auth, amount, liquidAddress);
  if (result.isSuccess && result.data != null) {
    ref.read(eulenTransferProvider.notifier).mergeTransfer(result.data!);
    return result.data!;
  } else {
    throw result.error!;
  }
});

final getEulenPixPaymentStateProvider = FutureProvider.autoDispose.family<bool, String>((ref, transactionId) async {
  final auth = ref.read(userProvider).jwt;
  final paymentState = await EulenService.getTransactionPaymentState(transactionId, auth);

  if (paymentState.isSuccess && paymentState.data != null) {
    if (paymentState.data!) {
      await ref.read(liquidSyncNotifierProvider.notifier).performSync();
    }
    return paymentState.data!;
  } else {
    throw paymentState.error!;
  }
});