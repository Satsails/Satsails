import 'package:Satsails/notifications/firebase.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/services/background_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> with WidgetsBindingObserver {
  late ProviderContainer _container;
  static bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _createNewContainerAndServices();
    _container.read(backgroundSyncInProgressProvider.notifier).state = false;
  }

  void _createNewContainerAndServices() {
    _container = ProviderContainer();

    if (!_servicesInitialized) {
      // CHANGE: No longer pass the container here
      FirebaseService.initialize();
      _servicesInitialized = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _container.dispose();
    BackgroundSyncService().stop();
    super.dispose();
  }

  void restartApp() {
    setState(() {
      _container.dispose();
      BackgroundSyncService().stop();
      _createNewContainerAndServices();
      _container.read(backgroundSyncInProgressProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _container,
      child: KeyedSubtree(
        key: ValueKey(_container),
        child: widget.child,
      ),
    );
  }
}