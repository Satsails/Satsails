import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

enum PaymentType {
  Bitcoin,
  Liquid,
  Lightning,
  Spark,
  Unknown,
  NonNative
}

class AddressAndAmount {
  final String address;
  final int? amount;
  final PaymentType type;
  final String? assetId;

  AddressAndAmount(this.address, this.amount, this.assetId, {this.type = PaymentType.Unknown});
}

class Address {
  final int bitcoinAddressIndex;
  final String bitcoinAddress;
  final int liquidAddressIndex;
  final String liquidAddress;

  Address({
    required this.bitcoinAddressIndex,
    required this.bitcoinAddress,
    required this.liquidAddressIndex,
    required this.liquidAddress,
  });
}

class AddressModel extends StateNotifier<Address> {
  AddressModel(super.state);

  Future<void> setLiquidAddress(int index, String address) async {
    final box = await Hive.openBox('addresses');
    final currentIndex = box.get('liquidIndex', defaultValue: 0);

    // Only proceed if the index is new or higher
    if (currentIndex <= index) {
      box.put('liquidIndex', index);
      box.put('liquidAddress', address);

      // Check if the values have actually changed
      if (state.liquidAddressIndex != index || state.liquidAddress != address) {
        // Update state with a new Address instance
        state = Address(
          bitcoinAddressIndex: state.bitcoinAddressIndex,
          bitcoinAddress: state.bitcoinAddress,
          liquidAddressIndex: index,
          liquidAddress: address,
        );
      }
    }
  }

  Future<void> setBitcoinAddress(int index, String address) async {
    final box = await Hive.openBox('addresses');
    final currentIndex = box.get('bitcoinIndex', defaultValue: 0);

    // Only proceed if the index is new or higher
    if (currentIndex <= index) {
      box.put('bitcoinIndex', index);
      box.put('bitcoinAddress', address);

      // Check if the values have actually changed
      if (state.bitcoinAddressIndex != index || state.bitcoinAddress != address) {
        // Update state with a new Address instance
        state = Address(
          bitcoinAddressIndex: index,
          bitcoinAddress: address,
          liquidAddressIndex: state.liquidAddressIndex,
          liquidAddress: state.liquidAddress,
        );
      }
    }
  }
}