import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsModel extends StateNotifier<Settings> {
  SettingsModel(super.state);

  final _secureStorage = const FlutterSecureStorage();

  IOSOptions _getIOSOptions() => const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  Future<void> setCurrency(String newCurrency) async {
    final box = await Hive.openBox('settings');
    await box.put('currency', newCurrency);
    state = state.copyWith(currency: newCurrency);
  }

  Future<void> setLanguage(String newLanguage) async {
    final box = await Hive.openBox('settings');
    await box.put('language', newLanguage);
    state = state.copyWith(language: newLanguage);
  }

  Future<void> setBtcFormat(String newBtcFormat) async {
    final box = await Hive.openBox('settings');
    await box.put('btcFormat', newBtcFormat);
    state = state.copyWith(btcFormat: newBtcFormat);
  }

  void setOnline(bool onlineStatus) {
    state = state.copyWith(online: onlineStatus);
  }

  Future<void> setBackup(bool backupStatus) async {
    final box = await Hive.openBox('settings');
    await box.put('backup', backupStatus);
    state = state.copyWith(backup: backupStatus);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    final box = await Hive.openBox('settings');
    await box.put('biometricsEnabled', enabled);
    state = state.copyWith(biometricsEnabled: enabled);
  }

  Future<void> setBitcoinElectrumNode(String newElectrumNode) async {
    final box = await Hive.openBox('settings');
    await box.put('bitcoinElectrumNode', newElectrumNode);
    state = state.copyWith(bitcoinElectrumNode: newElectrumNode);
  }

  Future<void> setLiquidElectrumNode(String newElectrumNode) async {
    final box = await Hive.openBox('settings');
    await box.put('liquidElectrumNode', newElectrumNode);
    state = state.copyWith(liquidElectrumNode: newElectrumNode);
  }

  Future<void> setNodeType(String newNodeType) async {
    final box = await Hive.openBox('settings');
    await box.put('nodeType', newNodeType);
    state = state.copyWith(nodeType: newNodeType);
  }

  Future<void> setBalanceVisible(bool balanceVisible) async {
    final box = await Hive.openBox('settings');
    await box.put('balanceVisible', balanceVisible);
    state = state.copyWith(balanceVisible: balanceVisible);
  }

  Future<void> setReviewDone(bool hasBeenReviewed) async {
    await _secureStorage.write(
      key: 'reviewDone',
      value: hasBeenReviewed.toString(),
      iOptions: _getIOSOptions(),
    );
    state = state.copyWith(reviewDone: hasBeenReviewed);
  }
}

class Settings {
  final String currency;
  final String language;
  late final String btcFormat;
  late bool online;
  final bool balanceVisible;
  final bool backup;
  final bool biometricsEnabled;
  final String bitcoinElectrumNode;
  final String liquidElectrumNode;
  final String nodeType;
  final bool reviewDone;

  Settings({
    required this.currency,
    required this.language,
    required String btcFormat,
    required this.online,
    required this.backup,
    required this.balanceVisible,
    required this.biometricsEnabled,
    required this.bitcoinElectrumNode,
    required this.liquidElectrumNode,
    required this.nodeType,
    required this.reviewDone,
  }) : btcFormat = (['BTC', 'mBTC', 'bits', 'sats'].contains(btcFormat))
      ? btcFormat
      : throw ArgumentError('Invalid btcFormat'),
        super();

  Settings copyWith({
    String? currency,
    String? language,
    String? btcFormat,
    bool? online,
    bool? balanceVisible,
    bool? backup,
    bool? biometricsEnabled,
    String? pixPaymentCode,
    String? bitcoinElectrumNode,
    String? liquidElectrumNode,
    String? nodeType,
    bool? reviewDone,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      btcFormat: btcFormat ?? this.btcFormat,
      balanceVisible: balanceVisible ?? this.balanceVisible,
      online: online ?? this.online,
      backup: backup ?? this.backup,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      bitcoinElectrumNode: bitcoinElectrumNode ?? this.bitcoinElectrumNode,
      liquidElectrumNode: liquidElectrumNode ?? this.liquidElectrumNode,
      nodeType: nodeType ?? this.nodeType,
      reviewDone: reviewDone ?? this.reviewDone,
    );
  }
}
