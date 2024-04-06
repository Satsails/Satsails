import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinModel {
  String pin;

  PinModel({required this.pin});

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setPin() async {
    await _storage.write(key: 'pin', value: pin);
  }

  Future<void> deletePin() async {
    await _storage.delete(key: 'pin');
  }

  Future<bool> pinMatches(String incomingPin) async {
    return pin != '' && pin == incomingPin;
  }
}
