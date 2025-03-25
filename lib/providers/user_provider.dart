import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/models/firebase_model.dart';
import 'package:Satsails/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

final initializeUserProvider = FutureProvider<User>((ref) async {
  final box = await Hive.openBox('user');
  final paymentId = box.get('paymentId', defaultValue: '');
  final affiliateCode = box.get('affiliateCode', defaultValue: '');
  final hasUploadedAffiliateCode = box.get('hasUploadedAffiliateCode', defaultValue: false);
  final jwt = await _storage.read(key: 'backendJwt') ?? '';
  final recoveryCode = await _storage.read(key: 'recoveryCode') ?? '';

  return User(
    recoveryCode: recoveryCode,
    paymentId: paymentId,
    affiliateCode: affiliateCode,
    hasUploadedAffiliateCode: hasUploadedAffiliateCode ?? false,
    jwt: jwt,
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
      jwt: '',
      hasUploadedAffiliateCode: false,
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final addAffiliateCodeProvider = FutureProvider.autoDispose.family<void, String>((ref, affiliateCode) async {
  final auth = ref.read(userProvider).jwt;
  final result = await UserService.addAffiliateCode(affiliateCode, auth);

  if (result.isSuccess && result.data == true) {
    ref.read(userProvider.notifier).setAffiliateCode(affiliateCode);
    ref.read(userProvider.notifier).setHasUploadedAffiliateCode(true);
  } else {
    ref.read(userProvider.notifier).setAffiliateCode('');
    throw result.error!;
  }
});

final fetchBackendChallangeProvider = FutureProvider.autoDispose<String>((ref) async {
  final result = await BackendAuth.fetchChallenge();
  if (result.isSuccess && result.data != null) {
    return result.data!;
  } else {
    throw result.error!;
  }
});

final createUserProvider = FutureProvider.autoDispose<void>((ref) async {
  final challenge = await ref.read(fetchBackendChallangeProvider.future);
  final signedChallenge = await BackendAuth.signChallengeWithPrivateKey(challenge);
  final result = await UserService.createUserRequest(challenge, signedChallenge!);

  if (result.isSuccess && result.data != null) {
    final affiliateCodeFromLink = ref.read(userProvider).affiliateCode ?? '';
    final user = result.data!;
    await ref.read(userProvider.notifier).setPaymentId(user.paymentId);
    await ref.read(userProvider.notifier).setJwt(user.jwt);
    await ref.read(userProvider.notifier).setAffiliateCode(user.affiliateCode ?? '');
    await FirebaseService.storeTokenOnbackend();
    if (affiliateCodeFromLink.isNotEmpty) {
      await ref.read(addAffiliateCodeProvider(affiliateCodeFromLink).future);
    }
  } else {
    throw result.error!;
  }
});

// delete after migrations
final migrateUserToJwtProvider = FutureProvider.autoDispose<void>((ref) async {
  final challenge = await ref.read(fetchBackendChallangeProvider.future);
  final signedChallenge = await BackendAuth.signChallengeWithPrivateKey(challenge);
  final recoveryCode = ref.read(userProvider).recoveryCode;
  final result = await UserService.migrateToJWT(recoveryCode!, challenge, signedChallenge!);

  if (result.isSuccess && result.data != null) {
    ref.read(userProvider.notifier).setJwt(result.data!);
    ref.read(userProvider.notifier).setRecoveryCode('');
    await FirebaseService.storeTokenOnbackend();
  } else {
    throw result.error!;
  }
});