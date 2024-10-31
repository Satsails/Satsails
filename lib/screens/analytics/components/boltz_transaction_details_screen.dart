import 'package:Satsails/assets/lbtc_icon.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BtcTransactionDetailsScreen extends ConsumerWidget {
  final BtcBoltz transaction;

  const BtcTransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double dynamicMargin = 16.0;
    const double dynamicRadius = 12.0;

    final amount = transaction.swap.outAmount;
    final expiry = transaction.swapScript.locktime;
    final timestamp = transaction.timestamp;
    final completed = transaction.completed ? 'Completed' : 'Pending';
    final kind = transaction.swap.kind.name;
    final network = 'Bitcoin';
    final swapId = transaction.swap.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction Details'.i18n(ref),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(dynamicRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.currency_bitcoin,
                          color: Colors.orangeAccent,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          network,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      completed.i18n(ref),
                      style: const TextStyle(color: Colors.green, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 16.0),
              Text(
                "Transaction Details".i18n(ref),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Swap ID".i18n(ref),
                value: swapId,
              ),
              TransactionDetailRow(
                label: "Date".i18n(ref),
                value: _formatTimestamp(timestamp),
              ),
              TransactionDetailRow(
                label: "Kind".i18n(ref),
                value: kind,
              ),
              TransactionDetailRow(
                label: "Expiry block".i18n(ref),
                value: expiry.toString(),
              ),
              TransactionDetailRow(
                label: "Amount".i18n(ref),
                value: "${btcInDenominationFormatted(amount.toDouble(), ref.watch(settingsProvider).btcFormat)} ${ref.watch(settingsProvider).btcFormat}",
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),

              // Claim or Refund Button based on transaction kind
              GestureDetector(
                onTap: () async {
                  try {
                    if (kind == 'reverse') {
                      // Handle Claim Logic
                      await ref.read(claimSingleBitcoinBoltzTransactionProvider(swapId).future);
                      Fluttertoast.showToast(
                        msg: 'Transaction claimed'.i18n(ref),
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    } else {
                      // Handle Refund Logic
                      await ref.read(refundSingleBitcoinBoltzTransactionProvider(swapId).future);
                      Fluttertoast.showToast(
                        msg: 'Transaction refunded'.i18n(ref),
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    }
                    context.pop();
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: e.toString().i18n(ref),
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(dynamicRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Text(
                        kind == 'reverse' ? "Claim".i18n(ref) : "Refund".i18n(ref),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const TransactionDetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class LbtcTransactionDetailsScreen extends ConsumerWidget {
  final LbtcBoltz transaction;

  const LbtcTransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double dynamicMargin = 16.0;
    const double dynamicRadius = 12.0;

    final amount = transaction.swap.outAmount;
    final expiry = transaction.swapScript.locktime;
    final timestamp = transaction.timestamp;
    final completed = transaction.completed ? 'Completed' : 'Pending';
    final kind = transaction.swap.kind.name;
    final network = 'Liquid';
    final swapId = transaction.swap.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction Details'.i18n(ref),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(dynamicRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Lbtc_icon.lbtc_icon, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Text(
                          network,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      completed.i18n(ref),
                      style: const TextStyle(color: Colors.green, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 16.0),
              Text(
                "Transaction Details".i18n(ref),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Swap ID".i18n(ref),
                value: swapId,
              ),
              TransactionDetailRow(
                label: "Date".i18n(ref),
                value: _formatTimestamp(timestamp),
              ),
              TransactionDetailRow(
                label: "Expiry block".i18n(ref),
                value: expiry.toString(),
              ),
              TransactionDetailRow(
                label: "Amount".i18n(ref),
                value: "${btcInDenominationFormatted(amount.toDouble(), ref.watch(settingsProvider).btcFormat)} ${ref.watch(settingsProvider).btcFormat}",
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              GestureDetector(
                onTap: () async {
                  try {
                    if (kind == 'reverse') {
                      // Handle Claim Logic
                      await ref.read(claimSingleBoltzTransactionProvider(swapId).future);
                      Fluttertoast.showToast(
                        msg: 'Transaction claimed'.i18n(ref),
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    } else {
                      // Handle Refund Logic
                      await ref.read(refundSingleBoltzTransactionProvider(swapId).future);
                      Fluttertoast.showToast(
                        msg: 'Transaction refunded'.i18n(ref),
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    }
                    context.pop();
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: e.toString().i18n(ref),
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(dynamicRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Text(
                        kind == 'reverse' ? "Claim".i18n(ref) : "Refund".i18n(ref),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}