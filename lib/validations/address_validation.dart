import 'package:Satsails/providers/breez_provider.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk/lwk.dart' as lwk;
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/address_model.dart';

Future<bool> isValidLiquidAddress(String address) async {
  try {
    await lwk.Address.validate(addressString: address);
    return true;
  } catch (_) {
    return false;
  }
}

Future<bool> isLightningInvoice(WidgetRef ref, String invoice) async {
  if (invoice.isEmpty) return false;
  try {
    final parsedInput = await ref.read(parseInputProvider(invoice).future);
    return parsedInput is breez.InputType_Bolt11;
  } catch (e) {
    return false;
  }
}

Future<int> invoiceAmount(WidgetRef ref, String invoice) async {
  try {
    final parsedInput = await ref.read(parseInputProvider(invoice).future);
    if (parsedInput is breez.InputType_Bolt11) {
      final amountMsat = parsedInput.invoice.amountMsat;
      return amountMsat != null ? (amountMsat ~/ BigInt.from(1000)).toInt() : 0;
    }
    throw const FormatException('Not a valid BOLT11 invoice');
  } catch (e) {
    throw const FormatException('Invalid or unparseable invoice');
  }
}


Future<bool> isValidBitcoinAddress(String address) async {
  try {
    await bdk.Address.fromString(s: address, network: bdk.Network.bitcoin);
    return true;
  } catch (e) {
    return false;
  }
}

Future<AddressAndAmount> parseAddressAndAmount(String data) async {
  var parts = data.split('?');
  var address = parts[0];
  int amount = 0;
  var assetId = AssetMapper.reverseMapTicker(AssetId.LBTC);

  if (address.startsWith('bitcoin:')) {
    address = address.substring(8);
  }
  if (address.startsWith('liquidnetwork:')) {
    address = address.substring(14);
  }

  if (!(await isValidBitcoinAddress(address)) &&
      !(await isValidLiquidAddress(address))) {
    throw const FormatException('Invalid address');
  }

  if (parts.length > 1) {
    var params = parts[1].split('&');
    for (var param in params) {
      var keyValue = param.split('=');
      if (keyValue[0] == 'amount') {
        if (keyValue[1].contains('&lightning')) {
          keyValue[1] = keyValue[1].split('&lightning')[0];
        }
        amount = (double.parse(keyValue[1]) * 1e8).toInt();
      } else if (keyValue[0] == 'assetid') {
        assetId = keyValue[1];
      }
    }
  }

  PaymentType type;
  if (await isValidBitcoinAddress(address)) {
    type = PaymentType.Bitcoin;
    return AddressAndAmount(address, amount, assetId, type: type);
  } else if (await isValidLiquidAddress(address)) {
    type = PaymentType.Liquid;
    return AddressAndAmount(address, amount, assetId, type: type);
  }

  throw const FormatException('Could not determine address type.');
}