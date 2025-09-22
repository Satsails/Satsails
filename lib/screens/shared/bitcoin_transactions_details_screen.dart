import 'dart:ui';

import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BitcoinTransactionDetailsScreen extends ConsumerWidget {
  final BitcoinTransaction transaction;

  const BitcoinTransactionDetailsScreen({super.key, required this.transaction});

  void _showBumpFeeModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF212121),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return BumpFeeModalSheet(transaction: transaction);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Transaction Details'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            _buildHeader(context, ref),
            SizedBox(height: 24.h),
            _buildDetailsCard(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currencyRate = ref.watch(selectedCurrencyProvider(settings.currency));
    final totalAmount = (transaction.btcDetails.sent - transaction.btcDetails.received).abs();
    final fiatValue = totalAmount.toDouble() / 100000000 * currencyRate;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Color(0x00333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              transactionTypeIcon(transaction.btcDetails),
              SizedBox(width: 8.w),
              Image.asset('lib/assets/bitcoin-logo.png', width: 32.w),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            transactionAmount(transaction.btcDetails, ref),
            style: TextStyle(
                color: Colors.white,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            currencyFormat(fiatValue, settings.currency),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, WidgetRef ref) {
    final denomination = ref.read(settingsProvider).btcFormat;
    final isConfirmed = transaction.btcDetails.confirmationTime != null;
    final isOutgoing = transaction.btcDetails.sent > transaction.btcDetails.received;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0x00333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Transaction Details".i18n),
          SizedBox(height: 8.h),
          TransactionDetailRow(
            label: "Date".i18n,
            value: _formatTimestamp(transaction.btcDetails.confirmationTime?.timestamp.toInt()),
          ),
          TransactionDetailRow(
            label: "Status".i18n,
            value: confirmationStatus(transaction.btcDetails, ref),
            valueColor: _getStatusColor(confirmationStatus(transaction.btcDetails, ref)),
          ),
          TransactionDetailRow(
            label: "Confirmation Block".i18n,
            value: isConfirmed
                ? transaction.btcDetails.confirmationTime!.height.toString()
                : "N/A".i18n,
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildSectionHeader("Amounts".i18n),
          SizedBox(height: 8.h),

          if (isOutgoing) ...[
            TransactionDetailRow(
              label: "Amount Sent".i18n,
              value: "${btcInDenominationFormatted(
                  (transaction.btcDetails.sent - transaction.btcDetails.received - (transaction.btcDetails.fee ?? BigInt.zero)).toInt(),
                  denomination)} $denomination",
            ),
            if (transaction.btcDetails.fee != null)
              TransactionDetailRow(
                label: "Fee".i18n,
                value: "${btcInDenominationFormatted(transaction.btcDetails.fee!.toInt(), denomination)} $denomination",
              ),
          ] else ...[
            // For incoming transactions, the original view is clearer.
            TransactionDetailRow(
              label: "Received".i18n,
              value: "${btcInDenominationFormatted(transaction.btcDetails.received.toInt(), denomination)} $denomination",
            ),
            TransactionDetailRow(
              label: "Sent".i18n,
              value: "${btcInDenominationFormatted(transaction.btcDetails.sent.toInt(), denomination)} $denomination",
            ),
            if (transaction.btcDetails.fee != null)
              TransactionDetailRow(
                label: "Fee".i18n,
                value: "${btcInDenominationFormatted(transaction.btcDetails.fee!.toInt(), denomination)} $denomination",
              ),
          ],
          // --- MODIFICATION END ---

          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
          color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final isConfirmed = transaction.btcDetails.confirmationTime != null;
    final isOutgoing = transaction.btcDetails.sent > transaction.btcDetails.received;
    final canBumpFee = !isConfirmed && isOutgoing;

    final mempoolButton = _buildActionButton(
        icon: Icons.travel_explore,
        label: "Mempool".i18n,
        onPressed: () {
          ref.read(transactionSearchProvider).isLiquid = false;
          ref.read(transactionSearchProvider).txid = transaction.btcDetails.txid;
          context.push('/search_modal');
        },
        buttonColor: Colors.white.withOpacity(0.15),
        textColor: Colors.white);

    final bumpFeeButton = _buildActionButton(
        icon: Icons.rocket_launch,
        label: "Bump Fee".i18n,
        onPressed: () => _showBumpFeeModal(context, ref),
        buttonColor: Colors.green.withOpacity(0.25),
        textColor: Colors.green.shade300);

    if (canBumpFee) {
      return Row(
        children: [
          Expanded(child: mempoolButton),
          SizedBox(width: 12.w),
          Expanded(child: bumpFeeButton),
        ],
      );
    } else {
      return mempoolButton;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color buttonColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Confirmed'.i18n) return Colors.green.shade400;
    if (status == 'Unconfirmed'.i18n || status == 'Pending'.i18n) return Colors.orange.shade400;
    return Colors.white;
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null || timestamp == 0) {
      return "Pending".i18n;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('d MMM yyyy, HH:mm').format(date);
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const TransactionDetailRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class BumpFeeModalSheet extends ConsumerStatefulWidget {
  final BitcoinTransaction transaction;
  const BumpFeeModalSheet({super.key, required this.transaction});

  @override
  _BumpFeeModalSheetState createState() => _BumpFeeModalSheetState();
}

class _BumpFeeModalSheetState extends ConsumerState<BumpFeeModalSheet> {
  final _feeRateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _feeRateController.dispose();
    super.dispose();
  }

  Future<void> _submitBumpFee() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final newFeeRate = double.tryParse(_feeRateController.text);
      if (newFeeRate == null) {
        setState(() => _isLoading = false);
        return;
      }
      try {
        await ref.read(
          bumpBitcoinTransactionProvider(
              (txid: widget.transaction.btcDetails.txid, newFeeRate: newFeeRate))
              .future,
        );
        if (mounted) {
          showMessageSnackBar(
              message: "Fee bumped successfully!".i18n,
              error: false,
              context: context);
          // Pop twice to close the modal and the details screen
          context.pop();
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          showMessageSnackBar(
              message: e.toString().i18n, error: true, context: context);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF212121), // Solid dark grey color
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24.w,
              right: 24.w,
              top: 20.h,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.rocket_launch_outlined,
                      size: 40.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Bump Transaction Fee".i18n,
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Increase the fee to speed up your transaction".i18n,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    KeyboardDismissOnTap(
                      child: TextFormField(
                        controller: _feeRateController,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          labelText: "New Fee Rate (sats/vB)".i18n,
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                            const BorderSide(color: Colors.orange),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a fee rate.".i18n;
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number.".i18n;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _isLoading
                        ? Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                          size: 40.h, color: Colors.white),
                    )
                        : CustomButton(
                      text: "Confirm & Bump Fee".i18n,
                      onPressed: _submitBumpFee,
                      primaryColor: Colors.white.withOpacity(0.2),
                      secondaryColor: Colors.white.withOpacity(0.15),
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}