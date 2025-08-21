import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class EulenTransactionDetails extends ConsumerWidget {
  const EulenTransactionDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(singleEulenTransfersDetailsProvider);

    // It's good practice to handle the case where a transaction might not be found.
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

    return SafeArea(
      bottom: true,
      child: Scaffold(
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
      ),
    );
  }


  Widget _buildHeader(BuildContext context, WidgetRef ref, EulenTransfer transaction) {
    // Using explicit labels like "You Sent" / "You Received" is clearer
    final sentAmount = "${transaction.originalAmount.toStringAsFixed(2)} ${transaction.from_currency ?? 'N/A'}";
    final receivedAmount = "${transaction.receivedAmount.toStringAsFixed(2)} ${transaction.to_currency ?? 'N/A'}";

    final statusIcon = transaction.failed ? Icons.error_rounded : transaction.completed ? Icons.check_circle_rounded : Icons.access_time_rounded;
    final statusColor = transaction.failed ? Colors.red : transaction.completed ? Colors.green : Colors.orange;

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

  Widget _buildDetailsCard(BuildContext context, WidgetRef ref, EulenTransfer transaction) {
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
            _buildSectionHeader("Fees".i18n),
            _buildFeeDetails(ref, transaction),
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

  Widget _buildTransactionDetails(BuildContext context, WidgetRef ref, EulenTransfer transaction) {
    final statusText = transaction.statusText;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Column(
      children: [
        TransactionDetailRow(label: "Type".i18n, value: transaction.transactionType?.i18n ?? 'Unknown'.i18n),
        TransactionDetailRow(label: "Status".i18n, value: statusText, valueColor: transaction.failed ? Colors.red : transaction.completed ? Colors.green : Colors.orange),
        TransactionDetailRow(label: "Provider".i18n, value: transaction.provider ?? "N/A"),
        TransactionDetailRow(label: "Payment Method".i18n, value: transaction.paymentMethod ?? "N/A".i18n),
        TransactionDetailRow(label: "Date".i18n, value: dateFormat.format(transaction.createdAt)),
        TransactionDetailRow(
          label: "Transaction ID".i18n,
          value: transaction.transactionId,
          onCopy: () {
            Clipboard.setData(ClipboardData(text: transaction.transactionId));
            showMessageSnackBar(
              context: context,
              message: 'Transaction ID copied'.i18n,
              error: false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeeDetails(WidgetRef ref, EulenTransfer transaction) {
    // Total fee is the difference between what was sent and what was received.
    final totalFee = (transaction.originalAmount - transaction.receivedAmount).abs();
    final feeCurrency = transaction.from_currency ?? 'N/A';

    // Assume a fixed fee of 0.99, similar to the deposit screen.
    // This might need to be fetched from the transaction data if it's dynamic.
    const fixedFee = 0.99;
    final variableFee = totalFee - fixedFee;

    // Calculate the fee percentage based on the adjusted Satsails fee.
    final feePercentage = transaction.originalAmount != 0
        ? (variableFee / transaction.originalAmount) * 100
        : 0.0;

    // Ensure the fee percentage is not negative.
    final displayFeePercentage = feePercentage > 0 ? feePercentage : 0.0;

    return Column(
      children: [
        TransactionDetailRow(label: "Fixed fee".i18n, value: "${fixedFee.toStringAsFixed(2)} $feeCurrency"),
        TransactionDetailRow(label: "Satsails fee".i18n, value: "${displayFeePercentage.toStringAsFixed(2)}%"),
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
