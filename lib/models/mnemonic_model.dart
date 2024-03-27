import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MnemonicModel {
  String mnemonic;

  MnemonicModel({required this.mnemonic});

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> setMnemonic() async {
    await _storage.write(key: 'mnemonic', value: mnemonic);
  }

  Future<void> deleteMnemonic() async {
    await _storage.delete(key: 'mnemonic');
  }
}