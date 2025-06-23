import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PegDetails extends ConsumerWidget {
  final SideswapPegStatus swap;

  const PegDetails({super.key, required this.swap});

  // Helper function to shorten strings
  String shortenString(String input, {int prefixLength = 5, int suffixLength = 5}) {
    if (input.length <= prefixLength + suffixLength) {
      return input;
    }
    return '${input.substring(0, prefixLength)}...${input.substring(input.length - suffixLength)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(sideswapStatusDetailsItemProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Details'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: status.when(
        data: (status) => _buildDataView(context, status, btcFormat, ref),
        loading: () => Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            size: 70.w,
            color: Colors.orange,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error: $error Contact the developer (in the settings) about this'.i18n,
            style: TextStyle(fontSize: 16.sp, color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildDataView(BuildContext context, SideswapPegStatus status, String btcFormat, WidgetRef ref) {
    return SingleChildScrollView(
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
            _buildHeader(context, status, ref),
            SizedBox(height: 16.h),
            Divider(color: Colors.grey.shade700),
            SizedBox(height: 16.h),
            Text(
              "Transaction Details".i18n,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildTransactionsList(status, btcFormat, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SideswapPegStatus status, WidgetRef ref) {
    // Determine overall status based on the first transaction or fallback to "Pending"
    final firstTransaction = status.list?.isNotEmpty == true ? status.list!.first : null;
    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (firstTransaction != null) {
      switch (firstTransaction.txState) {
        case 'InsufficientAmount':
          statusText = "Insufficient Amount".i18n;
          statusIcon = Icons.error_rounded;
          statusColor = Colors.red;
          break;
        case 'Detected':
          statusText = "Detected".i18n;
          statusIcon = Icons.search_rounded;
          statusColor = Colors.orange;
          break;
        case 'Processing':
          statusText = "Processing".i18n;
          statusIcon = Icons.hourglass_empty_rounded;
          statusColor = Colors.yellow;
          break;
        case 'Done':
          statusText = "Completed".i18n;
          statusIcon = Icons.check_circle_rounded;
          statusColor = Colors.green;
          break;
        default:
          statusText = "Unknown".i18n;
          statusIcon = Icons.help_rounded;
          statusColor = Colors.grey;
      }
    } else {
      statusText = "Pending".i18n;
      statusIcon = Icons.access_time_rounded;
      statusColor = Colors.orange;
    }

    return Center(
      child: Column(
        children: [
          Icon(statusIcon, color: statusColor, size: 40.w),
          SizedBox(height: 8.h),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${"Order ID".i18n}: ",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
              Text(
                shortenString(status.orderId ?? "Error".i18n),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.orange, size: 16.w),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: status.orderId ?? ''));
                  showMessageSnackBar(
                    context: context,
                    message: 'Copied to clipboard'.i18n,
                    error: false,
                    info: true,
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${"Received at".i18n}: ",
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
              Text(
                shortenString(status.addrRecv ?? "Error".i18n),
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: Icon(Icons.copy, color: Colors.orange, size: 16.w),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: status.addrRecv ?? ''));
                  showMessageSnackBar(
                    context: context,
                    message: 'Copied to clipboard'.i18n,
                    error: false,
                    info: true,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(SideswapPegStatus status, String btcFormat, WidgetRef ref) {
    if (status.list == null || status.list!.isEmpty) {
      return Text(
        'No transactions found. Check back later.'.i18n,
        style: TextStyle(fontSize: 16.sp, color: Colors.white),
      );
    }

    return Column(
      children: status.list!.map((e) => _buildTransactionCard(e, btcFormat, ref)).toList(),
    );
  }

  Widget _buildTransactionCard(SideswapPegStatusTransaction transaction, String btcFormat, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionDetailRow(
          label: "Send Transaction".i18n,
          value: transaction.txHash ?? "Error".i18n,
          onCopy: () => Clipboard.setData(ClipboardData(text: transaction.txHash ?? '')),
          shorten: true,
        ),
        TransactionDetailRow(
          label: "Received Transaction".i18n,
          value: transaction.payoutTxid ?? "No Information".i18n,
          onCopy: () => Clipboard.setData(ClipboardData(text: transaction.payoutTxid ?? '')),
          shorten: true,
        ),
        TransactionDetailRow(
          label: "Amount sent".i18n,
          value: btcInDenominationFormatted(transaction.amount!.toDouble(), btcFormat),
          shorten: false,
        ),
        TransactionDetailRow(
          label: "Amount received".i18n,
          value: btcInDenominationFormatted(transaction.payout!.toDouble() ?? 0, btcFormat),
          shorten: false,
        ),
        _buildStatusRow(transaction, ref),
      ],
    );
  }

  Widget _buildStatusRow(SideswapPegStatusTransaction status, WidgetRef ref) {
    String statusText;
    IconData icon;
    Color color;

    switch (status.txState) {
      case 'InsufficientAmount':
        statusText = "Insufficient Amount".i18n;
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'Detected':
        statusText = "${"Detected".i18n}: ${status.detectedConfs ?? 0} / ${status.totalConfs ?? 0}";
        icon = Icons.search;
        color = Colors.orange;
        break;
      case 'Processing':
        statusText = "Processing".i18n;
        icon = Icons.hourglass_empty;
        color = Colors.yellow;
        break;
      case 'Done':
        statusText = "Done".i18n;
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      default:
        statusText = "Unknown".i18n;
        icon = Icons.help;
        color = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Status".i18n,
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
          Row(
            children: [
              Icon(icon, color: color, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                statusText,
                style: TextStyle(color: color, fontSize: 16.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final bool shorten;

  const TransactionDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.onCopy,
    this.shorten = false,
  });

  String shortenString(String input, {int prefixLength = 5, int suffixLength = 5}) {
    if (input.length <= prefixLength + suffixLength || input == 'No Information') {
      return input;
    }
    return '${input.substring(0, prefixLength)}...${input.substring(input.length - suffixLength)}';
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = shorten ? shortenString(value) : value;
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
                    displayValue,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
                if (onCopy != null) ...[
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.orange, size: 16.w),
                    onPressed: () {
                      onCopy?.call();
                      showMessageSnackBar(
                        context: context,
                        message: 'Copied to clipboard'.i18n,
                        error: false,
                        info: true,
                      );
                    },
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