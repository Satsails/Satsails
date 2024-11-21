import 'package:Satsails/models/affiliate_model.dart';
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