import 'dart:convert';

import 'package:Satsails/services/lnurl_parser/dart_lnurl_parser.dart';
import 'package:Satsails/services/lnurl_parser/src/lnurl.dart';
import 'package:decimal/decimal.dart';
import 'package:lwk_dart/lwk_dart.dart' as lwk;
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:bolt11_decoder/bolt11_decoder.dart';
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

final RegExp _regExpForLnAddressConversion = RegExp(r'([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})');

Uri? convertLnAddressToWellKnown(String lightningAddress) {
  try {
    if (findLnUrl(lightningAddress).isNotEmpty) {
      return decodeLnurlUri(lightningAddress);
    }
  } catch (_) {
    // Ignore the error and continue 
  }

  final match = _regExpForLnAddressConversion.firstMatch(lightningAddress);
  if (match != null && match.groupCount == 2) {
    String user = match.group(1)!;
    String domain = match.group(2)!;

    // Construct the .well-known/lnurlp URL
    String lnurlp = 'https://$domain/.well-known/lnurlp/$user';
    return Uri.parse(lnurlp);
  } else {
    return null;
  }
}

Future<String?> lnUrlHasWellKnown(Uri invoice) async {
  final lnParams = await getParamsFromLnurlServer(invoice);
  final lnuriCallback = lnParams.payParams?.callback;
  return lnuriCallback;
}

Future<String> checkForValidLnurl(String invoice) async {
  try {
    final wellKnownUrl = convertLnAddressToWellKnown(invoice);
    if (wellKnownUrl == null) {
      throw FormatException('Invalid lightning address format');
    }

    final callback = await lnUrlHasWellKnown(wellKnownUrl);

    if (callback == null) {
      throw FormatException('Callback URL is missing in LNURL response');
    }

    return callback;
  } catch (e) {
    throw FormatException('Error processing lightning address or API call: $e');
  }
}

Future<String> getLnInvoiceWithAmount(String invoice, int amount) async {
  try {
    if (convertLnAddressToWellKnown(invoice) == null) {
      final decodedInvoice = Bolt11PaymentRequest(invoice);

      if (decodedInvoice.amount != null) {
        return invoice;
      }
    }

    final amountInMsats = amount * 1000;

    final callbackUri = Uri.parse(await checkForValidLnurl(invoice)).replace(
      queryParameters: {"amount": amountInMsats.toString()},
    );

    final apiResponse = await http.get(callbackUri);

    if (apiResponse.statusCode != 200) {
      throw FormatException('Failed to fetch invoice: ${apiResponse.statusCode}');
    }

    final json = jsonDecode(apiResponse.body);
    final response = LNURLPayResult.fromJson(json);

    return response.pr;
  } catch (e) {
    throw FormatException('Error processing lightning address or API call: $e');
  }
}


Bolt11PaymentRequest isValidLightningAddress(String invoice) {
  try {
    final res = Bolt11PaymentRequest(invoice);
    return res;
  } catch (e) {
    throw const FormatException('Invalid lightning address');
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
        (await isValidLightningAddress(lightningInvoice) == null)) {
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
      Bolt11PaymentRequest decodedInvoice = isValidLightningAddress(lightningInvoice);
      type = PaymentType.Lightning;
      address = lightningInvoice;
      amount = (decodedInvoice.amount * Decimal.fromInt(100000000)).toBigInt().toInt();
      return AddressAndAmount(address, amount, assetId, type: type);
    } catch (e) {
      throw const FormatException('Invalid lightning address');
    }
  }
}