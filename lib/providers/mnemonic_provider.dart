import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/mnemonic_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final mnemonicProvider = FutureProvider<MnemonicModel>((ref) async {
  const storage = FlutterSecureStorage();
  final mnemonic = storage.read(key: 'mnemonic');
  mnemonic.then((value) => null)

  return MnemonicModel(mnemonic: mnemonic);
});

final deleteMnemonicProvider = FutureProvider.autoDispose<void>((ref) async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'mnemonic');
});