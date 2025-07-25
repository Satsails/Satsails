import 'dart:convert';

import 'package:decimal/decimal.dart';
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

Future<bool> isValidBitcoinAddress(String address) async {
  try {
    await bdk.Address.fromString(s: address, network: bdk.Network.bitcoin);
    return true;
  } catch (e) {
    return false;
  }
}

bool isLightningInvoice(String invoice) {
  return true;
}

Future<AddressAndAmount> parseAddressAndAmount(String data) async {
  if (data.isEmpty) {
    throw const FormatException('Data cannot be null or empty');
  }

  // Split the data into address and parameters
  var parts = data.split('?');
  var address = parts[0];
  int amount = 0;
  var lightningInvoice = data;
  var assetId = AssetMapper.reverseMapTicker(AssetId.LBTC);

  // Handle protocol prefixes
  if (data.startsWith('lightning:')) {
    lightningInvoice = data.substring('lightning:'.length);
  }
  if (address.startsWith('bitcoin:')) {
    address = address.substring(8);
  }
  if (address.startsWith('liquidnetwork:')) {
    address = address.substring(14);
  }

  // Validate address based on enabled features
    if (!(await isValidBitcoinAddress(address)) &&
        !(await isValidLiquidAddress(address)) &&
        !isLightningInvoice(lightningInvoice)) {
      throw const FormatException('Invalid address');
    }

  // Parse query parameters if present
  if (parts.length > 1) {
    var params = parts[1].split('&');
    for (var param in params) {
      var keyValue = param.split('=');
      if (keyValue[0] == 'amount') {
        if (keyValue[1].contains('&lightning')) {
          keyValue[1] = keyValue[1].split('&lightning')[0];
        }
        amount = (double.parse(keyValue[1]) * 1e8).toInt();
      } else if (keyValue[0] == 'lightning') {
        lightningInvoice = keyValue[1];
      } else if (keyValue[0] == 'assetid') {
        assetId = keyValue[1];
      }
    }
  }

  // Determine payment type and construct result
  PaymentType type;
  if (await isValidBitcoinAddress(address)) {
    type = PaymentType.Bitcoin;
    return AddressAndAmount(address, amount, assetId, type: type);
  } else if (await isValidLiquidAddress(address)) {
    type = PaymentType.Liquid;
    return AddressAndAmount(address, amount, assetId, type: type);
  } else {
    try {
      if (isLightningInvoice(lightningInvoice)) {
        type = PaymentType.Lightning;
        address = lightningInvoice;
        return AddressAndAmount(address, amount, assetId, type: type);
      } else {
        throw const FormatException('Invalid lightning invoice');
      }
    } catch (e) {
      throw const FormatException('Invalid lightning address');
    }
  }
}