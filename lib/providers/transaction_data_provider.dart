import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/address_model.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/validations/address_validation.dart';

final setAddressAndAmountProvider = StateProvider.family<AddressAndAmount, String>((ref, address) {
  try {
    final addressAndAmount = parseAddressAndAmount(address);
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

final setBlocksProvider = StateProvider.family<int, int>((ref, blocks) {
  ref.read(sendTxProvider.notifier).updateBlocks(blocks);
  return blocks;
});

final setAssetIdProvider = StateProvider.family<String, String>((ref, assetId) {
  ref.read(sendTxProvider.notifier).updateAssetId(assetId);
  return assetId;
});