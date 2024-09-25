import 'dart:async'; // Import Timer
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/providers/pix_transaction_details_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class PixTransactionDetails extends ConsumerStatefulWidget {
  const PixTransactionDetails({super.key});

  @override
  _PixTransactionDetailsState createState() => _PixTransactionDetailsState();
}

class _PixTransactionDetailsState extends ConsumerState<PixTransactionDetails> {
  Timer? _timer;
  Duration _expirationTime = const Duration(minutes: 4);

  @override
  void initState() {
    super.initState();
    final transaction = ref.read(singleTransactionDetailsProvider);
    _initializeExpirationTime(transaction.createdAt);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeExpirationTime(DateTime createdAt) {
    final timeSinceCreation = DateTime.now().difference(createdAt);
    setState(() {
      _expirationTime = const Duration(minutes: 4) - timeSinceCreation;
      if (_expirationTime.isNegative) {
        _expirationTime = Duration.zero;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(singleTransactionDetailsProvider);
    const double dynamicMargin = 16.0;
    const double dynamicRadius = 12.0;

    // Check if the frontend has marked this transaction as "expired"
    final isFrontendExpired = _expirationTime.inSeconds <= 0 && !transaction.completedTransfer && !transaction.sentToHotWallet;

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
                child: _buildTransactionHeader(ref, transaction, isFrontendExpired),
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
                _buildReceiptDownload(ref, transaction, dynamicRadius),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(WidgetRef ref, Transfer transaction, bool isFrontendExpired) {
    return Column(
      children: [
        Icon(
          isFrontendExpired
              ? Icons.error_rounded
              : transaction.completedTransfer || transaction.sentToHotWallet
              ? Icons.check_circle_rounded
              : Icons.access_time_rounded,
          color: isFrontendExpired
              ? Colors.red
              : transaction.completedTransfer || transaction.sentToHotWallet
              ? Colors.green
              : Colors.orange,
          size: 40,
        ),
        const SizedBox(height: 8.0),
        if (!transaction.completedTransfer && !transaction.sentToHotWallet && _expirationTime.inSeconds > 0)
          Text(
            'Time left:'.i18n(ref) +
                ' ${_expirationTime.inMinutes}:${(_expirationTime.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.orange, fontSize: 16),
          ),
        Text(
          isFrontendExpired
              ? "Transaction failed".i18n(ref)
              : transaction.sentToHotWallet
              ? "Processing transfer".i18n(ref)
              : transaction.processingStatus && !transaction.sentToHotWallet
              ? "Waiting payment".i18n(ref)
              : currencyFormat(transaction.receivedAmount, 'BRL', decimalPlaces: 3),
          style: TextStyle(
            color: isFrontendExpired ? Colors.red : Colors.green,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        if (transaction.completedTransfer || transaction.sentToHotWallet)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: transaction.transferId));
              Fluttertoast.showToast(
                msg: 'Transfer ID copied'.i18n(ref),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
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

  Widget _buildTransactionDetails(WidgetRef ref, Transfer transaction) {
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
              : transaction.completedTransfer || transaction.sentToHotWallet
              ? "Completed".i18n(ref)
              : "Pending".i18n(ref),
        ),
        const SizedBox(height: 16.0),
        TransactionDetailRow(
          label: "CPF/CNPJ",
          value: transaction.cpf,
        ),
        const SizedBox(height: 16.0),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: transaction.sentTxid ?? "N/A"));
            Fluttertoast.showToast(
              msg: 'Txid copied'.i18n(ref),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
            );
          },
          child: TransactionDetailRow(
            label: "Txid",
            value: transaction.sentTxid ?? "N/A",
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildFeeDetails(WidgetRef ref, Transfer transaction) {
    return Column(
      children: [
        TransactionDetailRow(
          label: "Original amount".i18n(ref),
          value: currencyFormat(transaction.originalAmount, 'BRL', decimalPlaces: 3),
        ),
        const SizedBox(height: 16.0),
        if (transaction.completedTransfer || transaction.sentToHotWallet)
          TransactionDetailRow(
            label: "Total fees".i18n(ref),
            value: currencyFormat((transaction.originalAmount - transaction.receivedAmount), 'BRL', decimalPlaces: 3),
          ),
      ],
    );
  }

  Widget _buildReceiptDownload(WidgetRef ref, Transfer transaction, double dynamicRadius) {
    return transaction.receipt != null
        ? GestureDetector(
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
    )
        : const SizedBox.shrink();
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
              overflow: TextOverflow.ellipsis, // This will handle long text by truncating it
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
