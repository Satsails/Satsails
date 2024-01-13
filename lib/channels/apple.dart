import 'package:flutter/services.dart';

class Channel {
  static const platform = const MethodChannel('com.example/hello_world');

  static Future<String> getHelloWorld() async {
    final String result = await platform.invokeMethod('getHelloWorld');
    return result;
  }
}