import 'package:Satsails/providers/breez_provider.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/address_model.dart' as AddressModel;
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/validations/address_validation.dart';

final addressAndAmountProvider =
FutureProvider.autoDispose.family<AddressModel.AddressAndAmount, String>((ref, input) async {
  try {
    final parsedInput = await ref.watch(parseInputProvider(input).future);

    if (parsedInput is InputType_Bolt11) {
      final amountSat = parsedInput.invoice.amountMsat != null
          ? (parsedInput.invoice.amountMsat! ~/ BigInt.from(1000)).toInt()
          : 0;
      return AddressModel.AddressAndAmount(
        parsedInput.invoice.bolt11,
        amountSat,
        parsedInput.invoice.description,
        type: AddressModel.PaymentType.Lightning,
      );
    }
  } catch (e) {
  }
  try {
    return await parseAddressAndAmount(input);
  } catch (e) {
    throw 'Invalid input. Only Bitcoin, Liquid, and Lightning invoices are supported.';
  }
});

final setAddressAndAmountProvider =
FutureProvider.autoDispose.family<AddressModel.AddressAndAmount, String>((ref, address) async {
  try {
    final addressAndAmount = await ref.read(addressAndAmountProvider(address).future);

    Future.microtask(() {
      final notifier = ref.read(sendTxProvider.notifier);
      notifier.updateAddress(addressAndAmount.address);
      notifier.updateAmount(addressAndAmount.amount ?? 0);
      notifier.updatePaymentType(addressAndAmount.type);
    });

    return addressAndAmount;
  } catch (e) {
    rethrow;
  }
});
