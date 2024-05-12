import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/validations/address_validation.dart';

final addressAndAmountProvider = FutureProvider.autoDispose.family<AddressAndAmount, String>((ref, address) async {
  return parseAddressAndAmount(address);
});

final validateBitcoinAddressProvider = FutureProvider.autoDispose.family<bool, String>((ref, address) async {
  try {
    return isValidBitcoinAddress(address);
  } catch (e) {
    return false;
  }
});

final validateLiquidAddressProvider = FutureProvider.autoDispose.family<bool, String>((ref, address) async {
  try {
    return isValidLiquidAddress(address);
  } catch (e) {
    return false;
  }
});

final validateLightningInvoiceProvider = FutureProvider.autoDispose.family<bool, String>((ref, invoice) async {
  try {
    return isValidLightningAddress(invoice);
  } catch (e) {
    return false;
  }
});

final setAddressAndAmountProvider = FutureProvider.autoDispose.family<AddressAndAmount, String>((ref, address) async {
  try {
    final addressAndAmount = await ref.read(addressAndAmountProvider(address).future);
    Future.microtask(() {
      ref.read(sendTxProvider.notifier).updateAddress(addressAndAmount.address);
      ref.read(sendTxProvider.notifier).updateAmount(addressAndAmount.amount ?? 0);
      ref.read(sendTxProvider.notifier).updatePaymentType(addressAndAmount.type);
      ref.read(sendTxProvider.notifier).updateAssetId(addressAndAmount.assetId ?? '');
    });
    return addressAndAmount;
  } catch (e) {
    throw Exception('Invalid address');
  }
});

final setAmountProvider = StateProvider.family<int, int>((ref, amount) {
  ref.read(sendTxProvider.notifier).updateAmount(amount);
  return amount;
});

final setAssetIdProvider = StateProvider.family<String, String>((ref, assetId) {
  ref.read(sendTxProvider.notifier).updateAssetId(assetId);
  return assetId;
});