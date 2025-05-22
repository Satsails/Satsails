import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final initialAddressesProvider = FutureProvider<Address>((ref) async {
  final box = await Hive.openBox('addresses');
  final bitcoinAddressIndex = box.get('bitcoinIndex', defaultValue: 0);
  final initialBtcAddress = await ref.read(lastUsedAddressProviderString.future);
  final initiaLiquidAddress = await ref.read(liquidLastUsedAddressStringProvider.future);
  final bitcoinAddress = box.get('bitcoinAddress', defaultValue: initialBtcAddress);
  final liquidAddressIndex = box.get('liquidIndex', defaultValue: 0);
  final liquidAddress = box.get('liquidAddress', defaultValue: initiaLiquidAddress);

  return Address(
    bitcoinAddressIndex: bitcoinAddressIndex,
    bitcoinAddress: bitcoinAddress,
    liquidAddressIndex: liquidAddressIndex,
    liquidAddress: liquidAddress,
  );
});

final addressProvider = StateNotifierProvider<AddressModel, Address>((ref) {
  final initialSettings = ref.watch(initialAddressesProvider);

  return AddressModel(initialSettings.when(
    data: (addresses) => addresses,
    loading: () => Address(
      bitcoinAddressIndex: 0,
      bitcoinAddress: '',
      liquidAddressIndex: 0,
      liquidAddress: '',
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});