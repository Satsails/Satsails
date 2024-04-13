import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentTYpe {
  Bitcoin,
  Liquid,
  Lightning,
  Unknown
}

final sendPaymentProvider = StateProvider<PaymentTYpe>((ref) => PaymentTYpe.Bitcoin);