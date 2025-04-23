import 'dart:convert';

import 'package:Satsails/services/lnurl_parser/dart_lnurl_parser.dart';
import 'package:Satsails/services/lnurl_parser/src/lnurl.dart';
import 'package:boltz/boltz.dart';
import 'package:decimal/decimal.dart';
import 'package:lwk/lwk.dart' as lwk;
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:http/http.dart' as http;

Future<bool> isValidLiquidAddress(String address) async {
  try {
    await lwk.Address.validate(addressString: address).then((value) => value);
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


Future<String> getLnInvoiceWithAmount(String invoice, int amount) async {
  try {
      final amountInMsats = BigInt.from(amount * 1000);
      return await invoiceFromLnurl(lnurl: invoice, msats: amountInMsats);
  } catch (e) {
    throw FormatException('Error processing lightning address or API call: $e');
  }
}

Future<AddressAndAmount> parseAddressAndAmount(String data, bool lnEnabled) async {
  if (data.isEmpty) {
    throw const FormatException('Data cannot be null or empty');
  }

  var parts = data.split('?');
  var address = parts[0];
  int amount = 0;
  var lightningInvoice = data;
  if (data.startsWith('lightning:')) {
    lightningInvoice = data.substring('lightning:'.length);
  }
  var assetId = AssetMapper.reverseMapTicker(AssetId.LBTC);

  if (address.startsWith('bitcoin:')) {
    address = address.substring(8);
  }

  if(address.startsWith('liquidnetwork:')) {
    address = address.substring(14);
  }
  if (lnEnabled) {
    if ((await isValidBitcoinAddress(address).then((value) => !value)) &&
        (await isValidLiquidAddress(address).then((value) => !value)) &&
        (validateLnurl(lnurl: lightningInvoice) == null)) {
      throw const FormatException('Invalid address');
    }
  } else {
    if ((await isValidBitcoinAddress(address).then((value) => !value)) &&
        (await isValidLiquidAddress(address).then((value) => !value))) {
      throw const FormatException('Invalid address');
    }
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
      } else if (keyValue[0] == 'lightning') {
        lightningInvoice = keyValue[1];
      } else if (keyValue[0] == 'assetid') {
        assetId = keyValue[1];
      }
    }
  }

  PaymentType type;
  if (await isValidBitcoinAddress(address).then((value) => value)) {
    type = PaymentType.Bitcoin;
    return AddressAndAmount(address, amount, assetId, type: type);
  } else if ((await isValidLiquidAddress(address).then((value) => value))) {
    type = PaymentType.Liquid;
    return AddressAndAmount(address, amount, assetId, type: type);
  } else {
    try {
      type = PaymentType.Lightning;
      address = lightningInvoice;
      BigInt amountBigInt = await getVoucherMaxAmount(lnurl: lightningInvoice);
      int amount = amountBigInt.toInt();
      return AddressAndAmount(address, amount, assetId, type: type);
    } catch (e) {
      throw const FormatException('Invalid lightning address');
    }
  }
}