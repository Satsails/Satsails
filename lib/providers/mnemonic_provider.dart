import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/mnemonic_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final mnemonicProvider = FutureProvider<MnemonicModel>((ref) async {
  const storage = FlutterSecureStorage();
  final mnemonic = await storage.read(key: 'mnemonic') ?? "";

  return MnemonicModel(mnemonic: mnemonic);
});