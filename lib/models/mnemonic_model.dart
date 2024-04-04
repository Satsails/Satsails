import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;


class MnemonicModel {
  String mnemonic;

  MnemonicModel({required this.mnemonic});

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setMnemonic(String mnemonic) async {
    this.mnemonic = mnemonic;
    await _storage.write(key: 'mnemonic', value: mnemonic);
  }

  bool validateMnemonic() {
    return bip39.validateMnemonic(mnemonic ?? '');
  }
}

class DeleteMnemonicModel {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> deleteMnemonic() async {
    await _storage.delete(key: 'mnemonic');
  }
}