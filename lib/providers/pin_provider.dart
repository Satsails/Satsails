import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/pin_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final pinProvider = FutureProvider.autoDispose<PinModel>((ref) async {
  const storage = FlutterSecureStorage();
  final pin = await storage.read(key: 'pin');

  return PinModel(pin: pin ?? '');
});

final setPinProvider = FutureProvider.autoDispose<void>((ref) async {
  final pin = await ref.read(pinProvider.future);

  await pin.setPin();
});