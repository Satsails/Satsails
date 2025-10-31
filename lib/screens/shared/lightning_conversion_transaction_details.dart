import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:intl/intl.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

final selectedLightningTransactionProvider = StateProvider<LightningConversionTransaction?>((ref) => null);

class LightningConversionTransactionDetails extends ConsumerWidget {
  const LightningConversionTransactionDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(selectedLightningTransactionProvider);

    if (transaction == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text('Transaction Details'.i18n, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.black),
        body: Center(child: Text('No transaction selected'.i18n, style: TextStyle(color: Colors.white, fontSize: 16.sp))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'.i18n, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: false,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w), onPressed: () => context.pop()),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
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

  Widget _buildHeader(BuildContext context, WidgetRef ref, LightningConversionTransaction transaction) {
    final payment = transaction.details;
    final isReceiving = payment.paymentType == breez.PaymentType.receive;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [lightningTransactionTypeIcon(), SizedBox(width: 8.w), paymentStatusIcon(payment.status)],
          ),
          SizedBox(height: 12.h),
          Text(_formatAmount(payment.amountSat.toInt(), ref), style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(isReceiving ? "Lightning → L-BTC".i18n : "L-BTC → Lightning".i18n, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, WidgetRef ref, LightningConversionTransaction transaction) {
    final payment = transaction.details;
    final details = payment.details as breez.PaymentDetails_Lightning;
    final locale = I18n.locale.languageCode;
    final formattedDate = DateFormat('d MMMM, HH:mm', locale).format(DateTime.fromMillisecondsSinceEpoch(payment.timestamp * 1000));
    final statusText = getStatusText(payment.status);
    final statusColor = getStatusColor(payment.status);

    final bool canValidate = details.invoice != null && details.preimage != null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Transaction Info'.i18n),
          TransactionDetailRow(label: 'Date'.i18n, value: formattedDate),
          TransactionDetailRow(label: 'Status'.i18n, value: statusText, valueColor: statusColor),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildSectionHeader('Payment Details'.i18n),
          TransactionDetailRow(label: 'Fee'.i18n, value: _formatAmount(payment.feesSat.toInt(), ref)),
          if (details.description.isNotEmpty) TransactionDetailRow(label: 'Description'.i18n, value: details.description),
          if (payment.txId != null)
            TransactionDetailRow(
              label: 'On-chain TXID'.i18n,
              value: payment.txId!,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: payment.txId!));
                showMessageSnackBar(context: context, message: 'TXID Copied'.i18n, error: false, info: true);
              },
            ),
          TransactionDetailRow(
            label: 'Swap ID'.i18n,
            value: details.swapId,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: details.swapId));
              showMessageSnackBar(context: context, message: 'Swap ID Copied'.i18n, error: false, info: true);
            },
          ),
          if (details.invoice != null)
            TransactionDetailRow(
              label: 'Invoice'.i18n,
              value: details.invoice!,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: details.invoice!));
                showMessageSnackBar(context: context, message: 'Invoice Copied'.i18n, error: false, info: true);
              },
            ),
          if (details.preimage != null)
            TransactionDetailRow(
              label: 'Payment Preimage'.i18n,
              value: details.preimage!,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: details.preimage!));
                showMessageSnackBar(context: context, message: 'Preimage Copied'.i18n, error: false, info: true);
              },
            ),
          if (canValidate)
            TransactionDetailRow(
              label: 'Confirmation Link'.i18n,
              value: 'Tap to copy'.i18n,
              onCopy: () {
                final uri = Uri.https('validate-payment.com', '', {
                  'invoice': details.invoice,
                  'preimage': details.preimage,
                });
                Clipboard.setData(ClipboardData(text: uri.toString()));
                showMessageSnackBar(context: context, message: 'Confirmation Link Copied'.i18n, error: false, info: true);
              },
            ),
          SizedBox(height: 16.h),
          _buildActionButtons(context, ref, payment),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, breez.Payment payment) {
    final details = payment.details as breez.PaymentDetails_Lightning;
    final isRefundable = payment.status == breez.PaymentState.refundable || payment.status == breez.PaymentState.waitingFeeAcceptance;
    final isRefundedOrPending = payment.status == breez.PaymentState.failed || payment.status == breez.PaymentState.refundPending;
    final hasTimedOut = payment.status == breez.PaymentState.timedOut;

    final List<Widget> actionWidgets = [];

    if (details.invoice != null && details.preimage != null) {
      actionWidgets.add(
        _buildActionButton(
          text: 'Check payment completion'.i18n,
          icon: Icons.open_in_new,
          buttonColor: Colors.white.withOpacity(0.15),
          textColor: Colors.white,
          onPressed: () async {
            final uri = Uri.https('validate-payment.com', '', {
              'invoice': details.invoice,
              'preimage': details.preimage,
            });

            // Use url_launcher to open in an external browser
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              } else {
                showMessageSnackBar(context: context, message: 'Could not open link'.i18n, error: true);
              }
            } catch (e) {
              showMessageSnackBar(context: context, message: 'An error occurred'.i18n, error: true);
            }
          },
        ),
      );
    }

    if (isRefundable) {
      if (actionWidgets.isNotEmpty) actionWidgets.add(SizedBox(height: 12.h));
      actionWidgets.add(
        _buildActionButton(
          text: 'Refund Transaction'.i18n,
          icon: Icons.undo_rounded,
          buttonColor: Colors.red.withOpacity(0.25),
          textColor: Colors.red.shade300,
          onPressed: () async {},
        ),
      );
    } else if (isRefundedOrPending) {
      actionWidgets.add(Center(child: Text('This transaction has been refunded'.i18n, style: TextStyle(color: Colors.green, fontSize: 16.sp))));
    } else if (hasTimedOut) {
      actionWidgets.add(Center(child: Text('This transaction has timed out'.i18n, style: TextStyle(color: Colors.red, fontSize: 16.sp))));
    }

    if (actionWidgets.isEmpty) return const SizedBox.shrink();
    return Column(children: actionWidgets);
  }

  Widget _buildActionButton({required String text, required IconData icon, required Color buttonColor, required Color textColor, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(14.r)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: textColor, size: 20.w), SizedBox(width: 8.w), Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15.sp))]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: EdgeInsets.only(top: 16.h, bottom: 8.h), child: Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)));
  }

  String _formatAmount(int satoshis, WidgetRef ref) {
    if (satoshis == 0) return "0 sats";
    return btcInDenominationFormatted(satoshis, ref.read(settingsProvider).btcFormat);
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final Color? valueColor;
  const TransactionDetailRow({super.key, required this.label, required this.value, this.onCopy, this.valueColor});

  String shortenString(String input) {
    if (input.length <= 12) return input;
    return '${input.substring(0, 6)}...${input.substring(input.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isLongValue = value.length > 25;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp)),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: onCopy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
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