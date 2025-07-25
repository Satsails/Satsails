import 'package:Satsails/models/breez/init.dart';
import 'package:Satsails/models/breez/sdk_instance.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final breezSDKProvider = FutureProvider<BreezSDKLiquid>((ref) async {
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  if (mnemonic == null || mnemonic.isEmpty) {
    throw Exception('Mnemonic is not available.');
  }

  await initializeSDK(mnemonic);

  return breezSDKLiquid;
});