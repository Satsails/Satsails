import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoxTransactionDetails extends ConsumerWidget {
  const NoxTransactionDetails({super.key});

  /// Formats a currency amount, handling BTC/sats conversion based on user settings.
  String _formatCurrencyAmount(double amount, String currency, WidgetRef ref) {
    if (currency.toUpperCase() == 'BTC') {
      final denomination = ref.read(settingsProvider).btcFormat;
      // Convert the BTC amount to sats for the formatter.
      final satsAmount = (amount * 100000000).toInt();
      // Use the helper to format into either BTC or sats string.
      return "${btcInDenominationFormatted(satsAmount, denomination)} $denomination";
    }
    // For other currencies, format to 2 decimal places with grouping.
    return "${NumberFormat('#,##0.00').format(amount)} $currency";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(singleNoxTransfersDetailsProvider);

    if (transaction == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: Center(
          child: Text(
            'Transaction not found.'.i18n,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Transaction Details'.i18n, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w), onPressed: () => context.pop()),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            _buildHeader(context, ref, transaction),
            SizedBox(height: 24.h),
            _buildDetailsCard(context, ref, transaction),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, NoxTransfer transaction) {
    final statusIcon = transaction.failed ? Icons.error_rounded : transaction.completed ? Icons.check_circle_rounded : Icons.access_time_rounded;
    final statusColor = transaction.failed ? Colors.red : transaction.completed ? Colors.green : Colors.orange;

    // Use the helper to format amounts, which will handle BTC/sats conversion.
    final sentAmount = _formatCurrencyAmount(transaction.originalAmount, transaction.from_currency ?? 'N/A', ref);
    final receivedAmount = _formatCurrencyAmount(transaction.receivedAmount, transaction.to_currency ?? 'N/A', ref);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 40.w),
          SizedBox(height: 16.h),
          Text("You Sent".i18n, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp)),
          SizedBox(height: 4.h),
          Text(sentAmount, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          Text("You Received".i18n, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp)),
          SizedBox(height: 4.h),
          Text(receivedAmount, style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, WidgetRef ref, NoxTransfer transaction) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Transaction Info".i18n),
          _buildTransactionDetails(context, ref, transaction),

          if (transaction.completed) ...[
            Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
            _buildSectionHeader("Fees & Rate".i18n),
            _buildFeeAndRateDetails(ref, transaction),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTransactionDetails(BuildContext context, WidgetRef ref, NoxTransfer transaction) {
    final statusText = transaction.statusText;
    final subStatusText = transaction.subStatusText;
    final statusColor = transaction.failed ? Colors.red : transaction.completed ? Colors.green : Colors.orange;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Column(
      children: [
        TransactionDetailRow(label: "Type".i18n, value: transaction.transactionType?.i18n ?? 'Unknown'.i18n),
        TransactionDetailRow(label: "Status".i18n, value: statusText, valueColor: statusColor),

        if (transaction.subStatus != null && transaction.subStatus!.isNotEmpty)
          TransactionDetailRow(label: "Sub-Status".i18n, value: subStatusText, valueColor: statusColor),

        TransactionDetailRow(label: "Provider".i18n, value: transaction.provider ?? "N/A"),
        TransactionDetailRow(label: "Payment Method".i18n, value: transaction.paymentMethod ?? "N/A".i18n),
        TransactionDetailRow(label: "Created At".i18n, value: dateFormat.format(transaction.createdAt)),
        TransactionDetailRow(label: "Last Updated".i18n, value: dateFormat.format(transaction.updatedAt)),

        TransactionDetailRow(
          label: "Transaction ID".i18n,
          value: transaction.transactionId,
          onCopy: () {
            Clipboard.setData(ClipboardData(text: transaction.transactionId));
            showMessageSnackBar(context: context, message: 'Transaction ID copied'.i18n, error: false);
          },
        ),
      ],
    );
  }

  Widget _buildFeeAndRateDetails(WidgetRef ref, NoxTransfer transaction) {
    final fee = (transaction.originalAmount - transaction.receivedAmount).abs();
    final feePercentage = transaction.originalAmount != 0 ? (fee / transaction.originalAmount) * 100 : 0.0;
    final feeCurrency = transaction.from_currency ?? 'N/A';
    final formattedFee = _formatCurrencyAmount(fee, feeCurrency, ref);

    final price = transaction.price ?? 0;
    final fromCurrency = transaction.from_currency ?? '';
    final toCurrency = transaction.to_currency ?? '';

    String rateString;
    if (price > 0) {
      String toPart;
      // If the rate is in BTC, format it according to user settings (BTC or sats).
      if (toCurrency.toUpperCase() == 'BTC') {
        final denomination = ref.read(settingsProvider).btcFormat;
        final satsAmount = (price * 100000000).toInt();
        toPart = "${btcInDenominationFormatted(satsAmount, denomination)} $denomination";
      } else {
        // Format other currencies with appropriate precision.
        toPart = "${NumberFormat('#,##0.00########').format(price)} $toCurrency";
      }
      rateString = "1 $fromCurrency ≈ $toPart";
    } else {
      rateString = "N/A";
    }

    return Column(
      children: [
        TransactionDetailRow(label: "Exchange Rate".i18n, value: rateString),
        TransactionDetailRow(label: "Fee".i18n, value: formattedFee),
        TransactionDetailRow(label: "Fee Percentage".i18n, value: "${feePercentage.toStringAsFixed(2)}%"),
      ],
    );
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label; final String value; final VoidCallback? onCopy; final Color? valueColor;
  const TransactionDetailRow({super.key, required this.label, required this.value, this.onCopy, this.valueColor});

  String shortenString(String input) {
    if (input.length <= 12) return input;
    return '${input.substring(0, 6)}...${input.substring(input.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isLongValue = value.length > 20 && onCopy != null;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp)),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: onCopy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(child: Text(isLongValue ? shortenString(value) : value, textAlign: TextAlign.right, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500))),
                  if (onCopy != null) ...[SizedBox(width: 8.w), Icon(Icons.copy, color: Colors.orange, size: 16.w)],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}