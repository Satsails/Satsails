import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/providers/pix_transaction_details_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class PixTransactionDetails extends ConsumerWidget {
  PixTransactionDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Transfer transaction = ref.watch(singleTransactionDetailsProvider);
    final double dynamicMargin = 16.0;
    final double dynamicRadius = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction Details'.i18n(ref),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 8.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(dynamicRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(Icons.arrow_downward_rounded, color: Colors.green, size: 40),
                    SizedBox(height: 8.0),
                    Text(
                      "R\$ ${transaction.receivedAmount.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.green, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      transaction.transferId,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              SizedBox(height: 16.0),
              Text(
                "About the transaction".i18n(ref),
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Date".i18n(ref),
                value: "${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year}",
              ),
              TransactionDetailRow(
                label: "Status".i18n(ref),
                value: transaction.completedTransfer ? "Completed".i18n(ref) : "Pending".i18n(ref),
              ),
              SizedBox(height: 16.0),
              Text(
                "Origin".i18n(ref),
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Name".i18n(ref),
                value: transaction.name,
              ),
              TransactionDetailRow(
                label: "CPF/CNPJ",
                value: transaction.cpf,
              ),
              SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
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
                    margin: EdgeInsets.only(top: 12.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(dynamicRadius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, color: Colors.white),
                        SizedBox(width: 8.0),
                        Text(
                          "Download document".i18n(ref),
                          style: TextStyle(color: Colors.white, fontSize: 16),
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

  TransactionDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
