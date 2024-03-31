import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'bitcoin_config_provider.dart';

final initializeBitcoinProvider = FutureProvider<Bitcoin>((ref) async {
  final configModel = ref.watch(configNotifierProvider.notifier);
  final descriptor = await configModel.createDescriptor();
  final blockchain = await configModel.initializeBlockchain();
  final wallet = await configModel.restoreWallet(descriptor);

  Bitcoin bitcoin = Bitcoin(wallet, blockchain);

  return bitcoin;
});

final bitcoinNotifierProvider = StateNotifierProvider<BitcoinModel, Bitcoin>((ref) {
  final initialBitcoin = ref.watch(initializeBitcoinProvider);

  return BitcoinModel(initialBitcoin.when(
    data: (bitcoin) => bitcoin,
    loading: () => Bitcoin(null, null),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final syncTriggerProvider = StreamProvider.autoDispose<void>((ref) async* {
  await for (var _ in Stream.periodic(Duration(seconds: 10))) {
    final bitcoin = await ref.read(bitcoinNotifierProvider.notifier);
    bitcoin.sync();
  }
});