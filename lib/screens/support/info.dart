import 'package:flutter/material.dart';

class Info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information about the app'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: const Text('This app is currently in development. It relies on atomic swaps to offer a seamless layer agnostic experience.'
            'Our goal is to make the coolest app for bitcoin that attends both basic users as the need of the most advanced ones. We are working hard to make it happen. Stay tuned!'),
      ),
    );
  }
}