import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/providers/pix_transaction_details_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PixTransactionDetails extends ConsumerWidget {
  const PixTransactionDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Transfer transaction = ref.watch(singleTransactionDetailsProvider);
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
          onPressed: () => Navigator.of(context).pop(),
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
                    const Icon(Icons.arrow_downward_rounded, color: Colors.green, size: 40),
                    const SizedBox(height: 8.0),
                    Text(
                      transaction.receivedAmount == 0.0
                          ? "Waiting".i18n(ref)
                          : currencyFormat(transaction.receivedAmount, 'BRL', decimalPlaces: 3),
                      style: const TextStyle(color: Colors.green, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: transaction.transferId));
                      },
                      child: Text(
                        transaction.transferId,
                        style: const TextStyle(color: Colors.white, fontSize: 18, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 16.0),
              Text(
                "About the transaction".i18n(ref),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Date".i18n(ref),
                value: "${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}",
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Status".i18n(ref),
                value: transaction.completedTransfer ? "Completed".i18n(ref) : "Pending".i18n(ref),
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Txid".i18n(ref),
                value: transaction.sentTxid ?? "N/A",
              ),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 16.0),
              Text(
                "Fees".i18n(ref),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Original amount".i18n(ref),
                value: currencyFormat(transaction.originalAmount, 'BRL', decimalPlaces: 3),
              ),
              const SizedBox(height: 16.0),
              if (transaction.completedTransfer)
              TransactionDetailRow(
                label: "Total fees".i18n(ref),
                value: currencyFormat((transaction.originalAmount - transaction.receivedAmount), 'BRL', decimalPlaces: 3),
              ),
              if (transaction.receipt != null)
                GestureDetector(
                  onTap: () async {
                    if (await canLaunch(transaction.receipt!)) {
                      await launch(transaction.receipt!);
                    } else {
                      throw 'Could not launch ${transaction.receipt}';
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
                        const Icon(Icons.download, color: Colors.white),
                        const SizedBox(width: 8.0),
                        Text(
                          "Download document".i18n(ref),
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
