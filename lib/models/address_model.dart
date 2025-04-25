import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

enum PaymentType {
  Bitcoin,
  Liquid,
  Lightning,
  Spark,
  Unknown
}

class AddressAndAmount {
  final String address;
  final int? amount;
  final PaymentType type;
  final String? assetId;

  AddressAndAmount(this.address, this.amount, this.assetId, {this.type = PaymentType.Unknown});
}

class AddressModel extends StateNotifier<Address> {
  AddressModel(super.state);

  Future<void> setLiquidAddress(int index) async {
    final box = await Hive.openBox('addresses');
    final current = box.get('liquid', defaultValue: 0);
    if (current < index) {
      box.put('liquid', index);
      state = state.copyWith(liquidAddressIndex: index);
    }
  }
  Future<void> setBitcoinAddress(int index) async {
    final box = await Hive.openBox('addresses');
    final current = box.get('bitcoin', defaultValue: 0);
    if (current < index) {
      box.put('bitcoin', index);
      state = state.copyWith(bitcoinAddressIndex: index);
    }
  }
}

class Address {
  final int bitcoinAddressIndex;
  final int liquidAddressIndex;

  Address({
    required this.bitcoinAddressIndex,
    required this.liquidAddressIndex,
  });


  Address copyWith({
    int? bitcoinAddressIndex,
    int? liquidAddressIndex,
  }) {
    return Address(
      bitcoinAddressIndex: bitcoinAddressIndex ?? this.bitcoinAddressIndex,
      liquidAddressIndex: liquidAddressIndex ?? this.liquidAddressIndex,
    );
  }
}