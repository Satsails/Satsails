import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final TransactionDetails transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double dynamicMargin = 16.0;
    const double dynamicRadius = 12.0;

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
                        transactionTypeIcon(transaction),
                        const SizedBox(width: 8.0),
                        confirmationStatus(transaction, ref) == 'Confirmed'.i18n(ref)
                            ? const Icon(Icons.check_circle_outlined, color: Colors.green)
                            : const Icon(Icons.access_alarm_outlined, color: Colors.red),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      confirmationStatus(transaction, ref) == 'Unconfirmed'.i18n(ref)
                          ? "Waiting".i18n(ref)
                          : transactionAmount(transaction, ref),
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
                label: "Date".i18n(ref),
                value: _formatTimestamp(transaction.confirmationTime?.timestamp).i18n(ref)
              ),
              TransactionDetailRow(
                label: "Status".i18n(ref),
                value: transaction.confirmationTime != null ? "Confirmed".i18n(ref) : "Pending".i18n(ref),
              ),
              TransactionDetailRow(
                label: "Confirmation block".i18n(ref),
                value: transaction.confirmationTime != null ? transaction.confirmationTime!.height.toString() : "Unconfirmed".i18n(ref),
              ),
              const SizedBox(height: 16.0),
              Text(
                "Amounts".i18n(ref),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Received".i18n(ref),
                value: "${transaction.received}",
              ),
              TransactionDetailRow(
                label: "Sent".i18n(ref),
                value: "${transaction.sent}",
              ),
              if (transaction.fee != null)
                TransactionDetailRow(
                  label: "Fee".i18n(ref),
                  value: "${transaction.fee}",
                ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),

              GestureDetector(
                onTap: () async {
                  ref.read(transactionSearchProvider).isLiquid = false;
                  ref.read(transactionSearchProvider).txid = transaction.txid;
                  context.push('/search_modal');
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
                      const Icon(Icons.search, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Text(
                        "Search on Mempool".i18n(ref),
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

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null || timestamp == 0) {
      return "Unconfirmed";
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.day}/${date.month}/${date.year}";
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
