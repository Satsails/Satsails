//TODO: here there should only be handling of the greenaddress method directly from c++. When doing for android all swift functionality must move to dart and the only channle should just be communicaiton with greenaddress
import 'package:flutter/services.dart';

class Channel {
  late MethodChannel platform;

  Channel(String channelName) {
    platform = MethodChannel(channelName);
  }

  Future<void> walletInit() async {
    await platform.invokeMethod('walletInit');
  }

  Future<String> getMnemonic() async {
    String result = await platform.invokeMethod('getMnemonic');
    return result;
  }

  Future<Map<String, dynamic>> createWallet(
      {String? mnemonic, String connectionType = 'electrum-mainnet', String name = ''}) async {
    mnemonic ??= await getMnemonic();
    final walletInfo = await platform.invokeMethod(
        'createWallet', <String, dynamic>{
      'mnemonic': mnemonic,
      'name': name,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(walletInfo);
  }

  Future<Map<String, dynamic>> createSubAccount(
      {String name = 'wallet', String walletType = 'p2sh-p2wpkh', String? mnemonic, String connectionType = 'electrum-mainnet' }) async {
    mnemonic ??= "";
    final walletInfo = await platform.invokeMethod(
        'createSubAccount', <String, dynamic>{
      'name': name,
      'walletType': walletType,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(walletInfo);
  }

  Future<Map<String, dynamic>> getReceiveAddress(
      {int pointer = 1, String mnemonic = "", String connectionType = 'electrum-mainnet' }) async {
    final address = await platform.invokeMethod(
        'getReceiveAddress', <String, dynamic>{
      'pointer': pointer,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(address);
  }

  Future<Map<String, int>> getBalance(
      {int pointer = 1, String mnemonic = "", String connectionType = 'electrum-mainnet' }) async {
    final balance = await platform.invokeMethod('getBalance', <String, dynamic>{
      'pointer': pointer,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, int>.from(balance);
  }

  Future<int> getPointer(
      {String mnemonic = "", String connectionType = 'electrum-mainnet', String name = '', String walletType = 'p2wpkh'}) async {
    final pointer = await platform.invokeMethod('getPointer', <String, dynamic>{
      'mnemonic': mnemonic,
      'connectionType': connectionType,
      'name': name,
      'walletType': walletType,
    });
    return pointer;
  }

  Future<List<Object?>> getTransactions(
      {int pointer = 1, String mnemonic = "", String connectionType = 'electrum-mainnet'}) async {
    final transactions = await platform.invokeMethod(
        'getTransactions', <String, dynamic>{
      'mnemonic': mnemonic,
      'pointer': pointer,
      'connectionType': connectionType,
    });
    return transactions;
  }

  Future<String> sendToAddress(
      {String address = '', int pointer = 1, String mnemonic = "", String connectionType = 'electrum-mainnet', int amount = 0, String assetId = ""}) async {
    final transaction = await platform.invokeMethod(
        'sendToAddress', <String, dynamic>{
      'address': address,
      'pointer': pointer,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
      'amount': amount,
      'assetId': assetId,
    });
    return transaction;
  }

  Future<Map<String, dynamic>> fetchAllSubAccounts(
      {String mnemonic = "", String connectionType = 'electrum-mainnet'}) async {
    final subaccounts = await platform.invokeMethod(
        'fetchAllSubAccounts', <String, dynamic>{
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(subaccounts);
  }

  Future<Map<String, dynamic>> getUTXOS(
      {int pointer = 1, String mnemonic = "", String connectionType = 'electrum-mainnet'}) async {
    final utxos = await platform.invokeMethod('getUTXOS', <String, dynamic>{
      'pointer': pointer,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(utxos);
  }

  Future<Map<String, dynamic>> getFeeEstimates(
      { String mnemonic = "", String connectionType = 'electrum-mainnet'}) async {
    final feeEstimates = await platform.invokeMethod(
        'getFeeEstimates', <String, dynamic>{
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(feeEstimates);
  }

  Future<Map<String, dynamic>> signTransaction(
      {int pointer = 1, String mnemonic = "", String connectionType = 'electrum-mainnet', String transaction = ""}) async {
    final signedTx = await platform.invokeMethod(
        'signTransaction', <String, dynamic>{
      'transaction': transaction,
      'pointer': pointer,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(signedTx);
  }
}
