import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';

class TransactionNotificationsListener extends ConsumerStatefulWidget {
  final Widget child;

  const TransactionNotificationsListener({super.key, required this.child});

  @override
  _TransactionNotificationsListenerState createState() =>
      _TransactionNotificationsListenerState();
}

class _TransactionNotificationsListenerState
    extends ConsumerState<TransactionNotificationsListener> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  BalanceChange? _previousBalanceChange;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
      duration: const Duration(seconds: 5),
    );
  }
}
