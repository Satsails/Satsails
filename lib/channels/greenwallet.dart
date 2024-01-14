import 'package:flutter/services.dart';

class Channel {
  late MethodChannel platform;

  Channel(String channelName) {
    platform = MethodChannel(channelName);
  }

  Future<String> createNewWallet() async {
    final String wallet = await platform.invokeMethod('createNewWallet', <String, dynamic>{'network': 'testnet-liquid'});
    return wallet;
  }
}