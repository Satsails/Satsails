import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:random_string/random_string.dart';

class PixModel extends StateNotifier<Pix> {
  PixModel(super.pix);

  Future<void> setPixOnboarding(bool pixOnboardingStatus) async {
    final box = await Hive.openBox('pix');
    box.put('onboarding', pixOnboardingStatus);
    state = state.copyWith(pixOnboarding: pixOnboardingStatus);
  }
  Future<String> setPixPaymentCode() async {
    String paymentCode = randomAlphaNumeric(10);
    final box = await Hive.openBox('pix');
    box.put('pixPaymentCode', paymentCode);
    state = state.copyWith(pixPaymentCode: paymentCode);
    return paymentCode;
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