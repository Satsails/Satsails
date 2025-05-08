import 'package:Satsails/models/transactions_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/providers/sideshift_provider.dart';

String shortenAddress(String address, [int start = 6, int end = 4]) {
  if (address.length <= start + end) {
    return address;
  }
  return '${address.substring(0, start)}...${address.substring(address.length - end)}';
}

class SideShiftTransactionDetailsScreen extends ConsumerStatefulWidget {
  final SideShiftTransaction transaction;

  const SideShiftTransactionDetailsScreen({super.key, required this.transaction});

  @override
  _SideShiftTransactionDetailsScreenState createState() => _SideShiftTransactionDetailsScreenState();
}

class _SideShiftTransactionDetailsScreenState extends ConsumerState<SideShiftTransactionDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final details = widget.transaction.details;
    final statusText = _getStatusText(details.status);
    final formattedDate = DateFormat('d MMMM, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(details.timestamp * 1000));
    final expiresAtText = formatExpiresAt(details.expiresAt);
    final averageShiftTimeText = formatAverageShiftTime(details.averageShiftSeconds);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SideShift Transaction Details'.i18n,
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
            color: const Color(0x333333).withOpacity(0.4),
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
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _sideshiftTransactionTypeIcon(),
                        SizedBox(width: 8.w),
                        _shiftStatusIcon(details.status),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Shift'.i18n,
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade700),
              SizedBox(height: 16.h),
              Text(
                'Transaction Info'.i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TransactionDetailRow(label: 'Date'.i18n, value: formattedDate),
              TransactionDetailRow(label: 'ID'.i18n, value: details.id, isCopiable: true),
              TransactionDetailRow(label: 'Status'.i18n, value: statusText),
              TransactionDetailRow(label: 'Type'.i18n, value: details.type),
              TransactionDetailRow(label: 'Expires At'.i18n, value: expiresAtText),
              SizedBox(height: 16.h),
              Text(
                'Deposit Details'.i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TransactionDetailRow(label: 'Coin'.i18n, value: details.depositCoin),
              TransactionDetailRow(label: 'Network'.i18n, value: details.depositNetwork),
              TransactionDetailRow(label: 'Amount'.i18n, value: details.depositAmount),
              TransactionDetailRow(label: 'Address'.i18n, value: details.depositAddress, isCopiable: true, isAddress: true),
              if (details.depositMemo != null)
                TransactionDetailRow(label: 'Memo'.i18n, value: details.depositMemo!),
              TransactionDetailRow(label: 'Min'.i18n, value: details.depositMin),
              TransactionDetailRow(label: 'Max'.i18n, value: details.depositMax),
              SizedBox(height: 16.h),
              Text(
                'Settle Details'.i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TransactionDetailRow(label: 'Coin'.i18n, value: details.settleCoin),
              TransactionDetailRow(label: 'Network'.i18n, value: details.settleNetwork),
              TransactionDetailRow(label: 'Amount'.i18n, value: details.settleAmount),
              TransactionDetailRow(label: 'Address'.i18n, value: details.settleAddress, isCopiable: true, isAddress: true),
              TransactionDetailRow(label: 'Network Fee'.i18n, value: details.settleCoinNetworkFee),
              TransactionDetailRow(label: 'Network Fee USD'.i18n, value: details.networkFeeUsd),
              SizedBox(height: 16.h),
              Text(
                'Additional Info'.i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TransactionDetailRow(label: 'Average Shift Time'.i18n, value: averageShiftTimeText),
              if (details.status == 'failed') ...[
                SizedBox(height: 16.h),
                Text(
                  'Transaction Failed'.i18n,
                  style: TextStyle(color: Colors.red, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please provide a return address to receive a refund.'.i18n,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
              if (details.status == 'failed' || details.status != 'settled' && details.status != 'expired')
                ReturnAddressSection(transactionId: widget.transaction.id),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
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

  Widget _shiftStatusIcon(String status) {
    IconData iconData;
    Color color;
    switch (status) {
      case 'settled':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case 'failed':
      case 'expired':
        iconData = Icons.cancel;
        color = Colors.red;
        break;
      default:
        iconData = Icons.alarm;
        color = Colors.orange;
        break;
    }
    return circularIcon(iconData, color);
  }

  Widget _sideshiftTransactionTypeIcon() {
    return circularIcon(Icons.swap_horiz, Colors.orange);
  }

  Widget circularIcon(IconData icon, Color color) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333),
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 24.w,
        ),
      ),
    );
  }

  String formatExpiresAt(String expiresAt) {
    try {
      final expireTime = DateTime.parse(expiresAt);
      final now = DateTime.now();
      if (expireTime.isBefore(now)) {
        return 'Expired';
      } else {
        final difference = expireTime.difference(now);
        if (difference.inDays > 0) {
          return 'Expires in ${difference.inDays} days';
        } else if (difference.inHours > 0) {
          return 'Expires in ${difference.inHours} hours';
        } else if (difference.inMinutes > 0) {
          return 'Expires in ${difference.inMinutes} minutes';
        } else {
          return 'Expires soon';
        }
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  String formatAverageShiftTime(String averageShiftSeconds) {
    try {
      final seconds = int.parse(averageShiftSeconds);
      if (seconds < 60) {
        return '$seconds seconds';
      } else if (seconds < 3600) {
        final minutes = (seconds / 60).round();
        return '$minutes minutes';
      } else {
        final hours = (seconds / 3600).round();
        return '$hours hours';
      }
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

  const TransactionDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isCopiable = false,
    this.isAddress = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = isAddress ? shortenAddress(value) : value;
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
                    displayText,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
                if (isCopiable) ...[
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.orange, size: 16.w),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showMessageSnackBar(
                        message: 'Copied to clipboard'.i18n,
                        error: false,
                        context: context,
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

class ReturnAddressSection extends ConsumerStatefulWidget {
  final String transactionId;

  const ReturnAddressSection({super.key, required this.transactionId});

  @override
  _ReturnAddressSectionState createState() => _ReturnAddressSectionState();
}

class _ReturnAddressSectionState extends ConsumerState<ReturnAddressSection> {
  late TextEditingController _returnAddressController;
  String? _savedReturnAddress;

  @override
  void initState() {
    super.initState();
    _returnAddressController = TextEditingController();
    _loadReturnAddress();
  }

  Future<void> _loadReturnAddress() async {
    final box = await Hive.openBox<String>('returnAddresses');
    final address = box.get(widget.transactionId);
    if (address != null) {
      setState(() {
        _savedReturnAddress = address;
        _returnAddressController.text = address;
      });
    }
  }

  Future<void> _saveReturnAddress() async {
    final box = await Hive.openBox<String>('returnAddresses');
    await box.put(widget.transactionId, _returnAddressController.text);
    setState(() {
      _savedReturnAddress = _returnAddressController.text;
    });

    // Set the refund address using the provider
    final refundParams = RefundAddressParams(
      shiftId: widget.transactionId,
      refundAddress: _returnAddressController.text,
    );
    try {
      await ref.read(setRefundAddressProvider(refundParams).future);
      // Reload the shift after setting the refund address
      await ref.read(updateSideShiftShiftsProvider([widget.transactionId]).future);
      showMessageSnackBar(
        message: 'Refund address set and shift updated'.i18n,
        error: false,
        context: context,
      );
    } catch (e) {
      showMessageSnackBar(
        message: 'Failed to set refund address'.i18n,
        error: true,
        context: context,
      );
    }
  }

  @override
  void dispose() {
    _returnAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text(
          'Return Address'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _returnAddressController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter return address'.i18n,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade800,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.all(16.h),
          child: CustomButton(
            onPressed: _saveReturnAddress,
            text: 'Save'.i18n,
            primaryColor: Colors.green,
            secondaryColor: Colors.green,
          ),
        ),
        if (_savedReturnAddress != null) ...[
          SizedBox(height: 8.h),
          CopyText(
            text: _savedReturnAddress!,
            displayText: shortenAddress(_savedReturnAddress!),
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ],
      ],
    );
  }
}

class CopyText extends StatelessWidget {
  final String text;
  final String? displayText;
  final TextStyle style;

  const CopyText({required this.text, this.displayText, required this.style});

  @override
  Widget build(BuildContext context) {
    final String display = displayText ?? text;
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        showMessageSnackBar(
          message: 'Copied to clipboard'.i18n,
          error: false,
          context: context,
        );
      },
      child: Text(
        display,
        style: style,
        textAlign: TextAlign.right,
      ),
    );
  }
}