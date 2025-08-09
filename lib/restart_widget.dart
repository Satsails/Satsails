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
  // Static flag to ensure one-time services are only initialized once per app run.
  static bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _createNewContainerAndServices();

    // --- ADDED: Reset the sync progress state on every start ---
    // This prevents the app from getting stuck in an "offline" state.
    _container.read(backgroundSyncInProgressProvider.notifier).state = false;
    // -----------------------------------------------------------

    debugPrint("initState: Starting sync service...");
    BackgroundSyncService().start(_container);
  }

  /// Creates a new ProviderContainer and initializes services that need it.
  void _createNewContainerAndServices() {
    _container = ProviderContainer();

    if (!_servicesInitialized) {
      FirebaseService.initialize(_container);
      _servicesInitialized = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("App resumed, ensuring sync service is running...");
        BackgroundSyncService().start(_container);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        debugPrint("App paused, stopping sync service...");
        BackgroundSyncService().stop();
        break;
    }
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
      // Reset sync state and start the service immediately after a manual restart.
      _container.read(backgroundSyncInProgressProvider.notifier).state = false;
      BackgroundSyncService().start(_container);
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
