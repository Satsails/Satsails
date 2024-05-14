import 'package:boltz_dart/boltz_dart.dart';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/address_model.dart';

Future<bool> isValidLiquidAddress(String address) async {
  try {
    await Address.validate(addressString: address).then((value) => value);
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

Future<DecodedInvoice> isValidLightningAddress(String invoice) async {
  try {
    final res = await DecodedInvoice.fromString(
      s: invoice,
      boltzUrl: 'https://api.boltz.exchange',
    );
    return res;
  } catch (e) {
    throw FormatException('Invalid lightning address');
  }
}

Future<AddressAndAmount> parseAddressAndAmount(String data) async {
  if (data == null || data.isEmpty) {
    throw FormatException('Data cannot be null or empty');
  }
  var parts = data.split('?');
  var address = parts[0];
  var amount;
  var lightningInvoice = '';
  var assetId = AssetMapper.reverseMapTicker(AssetId.LBTC);

  if (address.startsWith('bitcoin:')) {
    address = address.substring(8);
  }

  if(address.startsWith('liquidnetwork:')) {
    address = address.substring(14);
  }

  if ((await isValidBitcoinAddress(address).then((value) => !value)) && (await isValidLiquidAddress(address).then((value) => !value)) && (await isValidLightningAddress(address).then((value) => false))){
    throw FormatException('Invalid address');
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
      DecodedInvoice decodedInvoice = await isValidLightningAddress(address);
      type = PaymentType.Lightning;
      address = address;
      amount = decodedInvoice.msats ~/ 1000;
      return AddressAndAmount(address, amount, assetId, type: type);
    } catch (e) {
      throw FormatException('Invalid lightning address');
    }
  }
}