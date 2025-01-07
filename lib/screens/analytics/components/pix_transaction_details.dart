import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/purchase_model.dart';
import 'package:Satsails/providers/purchase_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PixTransactionDetails extends ConsumerStatefulWidget {
  const PixTransactionDetails({super.key});

  @override
  _PixTransactionDetailsState createState() => _PixTransactionDetailsState();
}

class _PixTransactionDetailsState extends ConsumerState<PixTransactionDetails> {

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
    final transaction = ref.watch(singlePurchaseDetailsProvider);
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
                child: _buildTransactionHeader(ref, transaction),
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 16.0),
              Text(
                "About the transaction".i18n(ref),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              _buildTransactionDetails(ref, transaction),
              if (transaction.completedTransfer) ...[
                Divider(color: Colors.grey.shade700),
                const SizedBox(height: 16.0),
                Text(
                  "Fees".i18n(ref),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                _buildFeeDetails(ref, transaction),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(WidgetRef ref, Purchase transaction) {
    return Column(
      children: [
        Icon(
          transaction.failed
              ? Icons.error_rounded
              : transaction.completedTransfer 
              ? Icons.check_circle_rounded
              : Icons.access_time_rounded,
          color: transaction.failed
              ? Colors.red
              : transaction.completedTransfer 
              ? Colors.green
              : Colors.orange,
          size: 40,
        ),
        const SizedBox(height: 8.0),
        Text(
          transaction.failed
              ? "Transaction failed".i18n(ref)
              : currencyFormat(transaction.receivedAmount, 'BRL', decimalPlaces: 2),
          style: TextStyle(
            color: transaction.failed ? Colors.red : Colors.green,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        if (transaction.completedTransfer )
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: transaction.transferId));
              showMessageSnackBar(
                message: 'Transfer ID copied'.i18n(ref),
                error: false,
                context: context,
              );
            },
            child: Text(
              transaction.transferId,
              style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.045),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionDetails(WidgetRef ref, Purchase transaction) {
    return Column(
      children: [
        TransactionDetailRow(
          label: "ID",
          value: transaction.id.toString(),
        ),
        const SizedBox(height: 16.0),
        TransactionDetailRow(
          label: "Date".i18n(ref),
          value: "${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}",
        ),
        const SizedBox(height: 16.0),
        TransactionDetailRow(
          label: "Status".i18n(ref),
          value: transaction.failed
              ? "Transaction failed".i18n(ref)
              : transaction.completedTransfer 
              ? "Completed".i18n(ref)
              : "Pending".i18n(ref),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildFeeDetails(WidgetRef ref, Purchase transaction) {
    return Column(
      children: [
        TransactionDetailRow(
          label: "Original amount".i18n(ref),
          value: currencyFormat(transaction.originalAmount, 'BRL', decimalPlaces: 2),
        ),
        const SizedBox(height: 16.0),
        if (transaction.completedTransfer )
          TransactionDetailRow(
            label: "Total fees".i18n(ref),
            value: currencyFormat((transaction.originalAmount - transaction.receivedAmount), 'BRL', decimalPlaces: 2),
          ),
      ],
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
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
