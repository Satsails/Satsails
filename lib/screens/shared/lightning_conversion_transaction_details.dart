import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:intl/intl.dart';
import 'package:Satsails/screens/shared/message_display.dart';

final selectedLightningTransactionProvider =
StateProvider<LightningConversionTransaction?>((ref) => null);

class LightningConversionTransactionDetails extends ConsumerWidget {
  const LightningConversionTransactionDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(selectedLightningTransactionProvider);

    if (transaction == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Transaction Details'.i18n),
          backgroundColor: Colors.black,
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

    final payment = transaction.details;
    final details = payment.details as breez.PaymentDetails_Lightning;
    final isReceiving = payment.paymentType == breez.PaymentType.receive;
    final isRefundable = payment.status == breez.PaymentState.refundable ||
        payment.status == breez.PaymentState.waitingFeeAcceptance;
    final isRefundedOrPending =
        payment.status == breez.PaymentState.failed ||
            payment.status == breez.PaymentState.refundPending;
    final hasTimedOut = payment.status == breez.PaymentState.timedOut;

    final title =
    isReceiving ? "Lightning → L-BTC".i18n : "L-BTC → Lightning".i18n;
    final locale = I18n.locale.languageCode;
    final formattedDate = DateFormat('d MMMM, HH:mm', locale)
        .format(DateTime.fromMillisecondsSinceEpoch(payment.timestamp * 1000));
    final statusText = getStatusText(payment.status);

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
                        lightningTransactionTypeIcon(),
                        SizedBox(width: 8.w),
                        paymentStatusIcon(payment.status),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      title,
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(color: Colors.grey),
              _buildSectionHeader('Transaction Info'.i18n),
              TransactionDetailRow(label: 'Date'.i18n, value: formattedDate),
              TransactionDetailRow(label: 'Status'.i18n, value: statusText),
              SizedBox(height: 16.h),
              const Divider(color: Colors.grey),
              _buildSectionHeader('Payment Details'.i18n),
              TransactionDetailRow(
                  label: 'Amount'.i18n,
                  value: _formatAmount(payment.amountSat.toInt(), ref)),
              TransactionDetailRow(
                  label: 'Fee'.i18n,
                  value: _formatAmount(payment.feesSat.toInt(), ref)),
              if (details.description.isNotEmpty)
                TransactionDetailRow(
                    label: 'Description'.i18n, value: details.description),
              if (payment.txId != null)
                TransactionDetailRow(
                    label: 'On-chain TXID'.i18n,
                    value: shortenValue(payment.txId!),
                    fullValue: payment.txId,
                    isCopiable: true),
              TransactionDetailRow(
                  label: 'Swap ID'.i18n,
                  value: shortenValue(details.swapId),
                  fullValue: details.swapId,
                  isCopiable: true),
              if (details.invoice != null)
                TransactionDetailRow(
                    label: 'Invoice'.i18n,
                    value: shortenValue(details.invoice!),
                    fullValue: details.invoice,
                    isCopiable: true),
              if (details.paymentHash != null)
                TransactionDetailRow(
                    label: 'Payment Hash'.i18n,
                    value: shortenValue(details.paymentHash!),
                    fullValue: details.paymentHash,
                    isCopiable: true),
              SizedBox(height: 24.h),
              if (isRefundable)
                _buildRefundAction(context, ref, details.swapId),
              if (isRefundedOrPending)
                Center(
                  child: Text(
                    'This transaction has been refunded'
                        .i18n,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.green, fontSize: 16.sp),
                  ),
                ),
              if (hasTimedOut)
                Center(
                  child: Text(
                    'This transaction has timed out and cannot be recovered'
                        .i18n,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16.sp),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefundAction(
      BuildContext context, WidgetRef ref, String swapId) {
    return CustomButton(
      text: 'Refund Transaction'.i18n,
      primaryColor: Colors.red,
      onPressed: () async {
        try {
          final recommendedFees =
          await ref.read(recommendedFeesProvider.future);
          final feeRateSatPerVbyte = recommendedFees.economyFee.toInt();
          final refundAddress = ref.read(addressProvider).liquidAddress;

          await ref.read(
            refundProvider(
              (
              swapAddress: swapId,
              refundAddress: refundAddress,
              feeRateSatPerVbyte: feeRateSatPerVbyte,
              ),
            ).future,
          );

          if (context.mounted) {
            showMessageSnackBar(
                message: 'Refund initiated successfully.'.i18n,
                context: context,
                error: false);
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            showMessageSnackBar(
              message: 'Refund failed: $e'.i18n,
              context: context,
              error: true,
            );
          }
        }
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatAmount(int satoshis, WidgetRef ref) {
    if (satoshis == 0) return "0 sats";
    final denomination = ref.read(settingsProvider).btcFormat;
    return btcInDenominationFormatted(satoshis, denomination);
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? fullValue;
  final bool isCopiable;

  const TransactionDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.fullValue,
    this.isCopiable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey, fontSize: 16.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
                if (isCopiable)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.copy, color: Colors.orange, size: 18.w),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: fullValue ?? value));
                      showMessageSnackBar(
                        message: 'Copied to clipboard'.i18n,
                        context: context,
                        error: false,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}