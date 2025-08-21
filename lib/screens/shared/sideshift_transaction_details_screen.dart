import 'package:Satsails/helpers/common_operation_methods.dart'; // Import the common helpers
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

String shortenAddress(String address, [int start = 6, int end = 6]) {
  if (address.length <= start + end) {
    return address;
  }
  return '${address.substring(0, start)}...${address.substring(address.length - end)}';
}

class SideShiftTransactionDetailsScreen extends ConsumerWidget {
  final SideShiftTransaction transaction;

  const SideShiftTransactionDetailsScreen(
      {super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(shiftByIdProvider(transaction.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('SideShift Transaction Details'.i18n,
            style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w),
            onPressed: () => context.pop()),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: true,
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              _buildHeader(context, ref, details),
              SizedBox(height: 24.h),
              _buildDetailsCard(context, ref, details),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, SideShift details) {
    return Container(
      width: double.infinity, // Ensures the container spans the full width
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
          color: const Color(0x00333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r)),
      child: SizedBox(
        height: 160.h, // Enforces a consistent height for the header card
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                sideshiftTransactionTypeIcon(), // Using helper from common_operation_methods.dart
                SizedBox(width: 8.w),
                _shiftStatusIcon(
                    details.status), // Using local helper for SideShift-specific status
              ],
            ),
            const Spacer(),
            Text(
              "${details.depositAmount ?? '...'} ${details.depositNetwork.capitalize()} ${details.depositCoin}",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              "${details.settleAmount ?? '...'} ${details.settleNetwork.capitalize()} ${details.settleCoin}",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
      BuildContext context, WidgetRef ref, SideShift details) {
    final locale = ref.watch(settingsProvider).language;
    final formattedDate = DateFormat('d MMMM, HH:mm', locale)
        .format(DateTime.fromMillisecondsSinceEpoch(details.timestamp * 1000));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
          color: const Color(0x00333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Transaction Info'.i18n),
          TransactionDetailRow(label: 'Date'.i18n, value: formattedDate),
          TransactionDetailRow(
              label: 'Status'.i18n,
              value: getStatusText(details.status),
              valueColor: _getStatusColor(details.status)),
          // Using the new onCopy parameter for the ID row to show a specific message.
          TransactionDetailRow(
            label: 'ID'.i18n,
            value: details.id,
            isCopiable: true,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: details.id));
              showMessageSnackBar(
                context: context,
                message: 'Transaction ID copied'.i18n,
                error: false,
                info: true,
              );
            },
          ),
          TransactionDetailRow(
              label: 'Expires'.i18n, value: formatExpiresAt(details.expiresAt)),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildSectionHeader('Deposit Details'.i18n),
          TransactionDetailRow(
              label: 'Address'.i18n,
              value: details.depositAddress,
              isCopiable: true,
              isAddress: true),
          if (details.depositMemo != null)
            TransactionDetailRow(label: 'Memo'.i18n, value: details.depositMemo!),
          TransactionDetailRow(
              label: 'Min'.i18n,
              value: "${details.depositMin} ${details.depositCoin}"),
          TransactionDetailRow(
              label: 'Max'.i18n,
              value: "${details.depositMax} ${details.depositCoin}"),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildSectionHeader('Settle Details'.i18n),
          TransactionDetailRow(
              label: 'Address'.i18n,
              value: details.settleAddress,
              isCopiable: true,
              isAddress: true),
          TransactionDetailRow(
              label: 'Network Fee'.i18n,
              value: "${details.settleCoinNetworkFee} ${details.settleCoin}"),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildSectionHeader('Additional Info'.i18n),
          TransactionDetailRow(
              label: 'Avg. Shift Time'.i18n,
              value: formatAverageShiftTime(details.averageShiftSeconds)),
          if (details.status == 'failed' ||
              (details.status != 'settled' && details.status != 'expired')) ...[
            Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
            ReturnAddressSection(transactionId: transaction.id, details: details)
          ]
        ],
      ),
    );
  }

  // --- Local Helper Methods Specific to SideShift ---
  Widget _buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold)));


  Color _getStatusColor(String status) {
    switch (status) {
      case 'settled':
        return Colors.green;
      case 'failed':
      case 'expired':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _shiftStatusIcon(String status) {
    IconData iconData;
    switch (status) {
      case 'settled':
        iconData = Icons.check_circle;
        break;
      case 'failed':
      case 'expired':
        iconData = Icons.cancel;
        break;
      default:
        iconData = Icons.alarm;
        break;
    }
    return Container(
        width: 40.w,
        height: 40.w,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: Color(0xFF333333)),
        child: Center(
            child: Icon(iconData, color: _getStatusColor(status), size: 24.w)));
  }

  String formatExpiresAt(String expiresAt) {
    try {
      final expireTime = DateTime.parse(expiresAt);
      final now = DateTime.now();
      if (expireTime.isBefore(now)) return 'Expired'.i18n;
      final difference = expireTime.difference(now);
      if (difference.inDays > 0)
        return '${difference.inDays} days'.i18n.fill([difference.inDays]);
      if (difference.inHours > 0)
        return '${difference.inHours} hours'.i18n.fill([difference.inHours]);
      if (difference.inMinutes > 0)
        return '${difference.inMinutes} minutes'.i18n.fill([difference.inMinutes]);
      return 'Expires soon'.i18n;
    } catch (e) {
      return 'Invalid date'.i18n;
    }
  }

  String formatAverageShiftTime(String averageShiftSeconds) {
    try {
      final seconds = int.parse(averageShiftSeconds);
      if (seconds < 60) return '$seconds seconds';
      final minutes = (seconds / 60).round();
      return '$minutes minutes';
    } catch (e) {
      return 'N/A';
    }
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCopiable;
  final bool isAddress;
  final Color? valueColor;
  final VoidCallback? onCopy; // Allows a custom onCopy callback

  const TransactionDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isCopiable = false,
    this.isAddress = false,
    this.valueColor,
    this.onCopy, // Added to the constructor
  });

  @override
  Widget build(BuildContext context) {
    final displayText = isAddress ? shortenAddress(value) : value;
    final copyValue = isCopiable ? value : null;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 16.sp)),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              // Use the custom onCopy if it exists, otherwise use the default logic.
              onTap: onCopy ??
                  (copyValue != null
                      ? () {
                    Clipboard.setData(ClipboardData(text: copyValue));
                    showMessageSnackBar(
                        message: 'Copied to clipboard'.i18n,
                        error: false,
                        context: context);
                  }
                      : null),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      child: Text(displayText,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: valueColor ?? Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500))),
                  if (isCopiable) ...[
                    SizedBox(width: 8.w),
                    Icon(Icons.copy, color: Colors.orange, size: 16.w)
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReturnAddressSection extends ConsumerStatefulWidget {
  final String transactionId;
  final SideShift details;
  const ReturnAddressSection(
      {super.key, required this.transactionId, required this.details});
  @override
  _ReturnAddressSectionState createState() => _ReturnAddressSectionState();
}

class _ReturnAddressSectionState extends ConsumerState<ReturnAddressSection> {
  late TextEditingController _returnAddressController;
  @override
  void initState() {
    super.initState();
    _returnAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _returnAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveReturnAddress() async {
    final refundParams = RefundAddressParams(
        shiftId: widget.transactionId,
        refundAddress: _returnAddressController.text);
    try {
      await ref.read(setRefundAddressProvider(refundParams).future);
      showMessageSnackBar(
          message: 'Refund address set and shift updated'.i18n,
          error: false,
          context: context);
    } catch (e) {
      showMessageSnackBar(
          message: 'Failed to set refund address: $e'.i18n,
          error: true,
          context: context);
    }
  }

  Widget _buildActionButton(
      {required String text,
        required IconData icon,
        required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.25),
            borderRadius: BorderRadius.circular(14.r)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.green.shade300, size: 20.w),
          SizedBox(width: 8.w),
          Text(text,
              style: TextStyle(
                  color: Colors.green.shade300,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.details.refundAddress.isNotEmpty) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Refund Address'.i18n),
            TransactionDetailRow(
                label: 'Address'.i18n,
                value: widget.details.refundAddress,
                isCopiable: true,
                isAddress: true)
          ]);
    } else {
      return KeyboardDismissOnTap(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Provide Refund Address'.i18n),
            SizedBox(height: 8.h),
            Text(
                'If this shift fails, the funds will be returned to this address.'
                    .i18n,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 14.sp)),
            SizedBox(height: 16.h),
            TextField(
                controller: _returnAddressController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Enter refund address'.i18n,
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF212121),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none))),
            SizedBox(height: 16.h),
            _buildActionButton(
                text: 'Save Address'.i18n,
                icon: Icons.save,
                onPressed: _saveReturnAddress),
          ],
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title) => Text(title,
      style: TextStyle(
          color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold));
}


String getStatusText(String status) {
  switch (status) {
    case 'waiting':
      return 'Waiting for deposit'.i18n;
    case 'pending':
      return 'Detected'.i18n;
    case 'processing':
      return 'Confirmed'.i18n;
    case 'review':
      return 'Under human review'.i18n;
    case 'settling':
      return 'Settlement in progress'.i18n;
    case 'settled':
      return 'Settlement completed'.i18n;
    case 'refund':
      return 'Queued for refund'.i18n;
    case 'refunding':
      return 'Refund in progress'.i18n;
    case 'refunded':
      return 'Refund completed'.i18n;
    case 'expired':
      return 'Shift expired'.i18n;
    case 'multiple':
      return 'Multiple deposits detected'.i18n;
    default:
      return 'Unknown'.i18n;
  }
}