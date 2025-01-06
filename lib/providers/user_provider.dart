// this screen needs some heavy refactoring. On version "Unyielding conviction" we shall totally redo this spaghetti code.
import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/models/purchase_model.dart';
import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

final initializeUserProvider = FutureProvider<User>((ref) async {
  final box = await Hive.openBox('user');
  final hasInsertedAffiliate = box.get('hasInsertedAffiliate', defaultValue: false);
  final hasCreatedAffiliate = box.get('hasCreatedAffiliate', defaultValue: false);
  final paymentId = box.get('paymentId', defaultValue: '');
  final recoveryCode = await _storage.read(key: 'recoveryCode') ?? '';

  return User(
    hasInsertedAffiliate: hasInsertedAffiliate,
    hasCreatedAffiliate: hasCreatedAffiliate,
    recoveryCode: recoveryCode,
    paymentId: paymentId,
  );
});

final userProvider = StateNotifierProvider<UserModel, User>((ref) {
  final initialUser = ref.watch(initializeUserProvider);

  return UserModel(initialUser.when(
    data: (user) => user,
    loading: () => User(
      hasInsertedAffiliate: false,
      hasCreatedAffiliate: false,
      recoveryCode: '',
      paymentId: '',
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final createUserProvider = FutureProvider.autoDispose<void>((ref) async {
  final auth = await AuthModel().getBackendPassword();
  ref.read(userProvider.notifier).setRecoveryCode(auth!);
  final result = await UserService.createUserRequest(auth!);


  // if has saved affiliate code passed from the link without an account created
  if (result.isSuccess && result.data != null) {
    // add affilaite from link in case it was passed
    final affiliateCodeFromLink = ref.read(affiliateProvider).insertedAffiliateCode;
    if (affiliateCodeFromLink.isNotEmpty) {
      await ref.read(addAffiliateCodeProvider(affiliateCodeFromLink).future);
    }
    final user = result.data!;
    await ref.read(userProvider.notifier).setPaymentId(user.paymentId);
    await ref.read(userProvider.notifier).setRecoveryCode(user.recoveryCode);
  } else {
    await ref.read(setUserProvider.future);
  }
});

final setUserProvider = FutureProvider.autoDispose<void>((ref) async {
  // hammer in a fix
  ref.read(affiliateProvider);
  final auth = ref.read(userProvider).recoveryCode;
  final userResult = await UserService.showUser(auth);

  if (userResult.isSuccess && userResult.data != null) {
    final user = userResult.data!;
    await ref.read(userProvider.notifier).setPaymentId(user.paymentId);
    await ref.read(userProvider.notifier).setRecoveryCode(user.recoveryCode);
    await ref.read(affiliateProvider.notifier).setCreatedAffiliateCode(user.createdAffiliateCode ?? '');
    await ref.read(affiliateProvider.notifier).setLiquidAddress(user.createdAffiliateLiquidAddress ?? '');
    // search for affiliate code from the link in this state to add if user already exists and add it
    final affiliateCodeFromLink = ref.read(affiliateProvider).insertedAffiliateCode;
    if (affiliateCodeFromLink.isNotEmpty && !user.hasInsertedAffiliate) {
      await ref.read(addAffiliateCodeProvider(affiliateCodeFromLink).future);
    } else {
      await ref.read(affiliateProvider.notifier).setInsertedAffiliateCode(user.insertedAffiliateCode ?? '');
    }
    await ref.read(userProvider.notifier).setHasCreatedAffiliate(user.hasCreatedAffiliate);
    await ref.read(userProvider.notifier).setHasInsertedAffiliate(user.hasInsertedAffiliate);
  } else {
    await ref.read(userProvider.notifier).setRecoveryCode('');
    throw userResult.error!;
  }
});