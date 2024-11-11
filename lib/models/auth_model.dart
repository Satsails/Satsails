import 'dart:convert';
import 'dart:io';
import 'package:conduit_password_hash/pbkdf2.dart';
import 'package:crypto/crypto.dart';
import 'package:faker/faker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:hive/hive.dart';
import 'dart:math';
import 'package:convert/convert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pusher_beams/pusher_beams.dart';


class SecureKeyManager {
  static const String _keyId = 'boltz_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> generateAndStoreKey() async {
    String? existingKey = await _secureStorage.read(key: _keyId);
    if (existingKey == null) {
      final key = _generateRandom256BitKey();
      await _secureStorage.write(key: _keyId, value: key);
    }
  }

  static Future<String?> retrieveKey() async {
    return await _secureStorage.read(key: _keyId);
  }

  static Future<void> deleteKey() async {
    await _secureStorage.delete(key: _keyId);
  }

  static String _generateRandom256BitKey() {
    final keyBytes = List<int>.generate(32, (i) => Random.secure().nextInt(256));
    return hex.encode(keyBytes);
  }

  static Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    final encryptionKey = await retrieveKey();

    if (encryptionKey == null) {
      throw Exception("Encryption key not found.");
    }

    final key = hex.decode(encryptionKey);

    return await Hive.openBox<T>(
      boxName,
      encryptionCipher: HiveAesCipher(key),
    );
  }
}

class AuthModel {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setMnemonic(String mnemonic) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }
    await _storage.write(key: 'mnemonic', value: mnemonic);
  }

  Future<bool> validateMnemonic(String mnemonic) async {
    return bip39.validateMnemonic(mnemonic);
  }

  Future<String> generateMnemonic() async {
    return bip39.generateMnemonic();
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: 'pin', value: pin);
  }

  Future<String?> getMnemonic() async {
    return await _storage.read(key: 'mnemonic');
  }

  Future<String?> getPin() async {
    return await _storage.read(key: 'pin');
  }

  Future<bool> pinMatches(String incomingPin) async {
    String? storedPin = await getPin();
    return storedPin != null && storedPin == incomingPin;
  }

  Future<String> hashMnemonic(String mnemonic) async {
    // Hash the mnemonic and convert it to a Base64 string
    final hash = sha256.convert(utf8.encode(mnemonic));
    return base64.encode(hash.bytes); // Convert Uint8List to Base64 String
  }

  Future<List<int>> deriveKeyWithSalt(String mnemonic) async {
    // Get the Base64 string representation of the hash
    final hashedMnemonic = await hashMnemonic(mnemonic);

    final pbkdf2 = PBKDF2();
    // Use a simple Base64 substring as salt
    final salt = base64.encode(hashedMnemonic.codeUnits.sublist(0, 16).map((c) => c & 0xff).toList());
    final derivedKey = pbkdf2.generateKey(hashedMnemonic, salt, 2048, 32);
    return derivedKey;
  }

  Future<String?> getUsername() async {
    final mnemonic = await getMnemonic();
    if (mnemonic == null) return null;

    // Derive a key from the mnemonic using PBKDF2 with the deterministic salt
    final derivedKey = await deriveKeyWithSalt(mnemonic);

    // Initialize Faker with the derived key for consistency
    int seed = derivedKey.sublist(0, 4).fold(0, (prev, elem) => (prev << 8) + elem);
    final faker = Faker(seed: seed);

    // Generate a single word for the username
    String word = faker.animal.name();
    String color = faker.color.commonColor();

    int number = derivedKey.sublist(4, 6).fold(0, (prev, elem) => (prev << 8) + elem) % 10000;
    String numberStr = number.toString().padLeft(4, '0');

    // Combine word and number to form the username
    String username = "$color$word$numberStr";

    return username;
  }

  Future<String?> getBackendPassword() async {
    final mnemonic = await getMnemonic();
    if (mnemonic == null) return null;

    final derivedKey = await deriveKeyWithSalt(mnemonic);

    return base64.encode(derivedKey.sublist(10, 20));
  }

  Future<String?> getCoinosPassword() async {
    final mnemonic = await getMnemonic();
    if (mnemonic == null) return null;

    final derivedKey = await deriveKeyWithSalt(mnemonic);

    return base64.encode(derivedKey.sublist(20, 30));
  }

  Future<void> deleteAuthentication() async {
    await _storage.delete(key: 'mnemonic');
    await _storage.delete(key: 'pin');
    await _storage.delete(key: 'pixPaymentCode');
    await _storage.delete(key: 'coinosToken');
    await _storage.delete(key: 'coinosUsername');
    await _storage.delete(key: 'coinosPassword');
    await _storage.delete(key: 'recoveryCode');
    await Hive.deleteBoxFromDisk('bitcoin');
    await Hive.deleteBoxFromDisk('liquid');
    await Hive.deleteBoxFromDisk('balanceBox');
    await Hive.deleteBoxFromDisk('settings');
    await Hive.deleteBoxFromDisk('bitcoinTransactions');
    await Hive.deleteBoxFromDisk('liquidTransactions');
    await Hive.deleteBoxFromDisk('receiveBoltz');
    await Hive.deleteBoxFromDisk('payBoltz');
    await Hive.deleteBoxFromDisk('sideswapStatus');
    await Hive.deleteBoxFromDisk('sideswapSwapData');
    await Hive.deleteBoxFromDisk('pix');
    await Hive.deleteBoxFromDisk('user');
    await Hive.deleteBoxFromDisk('affiliate');
    await Hive.deleteBoxFromDisk('addresses');
    await SecureKeyManager.deleteKey();
    await PusherBeams.instance.clearAllState();
    final appDocDir = await getApplicationDocumentsDirectory();
    final bitcoinDBPath = '${appDocDir.path}/bdk_wallet.sqlite';
    final dbFile = File(bitcoinDBPath);
    await dbFile.delete();
  }
}


