import 'package:flutter/services.dart';

class Channel {
  late MethodChannel platform;

  Channel(String channelName) {
    platform = MethodChannel(channelName);
  }

  Future<String> generateMnemonic() async {
    return await platform.invokeMethod('generateMnemonic');
  }

  Future<String> registerUser() async {
    return await platform.invokeMethod('registerUser');
  }
}