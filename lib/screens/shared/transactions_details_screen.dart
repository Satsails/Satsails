import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final BitcoinTransaction transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  void _showBumpFeeModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
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
    final denomination = ref.read(settingsProvider).btcFormat;
    // Condition for whether the transaction is confirmed.
    final isConfirmed = transaction.btcDetails.confirmationTime != null;
    // Condition for whether the transaction is outgoing.
    final isOutgoing = transaction.btcDetails.sent.toInt() > transaction.btcDetails.received.toInt();

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
                        transactionTypeIcon(transaction.btcDetails),
                        SizedBox(width: 8.w),
                        Image.asset(
                          'lib/assets/bitcoin-logo.png',
                          width: 40.w,
                          height: 40.h,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      confirmationStatus(transaction.btcDetails, ref) == 'Unconfirmed'.i18n
                          ? "Waiting".i18n
                          : transactionAmount(transaction.btcDetails, ref),
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade700),
              SizedBox(height: 16.h),
              Text(
                "Transaction Details".i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TransactionDetailRow(
                label: "Date".i18n,
                value: _formatTimestamp(transaction.btcDetails.confirmationTime?.timestamp.toInt()),
              ),
              TransactionDetailRow(
                label: "Status".i18n,
                value: isConfirmed ? "Confirmed".i18n : "Pending".i18n,
              ),
              TransactionDetailRow(
                label: "Confirmation block".i18n,
                value: isConfirmed
                    ? transaction.btcDetails.confirmationTime!.height.toString()
                    : "Unconfirmed".i18n,
              ),
              SizedBox(height: 16.h),
              Text(
                "Amounts".i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
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
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade700),
              GestureDetector(
                onTap: () async {
                  ref.read(transactionSearchProvider).isLiquid = false;
                  ref.read(transactionSearchProvider).txid = transaction.btcDetails.txid;
                  context.push('/search_modal');
                },
                child: Container(
                  margin: EdgeInsets.only(top: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 24.w),
                      SizedBox(width: 8.w),
                      Text(
                        "Search on Mempool".i18n,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isConfirmed && isOutgoing)
                GestureDetector(
                  onTap: () => _showBumpFeeModal(context, ref),
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rocket_launch, color: Colors.white, size: 24.w),
                        SizedBox(width: 8.w),
                        Text(
                          "Bump Fee".i18n,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null || timestamp == 0) {
      return "Unconfirmed".i18n;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.day}/${date.month}/${date.year}";
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const TransactionDetailRow({super.key, required this.label, required this.value});

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
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
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

      final txid = widget.transaction.btcDetails.txid;

      try {
        await ref.read(
          bumpBitcoinTransactionProvider(
              (txid: txid, newFeeRate: newFeeRate)
          ).future,
        );

        if (mounted) {
          showMessageSnackBar(
            message: "Fee bumped successfully!".i18n,
            error: false,
            context: context,
          );
          context.pop();
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          showMessageSnackBar(
            message: e.toString().i18n,
            error: true,
            context: context,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 20.h
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bump Transaction Fee".i18n,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20.h),
            KeyboardDismissOnTap(
              child: TextFormField(
                controller: _feeRateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "New Fee Rate (sats/vB)".i18n,
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.orange),
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
            SizedBox(height: 20.h),
            _isLoading
                ? Center(child: LoadingAnimationWidget.fourRotatingDots(size: 16.w, color: Colors.white))
                : GestureDetector(
              onTap: _submitBumpFee,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    "Confirm & Bump Fee".i18n,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
