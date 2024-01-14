import 'package:flutter/services.dart';

class Channel {
  static const platform = const MethodChannel('ios_wallet');

  static Future<String> getHelloWorld() async {
    final String result = await platform.invokeMethod('generateMnemonic');
    return result;
  }
}