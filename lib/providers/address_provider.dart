import 'dart:io';
import 'package:Satsails/models/address_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/settings_model.dart';
import 'package:hive/hive.dart';

final initialAddressesProvider = FutureProvider<Address>((ref) async {
  final box = await Hive.openBox('addresses');
  final liquidAddressIndex = box.get('liquid', defaultValue: 0);
  final bitcoinAddressIndex = box.get('bitcoin', defaultValue: 0);


  return Address(bitcoinAddressIndex: bitcoinAddressIndex, liquidAddressIndex: liquidAddressIndex);
});

final addressProvider = StateNotifierProvider<AddressModel, Address>((ref) {
  final initialSettings = ref.watch(initialAddressesProvider);

  return AddressModel(initialSettings.when(
    data: (addresses) => addresses,
    loading: () => Address(bitcoinAddressIndex: 0, liquidAddressIndex: 0),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});
