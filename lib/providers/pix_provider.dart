import 'package:Satsails/models/pix_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final initialPixProvider = FutureProvider.autoDispose<Pix>((ref) async {
  final box = await Hive.openBox('pix');
  final pixOnboarding = box.get('onboarding', defaultValue: false);
  final pixPaymentCode = box.get('pixPaymentCode', defaultValue: '');

  return Pix(pixOnboarding: pixOnboarding, pixPaymentCode: pixPaymentCode);
});

final pixProvider = StateNotifierProvider.autoDispose<PixModel, Pix>((ref) {
  final initialPix = ref.watch(initialPixProvider);

  return PixModel(initialPix.when(
    data: (pix) => pix,
    loading: () => Pix(pixOnboarding: false, pixPaymentCode: ''),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});