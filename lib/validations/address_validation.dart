import 'package:btc_address_validate_swan/btc_address_validate_swan.dart';
import 'package:satsails/models/address_model.dart';
import 'package:bolt11_decoder/bolt11_decoder.dart';

bool isValidLiquidAddress(String address) {
  // implment address from string from lwk dart
  return false;
}

bool isValidBitcoinAddress(String address) {
  try {
    validate(address);
    return true;
  } catch (e) {
    return false;
  }
}

bool isValidLightningAddress(String address) {
  try {
    final _ = Bolt11PaymentRequest(address);
    return true;
  } catch (_) {
    return false;
  }
}


AddressAndAmount parseAddressAndAmount(String data) {
  if (data == null || data.isEmpty) {
    throw FormatException('Data cannot be null or empty');
  }
  var parts = data.split('?');
  var address = parts[0];
  var amount;
  var lightningInvoice = '';
  var assetId;

  if (address.startsWith('bitcoin:')) {
    address = address.substring(8);
  }
  if (address.startsWith('lightning:')) {
    address = address.substring(10);
  }
  if(address.startsWith('liquidnetwork:')) {
    address = address.substring(14);
  }

  if (!isValidBitcoinAddress(address) && !isValidLiquidAddress(address) && !isValidLightningAddress(address)) {
    throw FormatException('Invalid address');
  }

  if (parts.length > 1) {
    var params = parts[1].split('&');
    for (var param in params) {
      var keyValue = param.split('=');
      if (keyValue[0] == 'amount') {
        amount = (double.parse(keyValue[1]) * 1e8).toInt();
      } else if (keyValue[0] == 'lightning') {
        lightningInvoice = keyValue[1];
      } else if (keyValue[0] == 'assetid') {
        assetId = keyValue[1];
      }
    }
  }

  PaymentType type;
  if (isValidBitcoinAddress(address)) {
    type = PaymentType.Bitcoin;
    return AddressAndAmount(address, amount, assetId, type: type);
  } else if (isValidLiquidAddress(address)) {
    type = PaymentType.Liquid;
    return AddressAndAmount(address, amount, assetId, type: type);
  } else if (isValidLightningAddress(address)) {
    type = PaymentType.Lightning;
    return AddressAndAmount(address, amount, assetId, type: type);
  } else {
    type = PaymentType.Unknown;
    return AddressAndAmount(address, amount, assetId, type: type);
  }
}