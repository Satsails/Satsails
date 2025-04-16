import 'dart:convert';
import 'dart:io';
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bitcoin_message_signer/bitcoin_message_signer.dart';
import 'package:conduit_password_hash/pbkdf2.dart';
import 'package:crypto/crypto.dart';
import 'package:faker/faker.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendAuth {
  static Future<String?> signChallengeWithPrivateKey(
      String challengeResponse) async {
    try {
      final mnemonic = await AuthModel().getMnemonic();
      if (mnemonic == null) {
        return null;
      }

      final descriptorSecretKey = await _getDescriptorSecretKey(mnemonic);
      final privateKeyBytes = descriptorSecretKey.secretBytes();

      final signer = BitcoinMessageSigner(
        privateKey: Uint8List.fromList(privateKeyBytes),
        scriptType: P2PKH(compressed: true)
      );

      final signature = signer.signMessage(message: challengeResponse);
      return signature;
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<DescriptorSecretKey> _getDescriptorSecretKey(
      String mnemonic) async {
    final mnemonicType = await Mnemonic.fromString(mnemonic);
    return await DescriptorSecretKey.create(
      network: Network.testnet,
      mnemonic: mnemonicType,
    );
  }

  static Future<Result<String>> fetchChallenge() async {
    try {
      final backendUrl = dotenv.env['BACKEND'];
      if (backendUrl == null || backendUrl.isEmpty) {
        return Result(error: 'Backend URL is not configured');
      }

      // final appCheckToken = await FirebaseAppCheck.instance.getToken();

      final response = await http.get(
        Uri.parse('$backendUrl/auth/challenge'),
        headers: {
          'Content-Type': 'application/json',
          // 'X-Firebase-AppCheck': appCheckToken ?? '',
        },
      );

        final dynamic jsonResponse = json.decode(response.body);
        final challenge = jsonResponse['challenge'] as String?;

        return Result(data: challenge);
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
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
    return await getMnemonicWithRetry();
  }

  // New method with retry logic
  Future<String?> getMnemonicWithRetry() async {
    for (int i = 0; i < 3; i++) {
      final mnemonic = await _storage.read(key: 'mnemonic');
      if (mnemonic != null) {
        return mnemonic;
      }
      // Wait 500ms before the next attempt
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return null;
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
    String word = faker.animal.name().toLowerCase();
    String color = faker.color.commonColor().toLowerCase();

    int number = derivedKey.sublist(4, 6).fold(0, (prev, elem) => (prev << 8) + elem) % 10000;
    String numberStr = number.toString().padLeft(4, '0');

    // Combine word and number to form the username
    String username = "$color$word$numberStr";

    return username;
  }

  Future<String?> getCoinosPassword() async {
    final mnemonic = await getMnemonic();
    if (mnemonic == null) return null;

    final derivedKey = await deriveKeyWithSalt(mnemonic);

    return base64.encode(derivedKey.sublist(20, 30));
  }

  Future<void> deleteLwkDb() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final liquidDBPath = '${appDocDir.path}/lwk-db';
    final dbDir = Directory(liquidDBPath);
    if (await dbDir.exists()) {
      await dbDir.delete(recursive: true);
    }
  }

  Future<void> deleteAuthentication() async {
    await _storage.delete(key: 'mnemonic');
    await _storage.delete(key: 'pin');
    await _storage.delete(key: 'pixPaymentCode');
    await _storage.delete(key: 'coinosToken');
    await _storage.delete(key: 'coinosUsername');
    await _storage.delete(key: 'coinosPassword');
    await _storage.delete(key: 'recoveryCode');
    await _storage.delete(key: 'backendJwt');
    await _storage.delete(key: 'fcmToken');
    await Hive.deleteBoxFromDisk('bitcoin');
    await Hive.deleteBoxFromDisk('liquid');
    await Hive.deleteBoxFromDisk('affiliateCode');
    await Hive.deleteBoxFromDisk('balanceBox');
    await Hive.deleteBoxFromDisk('settings');
    await Hive.deleteBoxFromDisk('bitcoinTransactions');
    await Hive.deleteBoxFromDisk('liquidTransactions');
    await Hive.deleteBoxFromDisk('boltzSwapsBox');
    await Hive.deleteBoxFromDisk('sideswapStatus');
    await Hive.deleteBoxFromDisk('sideswapSwapData');
    await Hive.deleteBoxFromDisk('pix');
    await Hive.deleteBoxFromDisk('eulenTransfersBox');
    await Hive.deleteBoxFromDisk('user');
    await Hive.deleteBoxFromDisk('affiliate');
    await Hive.deleteBoxFromDisk('addresses');
    await Hive.deleteBoxFromDisk('coinosPayments');
    final appDocDir = await getApplicationDocumentsDirectory();
    final bitcoinDBPath = '${appDocDir.path}/bdk_wallet.sqlite';
    final dbFile = File(bitcoinDBPath);
    await dbFile.delete();
  }
}


