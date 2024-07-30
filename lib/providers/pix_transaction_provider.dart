import 'dart:ui';
import 'package:Satsails/providers/pix_provider.dart';
import 'package:Satsails/services/backend/satsails.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleStateProvider = StateProvider.autoDispose<AppLifecycleState>((ref) => AppLifecycleState.resumed);

final pixTransactionReceivedProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  ref.watch(appLifecycleStateProvider);
  final paymentId = ref.read(pixProvider).pixPaymentCode;
  final service = Satsails();
  service.connect(paymentId);

  ref.onDispose(() => service.dispose(paymentId));

  return service.loginStream.map((event) => event);
});
