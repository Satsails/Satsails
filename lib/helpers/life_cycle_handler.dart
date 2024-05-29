import 'package:flutter/material.dart';

class LifecycleHandler extends WidgetsBindingObserver {
  final Function onAppPaused;

  LifecycleHandler({required this.onAppPaused});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      onAppPaused();
    }
  }
}
