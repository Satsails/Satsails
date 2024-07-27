import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class PixModel extends StateNotifier<Pix> {
  PixModel(super.pix);

  Future<void> setPixOnboarding(bool pixOnboardingStatus) async {
    final box = await Hive.openBox('pix');
    box.put('onboarding', pixOnboardingStatus);
    state = state.copyWith(pixOnboarding: pixOnboardingStatus);
  }
  Future<void> setPixPaymentCode(String paymentCode) async {
    final box = await Hive.openBox('pix');
    box.put('pixPaymentCode', paymentCode);
    state = state.copyWith(pixPaymentCode: paymentCode);
  }
}

class Pix{
  final bool pixOnboarding;
  final String pixPaymentCode;


  Pix({
    required this.pixOnboarding,
    required this.pixPaymentCode,
  }) : super();

  Pix copyWith({
    bool? pixOnboarding,
    String? pixPaymentCode,
  }) {
    return Pix(
      pixOnboarding: pixOnboarding ?? this.pixOnboarding,
      pixPaymentCode: pixPaymentCode ?? this.pixPaymentCode,
    );
  }
}