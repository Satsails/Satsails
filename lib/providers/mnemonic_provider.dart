import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/mnemonic_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;

final mnemonicProvider = FutureProvider<MnemonicModel>((ref) async {
  const storage = FlutterSecureStorage();
  final mnemonic = await storage.read(key: 'mnemonic');

  return MnemonicModel(mnemonic: mnemonic ?? '');
});

final deleteMnemonicProvider = FutureProvider.autoDispose<void>((ref) async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'mnemonic');
});

final setMnemonicProvider = FutureProvider.autoDispose<void>((ref) async {
  final mnemonic = await ref.read(mnemonicProvider.future);
  if (mnemonic.mnemonic != '') {
    return;
  }
  final words = bip39.generateMnemonic();
  mnemonic.mnemonic = words.toString();
});