import 'package:flutter/services.dart';

class Channel {
  late MethodChannel platform;

  Channel(String channelName) {
    platform = MethodChannel(channelName);
  }

  Future<void> walletInit() async {
    await platform.invokeMethod('walletInit');
  }

  Future<String> generateMnemonic() async {
    String result = await platform.invokeMethod('generateMnemonic');
    print('Mnemonic: $result');
    return result;
  }
}