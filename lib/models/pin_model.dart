import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:satsails_wallet/models/mnemonic_model.dart';
import 'package:bdk_flutter/bdk_flutter.dart';

class PinModel {
  String pin;

  PinModel({required this.pin});

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> setPin() async {
    await _storage.write(key: 'pin', value: pin);
    final mnemonic = await Mnemonic.create(WordCount.Words12);
    await _storage.write(key: 'mnemonic', value: mnemonic.toString());
  }

  Future<void> deletePin() async {
    await _storage.delete(key: 'pin');
  }

  Future<bool> pinMatches(String incomingPin) async {
    return pin != '' && pin == incomingPin;
  }
}
