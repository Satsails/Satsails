import 'package:Satsails/providers/breez_config_provider.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final breezLiquidBalanceProvider = FutureProvider<BigInt>((ref) async {
  final sdk = await ref.watch(breezSDKProvider.future);

  final GetInfoResponse info = await sdk.instance!.getInfo();

  return info.walletInfo.balanceSat;
});