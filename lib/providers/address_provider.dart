import 'package:Satsails/models/address_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final initialAddressesProvider = FutureProvider<Address>((ref) async {
  final box = await Hive.openBox('addresses');
  final bitcoinAddressIndex = box.get('bitcoinIndex', defaultValue: 0);
  final bitcoinAddress = box.get('bitcoinAddress', defaultValue: '');
  final liquidAddressIndex = box.get('liquidIndex', defaultValue: 0);
  final liquidAddress = box.get('liquidAddress', defaultValue: '');

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