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

  Future<Map<String, dynamic>> createWallet({String? mnemonic, String connectionType = 'electrum-mainnet'}) async {
    mnemonic ??= await getMnemonic();
    final walletInfo = await platform.invokeMethod('createWallet', <String, dynamic>{
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return Map<String, dynamic>.from(walletInfo);
  }
  //
  //
  // Future<void> loginWithMnemonic({String? mnemonic, String connectionType = 'electrum-mainnet'}) async {
  //   mnemonic ??= await getMnemonic();
  //    await platform.invokeMethod('loginWithMnemonic', <String, dynamic>{
  //     'mnemonic': mnemonic,
  //     'connectionType': connectionType,
  //   });
  // }

  Future<String> createSubAccount({String name = 'wallet', String walletType = 'p2pkh', String? mnemonic, String connectionType = 'electrum-mainnet' }) async {
    mnemonic ??= await getMnemonic();
    String sub =  await platform.invokeMethod('createSubAccount', <String, dynamic>{
      'name': name,
      'walletType': walletType,
      'mnemonic': mnemonic,
      'connectionType': connectionType,
    });
    return sub;
  }
}