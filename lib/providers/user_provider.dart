// this screen needs some heavy refactoring. On version "Unyielding conviction" we shall totally redo this spaghetti code.
import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/models/transfer_model.dart';
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
  final depixLiquidAddress = box.get('depixLiquidAddress', defaultValue: '');
  final paymentId = box.get('paymentId', defaultValue: '');
  final recoveryCode = await _storage.read(key: 'recoveryCode') ?? '';
  final onboarded = box.get('onboarding', defaultValue: false);

  return User(
    hasInsertedAffiliate: hasInsertedAffiliate,
    hasCreatedAffiliate: hasCreatedAffiliate,
    depixLiquidAddress: depixLiquidAddress,
    recoveryCode: recoveryCode,
    paymentId: paymentId,
    onboarded: onboarded,
  );
});

final userProvider = StateNotifierProvider<UserModel, User>((ref) {
  final initialUser = ref.watch(initializeUserProvider);

  return UserModel(initialUser.when(
    data: (user) => user,
    loading: () => User(
      hasInsertedAffiliate: false,
      depixLiquidAddress: '',
      hasCreatedAffiliate: false,
      recoveryCode: '',
      paymentId: '',
      onboarded: false,
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final createUserProvider = FutureProvider.autoDispose<void>((ref) async {
  final liquidAddress = await ref.read(liquidAddressProvider.future);
  final auth = await AuthModel().getBackendPassword();
  ref.read(userProvider.notifier).setRecoveryCode(auth!);
  final result = await UserService.createUserRequest(liquidAddress.confidential, liquidAddress.index, auth!);


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
    await ref.read(userProvider.notifier).setDepixLiquidAddress(user.depixLiquidAddress);
  } else {
    await ref.read(setUserProvider.future);
  }
});

final getUserTransactionsProvider = FutureProvider.autoDispose<List<Transfer>>((ref) async {
  final paymentId = ref.read(userProvider).paymentId;
  final auth = ref.read(userProvider).recoveryCode;
  final transactions = await UserService.getUserTransactions(paymentId, auth);

  if (transactions.isSuccess && transactions.data != null) {
    return transactions.data!;
  } else {
    throw transactions.error!;
  }
});

final getAmountTransferredProvider = FutureProvider.autoDispose<String>((ref) async {
  final paymentId = ref.read(userProvider).paymentId;
  final auth = ref.read(userProvider).recoveryCode;
  final amountTransferred = await UserService.getAmountTransferred(paymentId, auth);

  if (amountTransferred.isSuccess && amountTransferred.data != null) {
    return amountTransferred.data!;
  } else {
    throw amountTransferred.error!;
  }
});


final updateLiquidAddressProvider = FutureProvider.autoDispose<String>((ref) async {
  final liquidAddress = await ref.read(liquidAddressProvider.future);
  final auth = ref.read(userProvider).recoveryCode;
  final result = await UserService.updateLiquidAddress(liquidAddress.confidential, auth, liquidAddress.index);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});

final setUserProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.read(updateLiquidAddressProvider.future);
  // hammer in a fix
  ref.read(affiliateProvider);
  final auth = ref.read(userProvider).recoveryCode;
  final userResult = await UserService.showUser(auth);

  if (userResult.isSuccess && userResult.data != null) {
    final user = userResult.data!;
    await ref.read(userProvider.notifier).setPaymentId(user.paymentId);
    await ref.read(userProvider.notifier).setRecoveryCode(user.recoveryCode);
    await ref.read(userProvider.notifier).setDepixLiquidAddress(user.depixLiquidAddress);
    await ref.read(affiliateProvider.notifier).setCreatedAffiliateCode(user.createdAffiliateCode ?? '');
    await ref.read(affiliateProvider.notifier).setLiquidAddress(user.createdAffiliateLiquidAddress ?? '');
    // search for affiliate code from the link in this state to add if user already exists and add it
    final affiliateCodeFromLink = ref.read(affiliateProvider).insertedAffiliateCode;
    if (affiliateCodeFromLink.isNotEmpty) {
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

final getLiquidAddressIndexProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final auth = ref.read(userProvider).recoveryCode;
  final result = await UserService.getLiquidAddressIndex(auth);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});

final checkIfAccountBelongsToSetPrivateKeyProvider = FutureProvider.autoDispose<bool>((ref) async {
  final registeredAddress = await ref.read(getLiquidAddressIndexProvider.future);
  final walletLiquidAddress = await ref.read(liquidAddressOfIndexProvider(registeredAddress['liquid_address_index']).future);
  if (walletLiquidAddress == registeredAddress['liquid_address']) {
    return true;
  } else {
    return false;
  }
});

// final deleteUserDataProvider = FutureProvider.autoDispose<void>((ref) async {
//   final auth = ref.read(userProvider).recoveryCode;
//   final result = await UserService.deleteUser(auth);
//
//   if (result.isSuccess) {
//     await ref.read(userProvider.notifier).setPaymentId('');
//     await ref.read(userProvider.notifier).setRecoveryCode('');
//     await ref.read(userProvider.notifier).setDepixLiquidAddress('');
//     await ref.read(affiliateProvider.notifier).setCreatedAffiliateCode('');
//     await ref.read(affiliateProvider.notifier).setInsertedAffiliateCode('');
//     await ref.read(userProvider.notifier).setHasCreatedAffiliate(false);
//     await ref.read(userProvider.notifier).setHasInsertedAffiliate(false);
//   } else {
//     throw result.error!;
//   }
// });