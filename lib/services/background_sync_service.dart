import 'dart:async';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A singleton service to manage the continuous background sync loop.
/// This ensures the sync process is independent of any widget's lifecycle.
class BackgroundSyncService {
  // --- Singleton Setup ---
  static final BackgroundSyncService _instance = BackgroundSyncService._internal();
  factory BackgroundSyncService() {
    return _instance;
  }
  BackgroundSyncService._internal();
  // --- End Singleton Setup ---

  Timer? _timer;
  bool _isSyncing = false;

  /// Starts the continuous sync loop.
  /// This should be called once when the app starts.
  ///
  /// [container] is the app's root ProviderContainer, which allows this
  /// service to access other providers.
  void start(ProviderContainer container) {
    // Prevent starting multiple timers
    if (_timer?.isActive ?? false) {
      debugPrint("Background sync service already running.");
      return;
    }

    debugPrint("Starting background sync service...");

    // --- ADDED: Perform an initial sync immediately on start ---
    _runSync(container);
    // ---------------------------------------------------------

    // Start the periodic timer for subsequent syncs.
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      await _runSync(container);
    });
  }

  /// The core sync logic, now extracted into its own method.
  Future<void> _runSync(ProviderContainer container) async {
    if (_isSyncing) {
      debugPrint("Sync already in progress, skipping this interval.");
      return;
    }

    try {
      _isSyncing = true;
      debugPrint("Performing background sync via service...");
      // Use the container to read the provider and trigger the sync.
      await container.read(backgroundSyncNotifierProvider.notifier).performFullUpdate();
    } catch (e) {
      debugPrint("Background sync service failed in interval: $e");
    } finally {
      _isSyncing = false;
    }
  }


  /// Stops the sync loop.
  /// This can be called if the user logs out, for example.
  void stop() {
    debugPrint("Stopping background sync service.");
    _timer?.cancel();
    _isSyncing = false;
  }
}
