import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/pix_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final initializeUserProvider = FutureProvider.autoDispose<User>((ref) async {
  final box = await Hive.openBox('user');
  final affiliateCode = box.get('affiliateCode', defaultValue: '');
  final hasAffiliate = box.get('hasAffiliate', defaultValue: false);
  final hasCreatedAffiliate = box.get('hasCreatedAffiliate', defaultValue: false);

  return User(affiliateCode: affiliateCode, hasAffiliate: hasAffiliate, hasCreatedAffiliate: hasCreatedAffiliate);
});

final userProvider = StateNotifierProvider.autoDispose<UserModel, User>((ref) {
  final initialUser = ref.watch(initializeUserProvider);

  return UserModel(initialUser.when(
    data: (user) => user,
    loading: () => User(affiliateCode: '', hasAffiliate: false, hasCreatedAffiliate: false),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final createUserProvider = FutureProvider.autoDispose<String>((ref) async {
  final liquidAddress = await ref.read(liquidAddressProvider.future);
  final user = await UserService().createUserRequest(liquidAddress.confidential);
  await ref.read(pixProvider.notifier).setPixPaymentCode(user);
  final paymentId = ref.read(pixProvider).pixPaymentCode;
  return paymentId;
});

final getUserTransactionsProvider = FutureProvider.autoDispose<List<Transfer>>((ref) async {
  final paymentId = ref.read(pixProvider).pixPaymentCode;
  return await UserService().getUserTransactions(paymentId);
});

final getAmountTransferredProvider = FutureProvider.autoDispose<String>((ref) async {
  final paymentId = ref.read(pixProvider).pixPaymentCode;
  return await UserService().getAmountTransferred(paymentId);
});

final addAffiliateCodeProvider = FutureProvider.autoDispose<void>((ref) async {
  var paymentId = ref.read(pixProvider).pixPaymentCode;
  if (paymentId == "") {
    paymentId = await ref.read(createUserProvider.future);
  }
  final affiliateCode = ref.read(userProvider).affiliateCode;
  await UserService().addAffiliateCode(paymentId, affiliateCode);
  ref.read(userProvider.notifier).setHasAffiliate(true);
});

final createAffiliateCodeProvider = FutureProvider.autoDispose.family<void, String>((ref, affiliateCode) async {
  var paymentId = ref.read(pixProvider).pixPaymentCode;
  if (paymentId == "") {
    paymentId = await ref.read(createUserProvider.future);
  }
  final setAffiliateCode = await ref.read(userProvider.notifier).setAffiliateCode(affiliateCode);
  await UserService().createAffiliateCode(paymentId, setAffiliateCode);
  ref.read(userProvider.notifier).setHasCreatedAffiliate(true);
});

final numberOfAffiliateInstallsProvider = FutureProvider.autoDispose<int>((ref) async {
  final affiliateCode = ref.watch(userProvider).affiliateCode;
  return await UserService().affiliateNumberOfUsers(affiliateCode);
});

final affiliateEarningsProvider = FutureProvider.autoDispose<String>((ref) async {
  final affiliateCode = ref.watch(userProvider).affiliateCode;
  return await UserService().affiliateEarnings(affiliateCode);
});
