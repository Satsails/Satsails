import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/providers/pix_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createUserProvider = FutureProvider.autoDispose.family<String, UserArguments>((ref, userArguments) async {
  return await UserService().createUserRequest(userArguments.paymentId, userArguments.liquidAddress);
});

final getUserTransactionsProvider = FutureProvider.autoDispose<List<Transfer>>((ref) async {
  final paymentId = ref.read(pixProvider).pixPaymentCode;
  return await UserService().getUserTransactions(paymentId);
});

final getAmountTransferredProvider = FutureProvider.autoDispose<String>((ref) async {
  final paymentId = ref.read(pixProvider).pixPaymentCode;
  return await UserService().getAmountTransferred(paymentId);
});
