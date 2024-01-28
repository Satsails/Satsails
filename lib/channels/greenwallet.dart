//TODO: here there should only be handling of the greenaddress method directly from c++. When doing for android all swift functionality must move to dart and the only channle should just be communicaiton with greenaddress
import 'dart:ffi';
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

  Future<Map<String, dynamic>> createWallet({String? mnemonic, String connectionType = 'electrum-mainnet'}) async {
    mnemonic ??= await getMnemonic();
    final walletInfo = await platform.invokeMethod('createWallet', <String, dynamic>{
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(walletInfo);
  }

  Future<Map<String, dynamic>> createSubAccount({String name = 'wallet', String walletType = 'p2pkh', String? mnemonic, String connectionType = 'electrum-mainnet' }) async {
    mnemonic ??= "";
    final walletInfo =  await platform.invokeMethod('createSubAccount', <String, dynamic>{
      'name': name,
      'walletType': walletType,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(walletInfo);
  }

  Future<String> getReceiveAddress({int pointer = 0, String mnemonic= "", String connectionType = 'electrum-mainnet' }) async {
    final address = await platform.invokeMethod('getReceiveAddress', <String, dynamic>{
      'pointer': pointer,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return address;
  }

  Future<Map<String, dynamic>> getBalance({int pointer = 0, String mnemonic= "", String connectionType = 'electrum-mainnet' }) async {
    final balance = await platform.invokeMethod('getBalance', <String, dynamic>{
      'pointer': pointer,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(balance);
  }

  Future<int> getPointer({String mnemonic= "", String connectionType = 'electrum-mainnet', String name = '', String walletType = 'p2pkh'}) async {
    final pointer = await platform.invokeMethod('getPointer', <String, dynamic>{
      'mnemonic': mnemonic,
      'connectionType': connectionType,
      'name': name,
      'walletType': walletType,
    });
    return pointer;
  }
}