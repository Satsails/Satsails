import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class PegDetails extends ConsumerWidget {
  final SideswapPegStatus swap;

  const PegDetails({super.key, required this.swap});

  String shortenString(String input, {int prefixLength = 6, int suffixLength = 6}) {
    if (input.length <= prefixLength + suffixLength) {
      return input;
    }
    return '${input.substring(0, prefixLength)}...${input.substring(input.length - suffixLength)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(sideswapStatusDetailsItemProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Swap Details'.i18n, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w), onPressed: () => Navigator.pop(context)),
      ),
      body: statusAsync.when(
        data: (status) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              _buildHeader(context, status),
              SizedBox(height: 24.h),
              _buildDetailsCard(context, status, btcFormat, ref),
            ],
          ),
        ),
        loading: () => _buildShimmerView(),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'.i18n, style: TextStyle(fontSize: 16.sp, color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SideswapPegStatus status) {
    final firstTransaction = status.list?.isNotEmpty == true ? status.list!.first : null;
    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (firstTransaction != null) {
      switch (firstTransaction.txState) {
        case 'InsufficientAmount':
          statusText = "Insufficient Amount".i18n; statusIcon = Icons.error_rounded; statusColor = Colors.red; break;
        case 'Detected':
          statusText = "Detected".i18n; statusIcon = Icons.search_rounded; statusColor = Colors.orange; break;
        case 'Processing':
          statusText = "Processing".i18n; statusIcon = Icons.hourglass_empty_rounded; statusColor = Colors.orange; break;
        case 'Done':
          statusText = "Completed".i18n; statusIcon = Icons.check_circle_rounded; statusColor = Colors.green; break;
        default:
          statusText = "Unknown".i18n; statusIcon = Icons.help_rounded; statusColor = Colors.grey;
      }
    } else {
      statusText = "Pending".i18n; statusIcon = Icons.access_time_rounded; statusColor = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        children: [
          Icon(statusIcon, color: statusColor, size: 40.w),
          SizedBox(height: 12.h),
          Text(statusText, style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 4.h),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: status.orderId ?? ''));
              showMessageSnackBar(context: context, message: 'Order ID Copied'.i18n, error: false, info: true);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(shortenString(status.orderId ?? "No Order ID".i18n), style: TextStyle(fontSize: 18.sp, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
                SizedBox(width: 8.w),
                Icon(Icons.copy, color: Colors.white.withOpacity(0.7), size: 16.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, SideswapPegStatus status, String btcFormat, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Receive Address".i18n),
          TransactionDetailRow(
            label: "Address".i18n,
            value: status.addrRecv ?? "Error".i18n,
            onCopy: () {
              final textToCopy = status.addrRecv ?? '';
              Clipboard.setData(ClipboardData(text: textToCopy));
              showMessageSnackBar(context: context, message: 'Address Copied'.i18n, error: false, info: true);
            },
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildSectionHeader("Transactions".i18n),
          if (status.list == null || status.list!.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text('No transactions found. Check back later.'.i18n, style: TextStyle(fontSize: 16.sp, color: Colors.white70)),
            )
          else
            ...status.list!.map((e) => _buildTransactionCard(context, e, btcFormat, ref)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold));
  }

  Widget _buildTransactionCard(BuildContext context, SideswapPegStatusTransaction transaction, String btcFormat, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionDetailRow(
            label: "Send TX".i18n,
            value: transaction.txHash ?? "N/A".i18n,
            onCopy: () {
              final textToCopy = transaction.txHash ?? '';
              Clipboard.setData(ClipboardData(text: textToCopy));
              showMessageSnackBar(context: context, message: 'Send TX Copied'.i18n, error: false, info: true);
            }),
        TransactionDetailRow(
            label: "Payout TX".i18n,
            value: transaction.payoutTxid ?? "N/A".i18n,
            onCopy: () {
              final textToCopy = transaction.payoutTxid ?? '';
              Clipboard.setData(ClipboardData(text: textToCopy));
              showMessageSnackBar(context: context, message: 'Payout TX Copied'.i18n, error: false, info: true);
            }),
        TransactionDetailRow(label: "Amount Sent".i18n, value: btcInDenominationFormatted(transaction.amount!.toDouble(), btcFormat)),
        TransactionDetailRow(label: "Amount Received".i18n, value: btcInDenominationFormatted(transaction.payout?.toDouble() ?? 0.0, btcFormat)),
        _buildStatusRow(transaction),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildStatusRow(SideswapPegStatusTransaction status) {
    String statusText; IconData icon; Color color;
    switch (status.txState) {
      case 'InsufficientAmount': statusText = "Insufficient".i18n; icon = Icons.error; color = Colors.red; break;
      case 'Detected': statusText = "${"Detected".i18n}: ${status.detectedConfs ?? 0}/${status.totalConfs ?? 0}"; icon = Icons.search; color = Colors.orange; break;
      case 'Processing': statusText = "Processing".i18n; icon = Icons.hourglass_empty; color = Colors.orange; break;
      case 'Done': statusText = "Done".i18n; icon = Icons.check_circle; color = Colors.green; break;
      default: statusText = "Unknown".i18n; icon = Icons.help; color = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Status".i18n, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp)),
          Row(
            children: [
              Icon(icon, color: color, size: 20.w),
              SizedBox(width: 8.w),
              Text(statusText, style: TextStyle(color: color, fontSize: 16.sp, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerView() {
    final baseColor = Colors.grey[900]!; final highlightColor = Colors.grey[800]!;
    Widget shimmerBox({double? width, required double height}) => Container(width: width, height: height, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8.r)));
    Widget shimmerRow({double labelWidth = 100, double valueWidth = 150}) => Padding(padding: EdgeInsets.symmetric(vertical: 12.h), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [shimmerBox(width: labelWidth.w, height: 16.h), shimmerBox(width: valueWidth.w, height: 16.h)]));

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
                child: Column(children: [Container(width: 40.w, height: 40.h, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)), SizedBox(height: 12.h), shimmerBox(width: 150.w, height: 32.h), SizedBox(height: 4.h), shimmerBox(width: 200.w, height: 18.h)])
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [shimmerBox(width: 200.w, height: 22.h), shimmerRow(), Divider(color: Colors.grey.shade700, height: 32.h), shimmerBox(width: 150.w, height: 22.h), shimmerRow(), shimmerRow()]),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label; final String value; final VoidCallback? onCopy;
  const TransactionDetailRow({super.key, required this.label, required this.value, this.onCopy});

  String shortenString(String input) {
    if (input.length <= 12) return input;
    return '${input.substring(0, 6)}...${input.substring(input.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp)),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: onCopy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(child: Text(shortenString(value), textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500))),
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