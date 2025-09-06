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
// Change the start method to accept WidgetRef
  void start(WidgetRef ref) {
    if (_timer?.isActive ?? false) {
      debugPrint("Background sync service already running.");
      return;
    }

    debugPrint("Starting background sync service...");

    _runSync(ref); // initial sync immediately

    _timer = Timer.periodic(const Duration(seconds: 8), (timer) async {
      await _runSync(ref);
    });
  }

  Future<void> _runSync(WidgetRef ref) async {
    if (_isSyncing) {
      debugPrint("Sync already in progress, skipping this interval.");
      return;
    }

    try {
      _isSyncing = true;
      debugPrint("Performing background sync via service...");
      await ref.read(backgroundSyncNotifierProvider.notifier).performFullUpdate();
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
