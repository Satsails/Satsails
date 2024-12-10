import 'package:Satsails/models/purchase_model.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final initialPurchaseProvider = FutureProvider<List<Purchase>>((ref) async {
  final purchaseBox = await Hive.openBox<Purchase>('purchasesBox');

  final purchases = purchaseBox.values.toList();
  return purchases;
});

final purchaseProvider = StateNotifierProvider<PurchaseNotifier, List<Purchase>>((ref) {
  final initialPurchases = ref.watch(initialPurchaseProvider);

  return initialPurchases.when(
    data: (purchases) => PurchaseNotifier(purchases),
    loading: () => PurchaseNotifier([]),
    error: (error, stackTrace) {
      throw error;
    },
  );
});

final selectedPurchaseIdProvider = StateProvider<int>((ref) => 0);

final singlePurchaseDetailsProvider = StateProvider.autoDispose<Purchase>((ref) {
  final purchases = ref.watch(purchaseProvider.notifier);
  final id = ref.watch(selectedPurchaseIdProvider);
  final purchase = purchases.getPurchaseById(id);
  return purchase;
});


final getUserPurchasesProvider = FutureProvider.autoDispose<List<Purchase>>((ref) async {
  final paymentId = ref.read(userProvider).paymentId;
  final auth = ref.read(userProvider).recoveryCode;
  final transactions = await PurchaseService.getUserPurchases(paymentId, auth);

  if (transactions.isSuccess && transactions.data != null) {
    ref.read(purchaseProvider.notifier).setPurchases(transactions.data!);
    return transactions.data!;
  } else {
    throw transactions.error!;
  }
});

final getAmountPurchasedProvider = FutureProvider.autoDispose<String>((ref) async {
  final paymentId = ref.read(userProvider).paymentId;
  final auth = ref.read(userProvider).recoveryCode;
  final amountTransferred = await PurchaseService.getAmountPurchased(paymentId, auth);

  if (amountTransferred.isSuccess && amountTransferred.data != null) {
    return amountTransferred.data!;
  } else {
    throw amountTransferred.error!;
  }
});

final createPurchaseRequestProvider = FutureProvider.autoDispose.family<Purchase, PurchaseParams>((ref, params) async {
  final auth = ref.read(userProvider).recoveryCode;
  final result = await PurchaseService.createPurchaseRequest(auth, params);
  await ref.watch(getUserPurchasesProvider.future);
  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});

final getMinimumPurchaseProvider = FutureProvider.autoDispose<String>((ref) async {
  final auth = ref.read(userProvider).recoveryCode;
  final result = await PurchaseService.getMinimumPurchase(auth);
  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});

