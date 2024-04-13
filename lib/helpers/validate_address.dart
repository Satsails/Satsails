// this must be converted into a provider
import 'package:bech32/bech32.dart';
import 'package:btc_address_validate_swan/btc_address_validate_swan.dart';
import 'package:satsails/providers/send_payments_provider.dart';

bool isValidLiquidAddress(String address) {
  if (!address.startsWith('lq') && !address.startsWith('ex')) {
    return false;
  }

  try {
    var decoded = bech32.decode(address);

    if (address.startsWith('ex')) {
      if (decoded.data.length > 50) {
        return false;
      }
    } else if (address.startsWith('lq')) {
      if (decoded.data.length > 40) {
        return false;
      }
    }

    return true;
  } catch (e) {
    return false;
  }
}

bool isValidBitcoinAddress(String address) {
  try {
    validate(address);
    return true;
  } catch (e) {
    return false;
  }
}

PaymentTYpe addressType(String address) {
  if (isValidBitcoinAddress(address)) {
    return PaymentTYpe.Bitcoin;
  } else if (isValidLiquidAddress(address)) {
    return PaymentTYpe.Liquid;
  } else {
    return PaymentTYpe.Unknown;
  }
}
