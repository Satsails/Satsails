import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EulenTransactionDetails extends ConsumerStatefulWidget {
  const EulenTransactionDetails({super.key});

  @override
  _EulenTransactionDetailsState createState() => _EulenTransactionDetailsState();
}

class _EulenTransactionDetailsState extends ConsumerState<EulenTransactionDetails> {
  @override
  Widget build(BuildContext context) {
    final transaction = ref.watch(singleEulenTransfersDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction Details'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0x00333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildTransactionHeader(ref, transaction)),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade700),
              SizedBox(height: 16.h),
              Text(
                "About the transaction".i18n,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildTransactionDetails(ref, transaction),
              if (transaction.completed) ...[
                SizedBox(height: 16.h),
                Divider(color: Colors.grey.shade700),
                SizedBox(height: 16.h),
                Text(
                  "Fees".i18n,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildFeeDetails(ref, transaction),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(WidgetRef ref, EulenTransfer transaction) {
    final isBuy = transaction.transactionType == "BUY";
    final sentLabel = isBuy ? "Paid".i18n : "Sent".i18n;
    final sentAmount = "${transaction.originalAmount.toStringAsFixed(2)} ${transaction.from_currency ?? 'N/A'}";
    final receivedLabel = "Received".i18n;
    final receivedAmount = "${transaction.receivedAmount.toStringAsFixed(2)} ${transaction.to_currency ?? 'N/A'}";
    final statusIcon = transaction.failed
        ? Icons.error_rounded
        : transaction.completed
        ? Icons.check_circle_rounded
        : Icons.access_time_rounded;
    final statusColor = transaction.failed
        ? Colors.red
        : transaction.completed
        ? Colors.green
        : Colors.orange;
    final statusText = transaction.status ?? (transaction.failed
        ? "Failed".i18n
        : transaction.completed
        ? "Completed".i18n
        : "Pending".i18n);

    return Column(
      children: [
        Icon(statusIcon, color: statusColor, size: 40.w),
        SizedBox(height: 8.h),
        Text(
          transaction.transactionType?.i18n ?? 'Unknown'.i18n,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          statusText.capitalize().i18n,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(sentLabel, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                Text(
                  sentAmount,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(receivedLabel, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                Text(
                  receivedAmount,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (transaction.completed)
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: transaction.transactionId));
                showMessageSnackBar(
                  message: 'Transfer ID copied'.i18n,
                  error: false,
                  context: context,
                );
              },
              child: Text(
                transaction.transactionId,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionDetails(WidgetRef ref, EulenTransfer transaction) {
    final status = transaction.status;
    final currency = ref.read(settingsProvider).currency;
    final currencyConversionFromUsd = ref.read(selectedCurrencyProviderFromUSD(currency));

    // Map status values to display text with internationalization
    String statusText;
    switch (status) {
      case "expired":
        statusText = "Expired".i18n;
        break;
      case "pending":
        statusText = "Pending".i18n;
        break;
      case "depix_sent":
        statusText = "Depix Sent".i18n;
        break;
      case "under_review":
        statusText = "Under review".i18n;
        break;
      default:
        statusText = status?.i18n ?? "Unknown".i18n; // Fallback for unknown statuses
    }
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Column(
      children: [
        TransactionDetailRow(label: "ID".i18n, value: transaction.id.toString()),
        TransactionDetailRow(
          label: "Transaction ID".i18n,
          value: transaction.transactionId,
          onCopy: () {
            Clipboard.setData(ClipboardData(text: transaction.transactionId));
            showMessageSnackBar(
              context: context,
              message: 'Transaction ID copied'.i18n,
              error: false,
              info: true,
            );
          },
        ),
        TransactionDetailRow(
          label: "Transaction Type".i18n,
          value: transaction.transactionType?.i18n ?? 'Unknown'.i18n,
        ),
        TransactionDetailRow(
          label: "From".i18n,
          value: "${transaction.originalAmount.toStringAsFixed(2)} ${transaction.from_currency ?? 'N/A'}",
        ),
        TransactionDetailRow(
          label: "To".i18n,
          value: "${transaction.receivedAmount.toStringAsFixed(2)} ${transaction.to_currency ?? 'N/A'}",
        ),
        TransactionDetailRow(
          label: "Date".i18n,
          value: dateFormat.format(transaction.createdAt),
        ),
        TransactionDetailRow(label: "Status".i18n, value: statusText),
        TransactionDetailRow(
          label: "Payment Method".i18n,
          value: transaction.paymentMethod ?? "N/A".i18n,
        ),
        TransactionDetailRow(
          label: "Provider".i18n,
          value: transaction.provider ?? "N/A",
        ),
        TransactionDetailRow(
          label: '${"Value purchased in".i18n} $currency',
          value: currencyFormat(transaction.price ?? 0 * currencyConversionFromUsd, currency),
        ),
      ],
    );
  }

  Widget _buildFeeDetails(WidgetRef ref, EulenTransfer transaction) {
    final isBuy = transaction.transactionType == "BUY";
    final fee = (transaction.originalAmount - transaction.receivedAmount).abs();
    final feePercentage = transaction.originalAmount != 0 ? (fee / transaction.originalAmount) * 100 : 0.0;

    return Column(
      children: [
        TransactionDetailRow(
          label: "Fee".i18n,
          value: "${fee.toStringAsFixed(2)} ${isBuy ? transaction.from_currency : transaction.to_currency ?? 'N/A'}",
        ),
        TransactionDetailRow(
          label: "Fee Percentage".i18n,
          value: "${feePercentage.toStringAsFixed(2)}%",
        ),
      ],
    );
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const TransactionDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
                if (onCopy != null) ...[
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.orange, size: 16.w),
                    onPressed: onCopy,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}