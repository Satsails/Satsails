import 'dart:async';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/services/coinos/coinos_push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';

class TransactionNotificationsListener extends ConsumerStatefulWidget {
  final Widget child;

  const TransactionNotificationsListener({Key? key, required this.child})
      : super(key: key);

  @override
  _TransactionNotificationsListenerState createState() =>
      _TransactionNotificationsListenerState();
}

class _TransactionNotificationsListenerState
    extends ConsumerState<TransactionNotificationsListener> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  CoinosPushNotifications? _pushNotifications;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  BalanceChange? _previousBalanceChange;

  @override
  void initState() {
    super.initState();
    _initializePushNotifications();
  }

  Future<void> _initializePushNotifications() async {
    final token = await _storage.read(key: 'coinosToken') ?? '';

    if (token.isNotEmpty) {
      _pushNotifications = CoinosPushNotifications(token);
      _pushNotifications!.connect();

      _subscription = _pushNotifications!.paymentStream.listen((paymentData) {
        _handleWebSocketPayment(paymentData);
      });
    } else {
      print('Token is empty, cannot connect to push notifications');
    }
  }

  void _handleWebSocketPayment(Map<String, dynamic> paymentData) {
    if (!mounted) return;

    ref.read(backgroundSyncNotifierProvider.notifier).performSync();

  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pushNotifications?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balanceChange = ref.watch(balanceChangeProvider);

    // Check if there's a balance change and it's different from the previous one
    if (balanceChange != null && balanceChange != _previousBalanceChange) {
      // Schedule the side effect after the build method completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (balanceChange.asset == "Bitcoin" || balanceChange.asset == "Liquid Bitcoin" || balanceChange.asset == "Lightning") {
            _showFullScreenNotification(balanceChange, false, null, balanceChange.asset);
          } else {
            _showFullScreenNotification(balanceChange, true, fiatInDenominationFormatted(balanceChange.amount), balanceChange.asset);
          }
          ref.read(balanceChangeProvider.notifier).state = null;
          _previousBalanceChange = null;
        }
      });
      // Update the previous balance change to prevent duplicate notifications
      _previousBalanceChange = balanceChange;
    }

    return widget.child;
  }

  void _showFullScreenNotification(BalanceChange balanceChange, bool fiat, String? fiatAmount, String? asset) {
    showOverlay(
          (context, t) {
        return Material(
          color: Colors.black,
          child: Center(
            child: ReceiveTransactionOverlay(
              amount: btcInDenominationFormatted(balanceChange.amount, ref.read(settingsProvider).btcFormat),
              fiat: fiat,
              fiatAmount: fiatAmount,
              asset: asset,
            ),
          ),
        );
      },
      duration: Duration(seconds: 2),
    );
  }
}
