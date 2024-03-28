import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;


class MnemonicModel {
  String mnemonic;

  MnemonicModel({required this.mnemonic});

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setMnemonic() async {
    await _storage.write(key: 'mnemonic', value: mnemonic);
  }

  Future<void> deleteMnemonic() async {
    await _storage.delete(key: 'mnemonic');
  }

  bool validateMnemonic() {
    return bip39.validateMnemonic(mnemonic);
  }
}