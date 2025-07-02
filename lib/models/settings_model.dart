import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SettingsModel extends StateNotifier<Settings> {
  SettingsModel(super.state);

  Future<void> setCurrency(String newCurrency) async {
    final box = await Hive.openBox('settings');
    box.put('currency', newCurrency);
    state = state.copyWith(currency: newCurrency);
  }

  Future<void> setLanguage(String newLanguage) async {
    final box = await Hive.openBox('settings');
    box.put('language', newLanguage);
    state = state.copyWith(language: newLanguage);
  }

  Future<void> setBtcFormat(String newBtcFormat) async {
    final box = await Hive.openBox('settings');
    box.put('btcFormat', newBtcFormat);
    state = state.copyWith(btcFormat: newBtcFormat);
  }

  void setOnline(bool onlineStatus) {
    state = state.copyWith(online: onlineStatus);
  }

  Future<void> setBackup(bool backupStatus) async {
    final box = await Hive.openBox('settings');
    box.put('backup', backupStatus);
    state = state.copyWith(backup: backupStatus);
  }

  // New method to handle the biometrics setting
  Future<void> setBiometricsEnabled(bool enabled) async {
    final box = await Hive.openBox('settings');
    box.put('biometricsEnabled', enabled);
    state = state.copyWith(biometricsEnabled: enabled);
  }

  Future<void> setBitcoinElectrumNode(String newElectrumNode) async {
    final box = await Hive.openBox('settings');
    box.put('bitcoinElectrumNode', newElectrumNode);
    state = state.copyWith(bitcoinElectrumNode: newElectrumNode);
  }

  Future<void> setLiquidElectrumNode(String newElectrumNode) async {
    final box = await Hive.openBox('settings');
    box.put('liquidElectrumNode', newElectrumNode);
    state = state.copyWith(liquidElectrumNode: newElectrumNode);
  }

  Future<void> setNodeType(String newNodeType) async {
    final box = await Hive.openBox('settings');
    box.put('nodeType', newNodeType);
    state = state.copyWith(nodeType: newNodeType);
  }

  Future<void> setBalanceVisible(bool balanceVisible) async {
    final box = await Hive.openBox('settings');
    box.put('balanceVisible', balanceVisible);
    state = state.copyWith(balanceVisible: balanceVisible);
  }
}

class Settings {
  final String currency;
  final String language;
  late final String btcFormat;
  late bool online;
  final bool balanceVisible;
  final bool backup;
  final bool biometricsEnabled; // New property
  final String bitcoinElectrumNode;
  final String liquidElectrumNode;
  final String nodeType;


  Settings({
    required this.currency,
    required this.language,
    required String btcFormat,
    required this.online,
    required this.backup,
    required this.balanceVisible,
    required this.biometricsEnabled, // Add to constructor
    required this.bitcoinElectrumNode,
    required this.liquidElectrumNode,
    required this.nodeType,
  }) : btcFormat = (['BTC', 'mBTC', 'bits', 'sats'].contains(btcFormat)) ? btcFormat : throw ArgumentError('Invalid btcFormat'),
        super();

  Settings copyWith({
    String? currency,
    String? language,
    String? btcFormat,
    bool? online,
    bool? balanceVisible,
    bool? backup,
    bool? biometricsEnabled, // Add to copyWith
    String? pixPaymentCode,
    String? bitcoinElectrumNode,
    String? liquidElectrumNode,
    String? nodeType,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      btcFormat: btcFormat ?? this.btcFormat,
      balanceVisible: balanceVisible ?? this.balanceVisible,
      online: online ?? this.online,
      backup: backup ?? this.backup,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled, // Add to copyWith logic
      bitcoinElectrumNode: bitcoinElectrumNode ?? this.bitcoinElectrumNode,
      liquidElectrumNode: liquidElectrumNode ?? this.liquidElectrumNode,
      nodeType: nodeType ?? this.nodeType,
    );
  }
}