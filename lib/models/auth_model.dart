import 'dart:convert';
import 'dart:io';
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:bitcoin_message_signer/bitcoin_message_signer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> migrateMnemonicToAppGroup() async {
  const migrationBoxName = 'appState';
  const migrationFlagKey = 'isMnemonicMigratedToAppGroupV1'; // Use a new, specific flag
  final box = await Hive.openBox(migrationBoxName);

  // If already migrated, do nothing.
  if (box.get(migrationFlagKey) == true) {
    return;
  }

  const storage = FlutterSecureStorage();

  // 1. Read from the OLD location (default, no group specified)
  final oldMnemonic = await storage.read(key: 'mnemonic');

  if (oldMnemonic != null && oldMnemonic.isNotEmpty) {
    // 2. Write to the NEW location (with App Group and correct accessibility)
    const newOptions = IOSOptions(
      groupId: 'group.com.satsailswallet.satsails',
      accessibility: KeychainAccessibility.unlocked_this_device,
    );
    await storage.write(key: 'mnemonic', value: oldMnemonic, iOptions: newOptions);

    // 3. Mark the migration as complete.
    await box.put(migrationFlagKey, true);
  } else {
    // No old mnemonic to migrate, but still set the flag so we don't check again.
    await box.put(migrationFlagKey, true);
  }
}

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

      final response = await http.get(
        Uri.parse('$backendUrl/auth/challenge'),
        headers: {
          'Content-Type': 'application/json',
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

  /// Returns the required security options for iOS to enable background access.
  /// This uses the App Group you configured in Xcode.
  IOSOptions _getIOSOptions() => const IOSOptions(
    // The App Group ID you created in Xcode.
    groupId: 'group.com.satsailswallet.satsails',
    // This accessibility level allows access when the device is unlocked,
    // which is necessary for background tasks that might run before the user
    // interacts with the app directly after a reboot.
    accessibility: KeychainAccessibility.unlocked_this_device,
  );

  /// Saves the mnemonic to secure storage within the shared App Group.
  Future<void> setMnemonic(String mnemonic) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }
    await _storage.write(
        key: 'mnemonic', value: mnemonic, iOptions: _getIOSOptions());
  }

  Future<bool> validateMnemonic(String mnemonic) async {
    return bip39.validateMnemonic(mnemonic);
  }

  Future<String> generateMnemonic() async {
    return bip39.generateMnemonic();
  }

  Future<void> setPin(String pin) async {
    // Using App Group for the PIN as well ensures consistency.
    await _storage.write(key: 'pin', value: pin);
  }

  Future<String?> getMnemonic() async {
    return await getMnemonicWithRetry();
  }

  // Retry logic to handle potential brief delays in accessing secure storage.
  Future<String?> getMnemonicWithRetry() async {
    for (int i = 0; i < 3; i++) {
      // The read operation on iOS will automatically find the key in the App Group.
      final mnemonic = await _storage.read(key: 'mnemonic', iOptions: _getIOSOptions());
      if (mnemonic != null) {
        return mnemonic;
      }
      // Wait before the next attempt
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

  Future<void> deleteLwkDb() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final liquidDBPath = '${appDocDir.path}/lwk-db';
    final dbDir = Directory(liquidDBPath);
    if (await dbDir.exists()) {
      await dbDir.delete(recursive: true);
    }
  }

  Future<void> deleteAuthentication() async {
    await _storage.delete(key: 'mnemonic', iOptions: _getIOSOptions());
    await _storage.delete(key: 'mnemonic');
    await _storage.delete(key: 'pin');
    await _storage.delete(key: 'pixPaymentCode');
    await _storage.delete(key: 'coinosToken');
    await _storage.delete(key: 'coinosUsername');
    await _storage.delete(key: 'coinosPassword');
    await _storage.delete(key: 'recoveryCode');
    await _storage.delete(key: 'backendJwt');
    await _storage.delete(key: 'fcmToken');

    // Deleting Hive boxes is a separate process.
    await Hive.deleteBoxFromDisk('bitcoin');
    await Hive.deleteBoxFromDisk('liquid');
    await Hive.deleteBoxFromDisk('coinosLn');
    await Hive.deleteBoxFromDisk('affiliateCode');
    await Hive.deleteBoxFromDisk('breez_prefs');
    await Hive.deleteBoxFromDisk('balanceBox');
    await Hive.deleteBoxFromDisk('settings');
    await Hive.deleteBoxFromDisk('bitcoinTransactions');
    await Hive.deleteBoxFromDisk('sideShiftShifts');
    await Hive.deleteBoxFromDisk('liquidTransactions');
    await Hive.deleteBoxFromDisk('boltzSwapsBox');
    await Hive.deleteBoxFromDisk('sideswapStatus');
    await Hive.deleteBoxFromDisk('sideswapSwapNewData');
    await Hive.deleteBoxFromDisk('pix');
    await Hive.deleteBoxFromDisk('eulenTransfersBox');
    await Hive.deleteBoxFromDisk('noxTransfersBox');
    await Hive.deleteBoxFromDisk('user');
    await Hive.deleteBoxFromDisk('affiliate');
    await Hive.deleteBoxFromDisk('addresses');
    await Hive.deleteBoxFromDisk('coinosPayments');
    await Hive.deleteBoxFromDisk('lightningBox');
    await Hive.deleteBoxFromDisk('appState');

    final appDocDir = await getApplicationDocumentsDirectory();
    final bitcoinDBPath = '${appDocDir.path}/bdk_wallet.sqlite';
    final dbFile = File(bitcoinDBPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
  }
}
