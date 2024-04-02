import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'bitcoin_config_provider.dart';

final initializeBitcoinProvider = FutureProvider<Bitcoin>((ref) async {
  final configModel = ref.watch(configNotifierProvider.notifier);
  final internalDescriptor = await configModel.createInternalDescriptor();
  final externalDescriptor = await configModel.createExternalDescriptor();
  final blockchain = await configModel.initializeBlockchain();
  final wallet = await configModel.restoreWallet(externalDescriptor, internalDescriptor);

  Bitcoin bitcoin = Bitcoin(wallet, blockchain);

  return bitcoin;
});

final bitcoinNotifierProvider = StateNotifierProvider<BitcoinModel, Bitcoin>((ref) {
  final initialBitcoin = ref.watch(initializeBitcoinProvider);

  return BitcoinModel(initialBitcoin.when(
    data: (bitcoin) => bitcoin,
    loading: () => throw 'Loading bitcoin',
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});