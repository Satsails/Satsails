import 'dart:async';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/services/coinos/coinos_push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';

class TransactionNotificationsListener extends StatefulWidget {
  final Widget child;

  const TransactionNotificationsListener({Key? key, required this.child})
      : super(key: key);

  @override
  _TransactionNotificationsListenerState createState() =>
      _TransactionNotificationsListenerState();
}

class _TransactionNotificationsListenerState
    extends State<TransactionNotificationsListener> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  CoinosPushNotifications? _pushNotifications;
  StreamSubscription<Map<String, dynamic>>? _subscription;

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
        _showFullScreenNotification(paymentData);
      });
    } else {
      print('Token is empty, cannot connect to push notifications');
    }
  }

  void _showFullScreenNotification(Map<String, dynamic> paymentData) {
    if (!mounted) return;

    final amount = (paymentData['amount'] as num?)?.toDouble() ?? 0.0;

    showOverlay((context, t) {
      return Material(
        color: Colors.black,
        child: Center(
          child: AnimatedCheckboxWidget(
            amount: amount,
            successMessage: 'Received lightning payment',
          ),
        ),
      );
    }, duration: Duration(seconds: 3));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pushNotifications?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
