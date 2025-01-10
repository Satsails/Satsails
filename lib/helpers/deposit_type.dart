import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DepositMethod { pix, credit_card, big_tech_pay, bank_transfer }
enum DepositType { depix, bitcoin, lightning_bitcoin, usdt }

final depositTypeProvider = StateProvider.autoDispose((ref) => DepositType.depix);
final depositMethodProvider = StateProvider.autoDispose((ref) => DepositMethod.pix);

final depositMethodBasedOnTypeProvider = StateProvider((ref) {
  final depositType = ref.watch(depositTypeProvider);

  switch (depositType) {
    case DepositType.depix:
      return {DepositMethod.pix};
    case DepositType.bitcoin:
      return {DepositMethod.pix};
    case DepositType.lightning_bitcoin:
      return {DepositMethod.pix};
    case DepositType.usdt:
      return {DepositMethod.pix};
    default:
      return {DepositMethod.pix};
  }
});