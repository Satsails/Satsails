import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/helpers/validate_address.dart';

enum PaymentType {
  Bitcoin,
  Liquid,
  Lightning,
  Unknown
}

final sendPaymentProvider = StateProvider<PaymentType>((ref) => PaymentType.Bitcoin);

final addressTypeProvider = StateProvider.family<PaymentType, String>((ref, address) {
  if (isValidBitcoinAddress(address)) {
    return PaymentType.Bitcoin;
  } else if (isValidLiquidAddress(address)) {
    return PaymentType.Liquid;
  } else {
    return PaymentType.Unknown;
  }
});

