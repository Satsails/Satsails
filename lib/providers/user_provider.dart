import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

final initializeUserProvider = FutureProvider<User>((ref) async {
  final box = await Hive.openBox('user');
  final legacyBox = await Hive.openBox('affiliate');
  final legacyAffiliateCode = legacyBox.get('insertedAffiliateCode', defaultValue: '');
  final paymentId = box.get('paymentId', defaultValue: '');
  final affiliateCode = box.get('affiliateCode', defaultValue: '');

  final recoveryCode = await _storage.read(key: 'recoveryCode') ?? '';

  return User(
    recoveryCode: recoveryCode,
    paymentId: paymentId,
    affiliateCode: legacyAffiliateCode.isNotEmpty ? legacyAffiliateCode : affiliateCode,
  );
});

final userProvider = StateNotifierProvider<UserModel, User>((ref) {
  final initialUser = ref.watch(initializeUserProvider);

  return UserModel(initialUser.when(
    data: (user) => user,
    loading: () => User(
      affiliateCode: '',
      recoveryCode: '',
      paymentId: '',
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final addAffiliateCodeProvider = FutureProvider.autoDispose.family<void, String>((ref, affiliateCode) async {
  var paymentId = ref.read(userProvider).paymentId;
  final auth = ref.read(userProvider).recoveryCode;
  final result = await UserService.addAffiliateCode(paymentId, affiliateCode, auth);

  if (result.isSuccess && result.data == true) {
    ref.read(userProvider.notifier).setAffiliateCode(affiliateCode);
  } else {
    throw result.error!;
  }
});

final createUserProvider = FutureProvider.autoDispose<void>((ref) async {
  final auth = await AuthModel().getBackendPassword();
  ref.read(userProvider.notifier).setRecoveryCode(auth!);
  final result = await UserService.createUserRequest(auth!);

  // if has saved affiliate code passed from the link without an account created
  if (result.isSuccess && result.data != null) {
    // add affilaite from link in case it was passed
    final affiliateCodeFromLink = ref.read(userProvider).affiliateCode ?? '';
    if (affiliateCodeFromLink.isNotEmpty) {
      await ref.read(addAffiliateCodeProvider(affiliateCodeFromLink).future);
    }
    final user = result.data!;
    await ref.read(userProvider.notifier).setPaymentId(user.paymentId);
    await ref.read(userProvider.notifier).setRecoveryCode(user.recoveryCode);
    await ref.read(userProvider.notifier).setAffiliateCode(user.affiliateCode ?? '');
  } else {
    await ref.read(setUserProvider.future);
  }
});

final setUserProvider = FutureProvider.autoDispose<void>((ref) async {
  final auth = ref.read(userProvider).recoveryCode;
  final userResult = await UserService.showUser(auth);

  if (userResult.isSuccess && userResult.data != null) {
    final user = userResult.data!;
    await ref.read(userProvider.notifier).setPaymentId(user.paymentId);
    await ref.read(userProvider.notifier).setRecoveryCode(user.recoveryCode);
    await ref.read(userProvider.notifier).setAffiliateCode(user.affiliateCode ?? '');
    final affiliateCodeFromLink = ref.read(userProvider).affiliateCode ?? '';
    if (affiliateCodeFromLink.isNotEmpty && user.affiliateCode == null) {
      await ref.read(addAffiliateCodeProvider(affiliateCodeFromLink).future);
    }
  } else {
    await ref.read(userProvider.notifier).setRecoveryCode('');
    throw userResult.error!;
  }
});