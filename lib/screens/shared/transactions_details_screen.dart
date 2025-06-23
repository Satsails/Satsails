import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final BitcoinTransaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final denomination = ref.read(settingsProvider).btcFormat;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Transaction Details'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w), // Responsive icon size
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), // Responsive margins
          padding: EdgeInsets.all(16.w), // Responsive padding
          decoration: BoxDecoration(
            color: const Color(0x00333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.r), // Responsive radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4.r, // Responsive blur radius
                offset: Offset(0, 2.h), // Responsive offset
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
                        transactionTypeIcon(transaction.btcDetails),
                        SizedBox(width: 8.w), // Responsive spacing
                        Image.asset(
                          'lib/assets/bitcoin-logo.png',
                          width: 40.w,
                          height: 40.h,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h), // Responsive spacing
                    Text(
                      confirmationStatus(transaction.btcDetails, ref) == 'Unconfirmed'.i18n
                          ? "Waiting".i18n
                          : transactionAmount(transaction.btcDetails, ref),
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h), // Responsive spacing
              Divider(color: Colors.grey.shade700),
              SizedBox(height: 16.h), // Responsive spacing
              Text(
                "Transaction Details".i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold), // Responsive font size
              ),
              SizedBox(height: 16.h), // Responsive spacing
              TransactionDetailRow(
                label: "Date".i18n,
                value: _formatTimestamp(transaction.btcDetails.confirmationTime?.timestamp.toInt()).i18n,
              ),
              TransactionDetailRow(
                label: "Status".i18n,
                value: transaction.btcDetails.confirmationTime != null ? "Confirmed".i18n : "Pending".i18n,
              ),
              TransactionDetailRow(
                label: "Confirmation block".i18n,
                value: transaction.btcDetails.confirmationTime != null
                    ? transaction.btcDetails.confirmationTime!.height.toString()
                    : "Unconfirmed".i18n,
              ),
              SizedBox(height: 16.h), // Responsive spacing
              Text(
                "Amounts".i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold), // Responsive font size
              ),
              SizedBox(height: 16.h), // Responsive spacing
              TransactionDetailRow(
                label: "Received".i18n,
                value: "${btcInDenominationFormatted(transaction.btcDetails.received.toInt(), denomination)} $denomination",
              ),
              TransactionDetailRow(
                label: "Sent".i18n,
                value: "${btcInDenominationFormatted(transaction.btcDetails.sent.toInt(), denomination)} $denomination",
              ),
              if (transaction.btcDetails.fee != null)
                TransactionDetailRow(
                  label: "Fee".i18n,
                  value: "${btcInDenominationFormatted(transaction.btcDetails.fee!.toInt(), denomination)} $denomination",
                ),
              SizedBox(height: 16.h), // Responsive spacing
              Divider(color: Colors.grey.shade700),
              GestureDetector(
                onTap: () async {
                  ref.read(transactionSearchProvider).isLiquid = false;
                  ref.read(transactionSearchProvider).txid = transaction.btcDetails.txid;
                  context.push('/search_modal');
                },
                child: Container(
                  margin: EdgeInsets.only(top: 12.h), // Responsive margin
                  padding: EdgeInsets.all(12.w), // Responsive padding
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12.r), // Responsive radius
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 24.w), // Responsive icon size
                      SizedBox(width: 8.w), // Responsive spacing
                      Text(
                        "Search on Mempool".i18n,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp), // Responsive font size
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
      padding: EdgeInsets.symmetric(vertical: 8.h), // Responsive padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 16.sp), // Responsive font size
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 16.sp), // Responsive font size
            ),
          ),
        ],
      ),
    );
  }
}
