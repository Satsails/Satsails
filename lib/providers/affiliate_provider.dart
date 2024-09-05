import 'package:Satsails/models/affiliate_model.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final initializeAffiliateProvider = FutureProvider<Affiliate>((ref) async {
  final box = await Hive.openBox('affiliate');
  final insertedAffiliate = box.get('insertedAffiliateCode', defaultValue: '');
  final createdAffiliate = box.get('createdAffiliateCode', defaultValue: '');
  final liquidAddress = box.get('liquidAddress', defaultValue: '');

  return Affiliate(createdAffiliateCode: createdAffiliate, insertedAffiliateCode: insertedAffiliate, createdAffiliateLiquidAddress: liquidAddress);
});

final affiliateProvider = StateNotifierProvider<AffiliateModel, Affiliate>((ref) {
  final initialAffiliate = ref.watch(initializeAffiliateProvider);

  return AffiliateModel(initialAffiliate.when(
    data: (affiliate) => affiliate,
    loading: () => Affiliate(createdAffiliateCode: '', insertedAffiliateCode: '', createdAffiliateLiquidAddress: ''),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final addAffiliateCodeProvider = FutureProvider.autoDispose.family<void, String>((ref, affiliateCode) async {
  var paymentId = ref.read(userProvider).paymentId;
  final auth = ref.read(userProvider).recoveryCode;
  final result = await AffiliateService.addAffiliateCode(paymentId, affiliateCode, auth);

  if (result.isSuccess && result.data == true) {
    await ref.read(userProvider.notifier).setHasInsertedAffiliate(true);
    await ref.read(affiliateProvider.notifier).setInsertedAffiliateCode(affiliateCode);
  } else {
    throw result.error!;
  }
});

final createAffiliateCodeProvider = FutureProvider.autoDispose.family<void, Affiliate>((ref, affiliate) async {
  var paymentId = ref.read(userProvider).paymentId;
  final auth = ref.read(userProvider).recoveryCode;
  final result = await AffiliateService.createAffiliateCode(paymentId, affiliate.createdAffiliateCode, affiliate.createdAffiliateLiquidAddress, auth);

  if (result.isSuccess && result.data == true) {
    await ref.read(userProvider.notifier).setHasCreatedAffiliate(true);
    await ref.read(affiliateProvider.notifier).setCreatedAffiliateCode(affiliate.createdAffiliateCode);
    await ref.read(affiliateProvider.notifier).setLiquidAddress(affiliate.createdAffiliateLiquidAddress);
  } else {
    throw result.error!;
  }
});

final affiliateEarningsProvider = FutureProvider.autoDispose<String>((ref) async {
  final affiliateCode = ref.watch(affiliateProvider).createdAffiliateCode;
  final auth = ref.read(userProvider).recoveryCode;
  final result = await AffiliateService.affiliateEarnings(affiliateCode, auth);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});


final getTotalValuePurchasedByAffiliateUsersProvider = FutureProvider.autoDispose<String>((ref) async {
  final auth = ref.read(userProvider).recoveryCode;
  final affiliateCode = ref.read(affiliateProvider).createdAffiliateLiquidAddress;
  final result = await AffiliateService.affiliateUsersSpend(affiliateCode, auth);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});

final getAllTransfersFromAffiliateUsersProvider = FutureProvider.autoDispose<List<ParsedTransfer>>((ref) async {
  final auth = ref.read(userProvider).recoveryCode;
  final affiliateCode = ref.read(affiliateProvider).createdAffiliateCode;
  final result = await AffiliateService.getAllTransfersFromAffiliateUsers(affiliateCode, auth);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});

final numberOfAffiliateInstallsProvider = FutureProvider.autoDispose<int>((ref) async {
  final affiliateCode = ref.watch(affiliateProvider).createdAffiliateCode;
  final auth = ref.read(userProvider).recoveryCode;
  final numberOfUsers = await AffiliateService.affiliateNumberOfUsers(affiliateCode, auth);

  if (numberOfUsers.isSuccess && numberOfUsers.data != null) {
    return numberOfUsers.data!;
  } else {
    throw numberOfUsers.error!;
  }
});