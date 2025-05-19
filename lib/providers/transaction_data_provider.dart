import 'package:Satsails/providers/coinos_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/validations/address_validation.dart';

final addressAndAmountProvider = FutureProvider.autoDispose.family<AddressAndAmount, String>((ref, address) async {
  return parseAddressAndAmount(address);
});

final setAddressAndAmountProvider = FutureProvider.autoDispose.family<AddressAndAmount, String>((ref, address) async {
  if (await validLnurl(address)) {
    // Handle valid LNURL
    final addressAndAmount = AddressAndAmount(
      address,
      0,
      null,
      type: PaymentType.Lightning,
    );
    Future.microtask(() {
      ref.read(sendTxProvider.notifier).updateAddress(addressAndAmount.address);
      ref.read(sendTxProvider.notifier).updatePaymentType(addressAndAmount.type);
    });
    return addressAndAmount;
  } else {
    try {
      final addressAndAmount = await ref.read(addressAndAmountProvider(address).future);
      Future.microtask(() {
        ref.read(sendTxProvider.notifier).updateAddress(addressAndAmount.address);
        ref.read(sendTxProvider.notifier).updateAmount(addressAndAmount.amount ?? 0);
        ref.read(sendTxProvider.notifier).updatePaymentType(addressAndAmount.type);
      });
      return addressAndAmount;
    } catch (e) {
      throw 'Invalid address, only Bitcoin, Liquid and lightning invoices are supported.';
    }
  }
});