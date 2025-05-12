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

final nonNativeAddressProvider = StateProvider<String?>((ref) => null);

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
  late int balance;

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

    balance = ref.read(balanceNotifierProvider).usdBalance;

    final sendTxState = ref.read(sendTxProvider);
    if (sendTxState.amount > 0) {
      amountController.text = sendTxState.amount.toString();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String shortenAddress(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  Future<bool> showConfirmationModal(BuildContext context, String amount, String address, String fee, String btcFormat, WidgetRef ref) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Calculate the service fee: 1% of amount
        double amountDouble = double.parse(amount);
        double serviceFeeDouble = amountDouble * 0.01;
        String serviceFee = serviceFeeDouble.toStringAsFixed(3);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Card(
                color: Color(0xFF333333),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Confirm Transaction'.i18n,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Amount'.i18n,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 20.sp,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$amount USDT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey[700], height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recipient'.i18n,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 20.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                shortenAddress(address),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Service Fee'.i18n,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 20.sp,
                              ),
                            ),
                            Text(
                              '$serviceFee USDT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey[700], height: 20.h),
                      ref.watch(payjoinFeeProvider).when(
                        data: (String fee) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payjoin fee'.i18n,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 20.sp,
                                  ),
                                ),
                                Text(
                                  '$fee USDT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => SizedBox.shrink(),
                        error: (error, stack) => SizedBox.shrink(),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              'Cancel'.i18n,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Confirm'.i18n,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scannedAddress = ref.watch(nonNativeAddressProvider);
    if (scannedAddress != null && scannedAddress != addressController.text) {
      addressController.text = scannedAddress;
    }
    final balanceText = fiatInDenominationFormatted(balance);

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
                              Text(balanceText, style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
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
                                  ref.read(sendTxProvider.notifier).updateAddress(value);
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
                                            final adjustedAmount = (balance * 0.95) / 100000000;
                                            ref.read(sendTxProvider.notifier).updateAmountFromInput(adjustedAmount.toString(), btcFormat);
                                            amountController.text = adjustedAmount.toStringAsFixed(2);
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

                      final confirmed = await showConfirmationModal(
                        context,
                        fiatInDenominationFormatted(ref.read(sendTxProvider).amount),
                        shift.settleAddress,
                        shift.networkFeeUsd,
                        btcFormat,
                        ref,
                      );

                      if (confirmed) {
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
                      controller.reset();
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