import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart'; // Re-added overlay_support

class TransactionNotificationsListener extends ConsumerStatefulWidget {
  final Widget child;

  const TransactionNotificationsListener({super.key, required this.child});

  @override
  _TransactionNotificationsListenerState createState() =>
      _TransactionNotificationsListenerState();
}

class _TransactionNotificationsListenerState
    extends ConsumerState<TransactionNotificationsListener> {
  BalanceChange? _previousBalanceChange;

  @override
  Widget build(BuildContext context) {
    final balanceChange = ref.watch(balanceChangeProvider);

    if (balanceChange != null && balanceChange != _previousBalanceChange) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (balanceChange.asset == "Bitcoin" ||
              balanceChange.asset == "Liquid Bitcoin" ||
              balanceChange.asset == "Lightning") {
            _showFullScreenNotification(
                balanceChange, false, null, balanceChange.asset);
          } else {
            _showFullScreenNotification(
                balanceChange,
                true,
                fiatInDenominationFormatted(balanceChange.amount),
                balanceChange.asset);
          }
          ref.read(balanceChangeProvider.notifier).state = null;
          _previousBalanceChange = null;
        }
      });
      _previousBalanceChange = balanceChange;
    }

    return widget.child;
  }

  // UPDATED: Reverted to use showOverlay for reliable full-screen display
  void _showFullScreenNotification(
      BalanceChange balanceChange, bool fiat, String? fiatAmount, String? asset) {
    showOverlay(
          (context, t) {
        // The ReceiveTransactionOverlay is already a full-screen Scaffold,
        // so we can place it directly in the overlay.
        return ReceiveTransactionOverlay(
          amount: btcInDenominationFormatted(
              balanceChange.amount, ref.read(settingsProvider).btcFormat),
          fiat: fiat,
          fiatAmount: fiatAmount,
          asset: asset,
        );
      },
      duration: const Duration(seconds: 5),
    );
  }
}