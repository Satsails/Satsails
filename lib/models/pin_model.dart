import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;

class PinModel {
  String pin;

  PinModel({required this.pin});

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setPin() async {
    await _storage.write(key: 'pin', value: pin);
    if (await _storage.read(key: 'mnemonic') == null) {
      final mnemonic = bip39.generateMnemonic();
      await _storage.write(key: 'mnemonic', value: mnemonic.toString());
    }
  }

  Future<void> deletePin() async {
    await _storage.delete(key: 'pin');
  }

  Future<bool> pinMatches(String incomingPin) async {
    return pin != '' && pin == incomingPin;
  }
}
