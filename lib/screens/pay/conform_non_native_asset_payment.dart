import 'dart:async';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ConfirmNonNativeAssetPayment extends ConsumerStatefulWidget {
  const ConfirmNonNativeAssetPayment({super.key});

  @override
  _ConfirmNonNativeAssetPaymentState createState() => _ConfirmNonNativeAssetPaymentState();
}

class _ConfirmNonNativeAssetPaymentState extends ConsumerState<ConfirmNonNativeAssetPayment> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isProcessing = false;

  late String depositCoin;
  late String settleCoin;
  late String depositNetwork;
  late String settleNetwork;
  late String btcFormat;

  @override
  void initState() {
    super.initState();
    final shiftPair = ref.read(selectedSendShiftPairProvider);
    final params = shiftParamsMap[shiftPair]!;
    depositCoin = params.depositCoin;
    settleCoin = params.settleCoin;
    depositNetwork = params.depositNetwork;
    settleNetwork = params.settleNetwork;
    btcFormat = ref.read(settingsProvider).btcFormat;

    final sendTxState = ref.read(sendTxProvider);
    if (sendTxState.amount > 0) {
      amountController.text = sendTxState.amount.toString();
    }
    final address = sendTxState.address;
    if (address != null) {
      addressController.text = address;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Widget _buildTransactionDetailsCard(SideShift shift) {
    return Card(
      color: const Color(0x333333).withOpacity(0.4),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.only(bottom: 16.h),
          maintainState: true,
          shape: const Border(top: BorderSide(color: Colors.transparent), bottom: BorderSide(color: Colors.transparent)),
          collapsedShape: const Border(top: BorderSide(color: Colors.transparent), bottom: BorderSide(color: Colors.transparent)),
          title: Text(
            'Transaction Details'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount to Send:'.i18n, style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${shift.depositAmount} $depositCoin', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recipient Receives:'.i18n, style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                Text('${shift.settleAmount} $settleCoin', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance);

    return PopScope(
      canPop: !isProcessing,
      onPopInvoked: (bool canPop) {
        if (isProcessing) {
          showMessageSnackBarInfo(message: "Transaction in progress, please wait.".i18n, context: context);
        } else {
          ref.read(sendTxProvider.notifier).resetToDefault();
          context.replace('/home');
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('Confirm Non-Native Payment'.i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                if (!isProcessing) {
                  ref.read(sendTxProvider.notifier).resetToDefault();
                  context.replace('/home');
                } else {
                  showMessageSnackBarInfo(message: "Transaction in progress, please wait.".i18n, context: context);
                }
              },
            ),
          ),
          body: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.sp),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0x333333).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              Text(depositCoin, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                              Text(balance, style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text('Recipient Address ($settleNetwork $settleCoin)'.i18n, style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                color: const Color(0x333333).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: TextFormField(
                                controller: addressController,
                                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter recipient address'.i18n,
                                  hintStyle: TextStyle(color: Colors.white70),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.w),
                                    onPressed: () {
                                      context.pushNamed('camera', extra: {'paymentType': PaymentType.NonNative});
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  addressController.text = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                'Amount'.i18n,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0x333333).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: amountController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                                        style: TextStyle(fontSize: 24.sp, color: Colors.white),
                                        textAlign: TextAlign.left,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '0',
                                          hintStyle: TextStyle(color: Colors.white70),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                        ),
                                        onChanged: (value) {
                                          final amount = double.tryParse(value) ?? 0.0;
                                          ref.read(sendTxProvider.notifier).updateAmountFromInput(amount.toString(), btcFormat);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.sp),
                                      child: GestureDetector(
                                        onTap: () async {
                                          try {
                                            ref.read(sendTxProvider.notifier).updateAmountFromInput(balance.toString(), btcFormat);
                                            amountController.text = balance;
                                          } catch (e) {
                                            showMessageSnackBar(
                                              message: e.toString().i18n,
                                              error: true,
                                              context: context,
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            'Max',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ActionSlider.standard(
                  sliderBehavior: SliderBehavior.stretch,
                  width: double.infinity,
                  backgroundColor: Colors.black,
                  toggleColor: Colors.orange,
                  action: (controller) async {
                    setState(() {
                      isProcessing = true;
                    });
                    controller.loading();

                    try {
                      final shift = await ref.read(createSendSideShiftShiftProvider((ref.read(selectedSendShiftPairProvider), addressController.text)).future);

                      // Show confirmation dialog with transaction details
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black,
                          title: Text('Confirm Transaction'.i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp)),
                          content: SingleChildScrollView(
                            child: _buildTransactionDetailsCard(shift),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'.i18n, style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Confirm'.i18n, style: TextStyle(color: Colors.orange)),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        ref.read(sendTxProvider.notifier).updateAddress(shift.depositAddress);
                        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
                        final tx = await ref.read(liquidPayjoinTransaction.future);

                        showFullscreenTransactionSendModal(
                          context: context,
                          asset: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).name,
                          amount: btcInDenominationFormatted(ref.watch(sendTxProvider).amount, btcFormat),
                          fiat: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).isFiat,
                          fiatAmount: ref.watch(sendTxProvider).amount.toString(),
                          txid: tx,
                          isLiquid: true,
                          receiveAddress: shift.settleAddress,
                          confirmationBlocks: 1,
                        );

                        ref.read(sendTxProvider.notifier).resetToDefault();
                        context.replace('/home');
                      } else {
                        controller.reset();
                      }
                    } catch (e) {
                      controller.failure();
                      showMessageSnackBar(
                        message: e.toString().i18n,
                        error: true,
                        context: context,
                      );
                    } finally {
                      setState(() {
                        isProcessing = false;
                      });
                    }
                  },
                  child: Text('Slide to send'.i18n, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}