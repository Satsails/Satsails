import 'package:Satsails/helpers/formatters.dart';
import 'package:Satsails/models/boltz_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:boltz/boltz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:intl/intl.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/providers/boltz_provider.dart';

final selectedBoltzTransactionProvider = StateProvider<BoltzTransaction?>((ref) => null);

String shortenAddress(String address, [int start = 6, int end = 4]) {
  if (address.length <= start + end) {
    return address;
  }
  return '${address.substring(0, start)}...${address.substring(address.length - end)}';
}

class BoltzTransactionDetailsScreen extends ConsumerWidget {
  const BoltzTransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(selectedBoltzTransactionProvider);

    // Handle case where no transaction is selected
    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'Boltz Transaction Details'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w),
            onPressed: () => context.pop(),
          ),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No transaction selected'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ),
      );
    }

    final swap = transaction.details.swap;
    final bool isRefundCase = swap.kind == SwapType.submarine;
    final bool isCompleted = transaction.details.completed ?? false;
    final bool isTxExpired = _isExpired(transaction.details.timestamp);

    bool shouldShowButton = false;
    // For refund cases (Submarine Swaps), show button if not completed. Expiration doesn't prevent refund.
    if (isRefundCase) {
      shouldShowButton = true;
    }
    // For other cases (like Reverse Swaps/Claim), show button only if not completed and not expired.
    else if (!isRefundCase && !isCompleted && !isTxExpired) {
      shouldShowButton = true;
    }

    String locale = I18n.locale.languageCode;
    final formattedDate = DateFormat('d MMMM, HH:mm', locale).format(DateTime.fromMillisecondsSinceEpoch(transaction.details.timestamp));
    final expiresAtText = _formatExpiresAt(transaction.details.timestamp);
    final statusText = _getStatusText(transaction.details.completed, transaction.details);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Boltz Transaction Details'.i18n,
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
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _boltzTransactionTypeIcon(swap.kind),
                        SizedBox(width: 8.w),
                        _swapStatusIcon(transaction.details.completed, transaction.details),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _getSwapTypeText(swap.kind),
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
              TransactionDetailRow(label: 'ID'.i18n, value: swap.id, isCopiable: true),
              TransactionDetailRow(label: 'Status'.i18n, value: statusText),
              TransactionDetailRow(label: 'Type'.i18n, value: _getSwapTypeText(swap.kind)),
              TransactionDetailRow(label: 'Expires At'.i18n, value: expiresAtText),
              SizedBox(height: 16.h),
              Text(
                'Swap Details'.i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              if (swap.kind == SwapType.reverse) ...[
                TransactionDetailRow(label: 'Invoice'.i18n, value: shortenAddress(swap.invoice), isCopiable: true),
                TransactionDetailRow(label: 'Receive Address'.i18n, value: swap.scriptAddress, isCopiable: true, isAddress: true),
                TransactionDetailRow(label: 'Amount'.i18n, value: _formatAmount(swap.outAmount, ref)),
              ] else ...[
                TransactionDetailRow(label: 'Deposit Address'.i18n, value: swap.scriptAddress, isCopiable: true, isAddress: true),
                TransactionDetailRow(label: 'Invoice'.i18n, value: swap.invoice, isCopiable: true),
                TransactionDetailRow(label: 'Amount to Send'.i18n, value: _formatAmount(swap.outAmount, ref)),
              ],
              SizedBox(height: 16.h),
              Text(
                'Additional Info'.i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TransactionDetailRow(label: 'Network'.i18n, value: swap.network.toString()),
              TransactionDetailRow(label: 'Electrum URL'.i18n, value: swap.electrumUrl),
              TransactionDetailRow(label: 'Boltz URL'.i18n, value: swap.boltzUrl),
              if (!isCompleted && isTxExpired) ...[
                SizedBox(height: 16.h),
                Text(
                  'Transaction Expired'.i18n,
                  style: TextStyle(color: Colors.red, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please contact support if you need assistance.'.i18n,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
              if (shouldShowButton)
                _buildActionButton(context, ref, transaction.details),
            ],
          ),
        ),
      ),
    );
  }

  String _getSwapTypeText(SwapType kind) {
    switch (kind) {
      case SwapType.submarine:
        return 'Submarine Swap'.i18n;
      case SwapType.reverse:
        return 'Reverse Swap'.i18n;
      default:
        return 'Unknown'.i18n;
    }
  }

  String _getStatusText(bool? completed, LbtcBoltz transaction) {
    if (completed == true) {
      return 'Completed'.i18n;
    } else if (_isExpired(transaction.timestamp)) {
      return 'Expired'.i18n;
    } else {
      return 'Pending'.i18n;
    }
  }

  Widget _boltzTransactionTypeIcon(SwapType kind) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333),
      ),
      child: Center(
        child: Icon(
          Icons.swap_horiz,
          color: Colors.orange,
          size: 24.w,
        ),
      ),
    );
  }

  Widget _swapStatusIcon(bool? completed, LbtcBoltz transaction) {
    IconData iconData;
    Color color;
    if (completed == true) {
      iconData = Icons.check_circle;
      color = Colors.green;
    } else if (_isExpired(transaction.timestamp)) {
      iconData = Icons.cancel;
      color = Colors.red;
    } else {
      iconData = Icons.alarm;
      color = Colors.orange;
    }
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF333333),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: color,
          size: 24.w,
        ),
      ),
    );
  }

  String _formatExpiresAt(int timestamp) {
    final creationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expireTime = creationTime.add(const Duration(hours: 24));
    final now = DateTime.now();
    if (expireTime.isBefore(now)) {
      return 'Expired'.i18n;
    } else {
      final difference = expireTime.difference(now);
      if (difference.inDays > 0) {
        return '${difference.inDays} days'.i18n.fill(difference.inDays);
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours'.i18n.fill(difference.inHours);
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes'.i18n.fill(difference.inMinutes);
      } else {
        return 'Expires soon'.i18n;
      }
    }
  }

  bool _isExpired(int timestamp) {
    final creationTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expireTime = creationTime.add(const Duration(hours: 24));
    return expireTime.isBefore(DateTime.now());
  }

  String _formatAmount(int satoshis, WidgetRef ref) {
    final denomination = ref.read(settingsProvider).btcFormat;
    return btcInDenominationFormatted(satoshis, denomination);
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, LbtcBoltz transaction) {
    final swap = transaction.swap;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: CustomButton(
        onPressed: () async {
          try {
            if (swap.kind == SwapType.reverse) {
              await ref.read(claimSingleBoltzTransactionProvider(swap.id).future);
              FocusScope.of(context).unfocus();
              showMessageSnackBar(
                message: 'Claim initiated successfully'.i18n,
                error: false,
                context: context,
              );
            } else {
              await ref.read(refundSingleBoltzTransactionProvider(swap.id).future);
              FocusScope.of(context).unfocus();
              showMessageSnackBar(
                message: 'Refund initiated successfully'.i18n,
                error: false,
                context: context,
              );
            }
          } catch (e) {
            FocusScope.of(context).unfocus();
            showMessageSnackBar(
              message: 'Action failed'.i18n,
              error: true,
              context: context,
            );
          }
        },
        text: swap.kind == SwapType.reverse ? 'Claim'.i18n : 'Refund'.i18n,
        primaryColor: swap.kind == SwapType.reverse ? Colors.green : Colors.red,
        secondaryColor: swap.kind == SwapType.reverse ? Colors.green : Colors.red,
      ),
    );
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
