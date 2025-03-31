import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';

Widget buildTransactionDetailsCard(WidgetRef ref) {
  return Card(
    color: Color(0xFF212121),
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
        shape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        collapsedShape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        title: Text(
          'Transaction Details'.i18n,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Amount:'.i18n,
                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)
              ),
              Text(currencyFormat(ref.watch(bitcoinValueInCurrencyProvider), ref.watch(settingsProvider).currency), style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ref.watch(liquidFeeProvider).when(
            data: (int fee) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fee:'.i18n,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '$fee sats',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              );
            },
            loading: () => LoadingAnimationWidget.progressiveDots(size: 16.sp, color: Colors.white),
            error: (error, stack) => TextButton(
              onPressed: () {
                ref.refresh(feeProvider);
              },
              child: Text(
                ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          ref.watch(liquidFeeValueInCurrencyProvider).when(
            data: (double feeValue) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fee in ${ref.watch(settingsProvider).currency}:'.i18n,
                    style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currencyFormat(feeValue, ref.watch(settingsProvider).currency),
                    style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
            loading: () => LoadingAnimationWidget.progressiveDots(size: 16.sp, color: Colors.white),
            error: (error, stack) => Text(
              '',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    ),
  );
}




class ConfirmLiquidPayment extends ConsumerStatefulWidget {
  const ConfirmLiquidPayment({super.key});

  @override
  _ConfirmLiquidPaymentState createState() => _ConfirmLiquidPaymentState();
}

class _ConfirmLiquidPaymentState extends ConsumerState<ConfirmLiquidPayment> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isProcessing = false;
  late String btcFormat;
  late String currency;
  late double currencyRate;
  late dynamic sendTxState;



  @override
  void initState() {
    super.initState();
    sendTxState = ref.read(sendTxProvider);
    btcFormat = ref.read(settingsProvider).btcFormat;
    currency = ref.read(settingsProvider).currency;
    currencyRate = ref.read(selectedCurrencyProvider(currency));

    final sendAmount = sendTxState.btcBalanceInDenominationFormatted(btcFormat);
    controller.text = sendAmount == 0
        ? ''
        : (btcFormat == 'sats' ? sendAmount.toStringAsFixed(0) : sendAmount.toString());
    addressController.text = sendTxState.address;
  }

  @override
  void dispose() {
    controller.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btcBalanceInFormat = ref.read(liquidBalanceInFormatProvider(btcFormat));
    final valueInBtc = ref.watch(liquidBalanceInFormatProvider('BTC')) == '0.00000000'
        ? 0
        : double.parse(ref.watch(liquidBalanceInFormatProvider('BTC')));
    final balanceInSelectedCurrency = (valueInBtc * currencyRate).toStringAsFixed(2);
    Future.microtask(() => {
      ref.read(shouldUpdateMemoryProvider.notifier).state = false,
    });

    return PopScope(
      canPop: !isProcessing,
      onPopInvoked: (bool canPop) {
        if (isProcessing) {
          showMessageSnackBarInfo(
            message: "Transaction in progress, please wait.".i18n,
            context: context,
          );
        } else {
          ref.read(sendTxProvider.notifier).resetToDefault();
          ref.read(sendBlocksProvider.notifier).state = 1;
          ref.read(shouldUpdateMemoryProvider.notifier).state = true;
          context.replace('/home');
        }
      },
      child: SafeArea(
        child: KeyboardDismissOnTap(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text('Confirm Payment'.i18n, style: const TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (!isProcessing) {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    ref.read(sendBlocksProvider.notifier).state = 1;
                    ref.read(shouldUpdateMemoryProvider.notifier).state = true;
                    context.replace('/home');
                  } else {
                    showMessageSnackBarInfo(
                      message: "Transaction in progress, please wait.".i18n,
                      context: context,
                    );
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
                          // Balance Card
                          Container(
                            padding: EdgeInsets.all(16.sp),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF212121),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Liquid Balance'.i18n,
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                ),
                                Text(
                                  '$btcBalanceInFormat $btcFormat',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$balanceInSelectedCurrency $currency',
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Text(
                                  'Recipient Address'.i18n,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF212121),
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
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.w),
                                      onPressed: () {
                                        context.pushNamed(
                                          'camera',
                                          extra: {'paymentType': PaymentType.Liquid},
                                        );
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
                                  color: const Color(0xFF212121),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    children: [
                                      // Input Field
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: ref.watch(inputCurrencyProvider) == 'Sats'
                                              ? [DecimalTextInputFormatter(decimalRange: 0)]
                                              : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)],
                                          style: TextStyle(fontSize: 24.sp, color: Colors.white),
                                          textAlign: TextAlign.left,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0',
                                            hintStyle: TextStyle(color: Colors.white70),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                          ),
                                          onChanged: (value) async {
                                              ref.read(inputAmountProvider.notifier).state =
                                              controller.text.isEmpty ? '0.0' : controller.text;
                                              if (value.isEmpty) {
                                                ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                                                ref.read(sendTxProvider.notifier).updateDrain(false);
                                              }
                                              final amountInSats = calculateAmountInSatsToDisplay(
                                                value,
                                                ref.watch(inputCurrencyProvider),
                                                ref.watch(currencyNotifierProvider),
                                              );
                                              ref.read(sendTxProvider.notifier).updateAmountFromInput(amountInSats.toString(), 'sats');
                                              ref.read(sendTxProvider.notifier).updateDrain(false);
                                          },
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 80.w, // Updated from 100.w to match AmountInput
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    dropdownColor: const Color(0xFF212121), // Updated background color
                                                    value: ref.watch(inputCurrencyProvider),
                                                    items: [
                                                      DropdownMenuItem(
                                                        value: 'BTC',
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 16.w), // Added padding
                                                          child: Text(
                                                            'BTC',
                                                            style: TextStyle(
                                                              color: Colors.white, // White text
                                                              fontSize: 16.sp,
                                                              fontWeight: FontWeight.bold, // Bold text
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'USD',
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 16.w),
                                                          child: Text(
                                                            'USD',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16.sp,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'EUR',
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 16.w),
                                                          child: Text(
                                                            'EUR',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16.sp,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'BRL',
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 16.w),
                                                          child: Text(
                                                            'BRL',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16.sp,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'Sats',
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 16.w),
                                                          child: Text(
                                                            'Sats',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16.sp,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      ref.read(inputCurrencyProvider.notifier).state = value.toString();
                                                      controller.text = '';
                                                      ref.read(sendTxProvider.notifier).updateAmountFromInput('0', 'sats');
                                                      ref.read(sendTxProvider.notifier).updateDrain(false);
                                                    },
                                                    icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp), // Added custom icon
                                                    borderRadius: BorderRadius.all(Radius.circular(12.0)), // Added border radius
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 8.sp),
                                            child: GestureDetector(
                                              onTap: () async {
                                                try {
                                                    final pset = await ref.watch(liquidDrainWalletProvider.future);
                                                    final sendingBalance = pset.balances[0].value + pset.absoluteFees.toInt();
                                                    final controllerValue = sendingBalance.abs();
                                                    final selectedCurrency = ref.watch(inputCurrencyProvider);
                                                    final amountToSetInSelectedCurrency = calculateAmountInSelectedCurrency(
                                                        controllerValue, selectedCurrency, ref.watch(currencyNotifierProvider));
                                                    controller.text = selectedCurrency == 'BTC'
                                                        ? amountToSetInSelectedCurrency
                                                        : selectedCurrency == 'Sats'
                                                        ? double.parse(amountToSetInSelectedCurrency).toStringAsFixed(0)
                                                        : double.parse(amountToSetInSelectedCurrency).toStringAsFixed(2);
                                                    ref.read(sendTxProvider.notifier).updateAmountFromInput(
                                                        controllerValue.toString(), 'sats');
                                                    ref.read(sendTxProvider.notifier).updateDrain(true);
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
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          buildTransactionDetailsCard(ref),
                        ],
                      ),
                    ),
                  ),
                  // Action Slider
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
                        final tx = await ref.watch(sendLiquidTransactionProvider.future);
                        showFullscreenTransactionSendModal(
                          context: context,
                          asset: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).name,
                          amount: btcInDenominationFormatted(ref.watch(sendTxProvider).amount, btcFormat),
                          fiat: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).isFiat,
                          fiatAmount: ref.watch(sendTxProvider).amount.toString(),
                          txid: tx,
                          isLiquid: true,
                          receiveAddress: ref.read(sendTxProvider).address,
                          confirmationBlocks: ref.read(sendBlocksProvider.notifier).state.toInt(),
                        );

                        ref.read(sendTxProvider.notifier).resetToDefault();
                        ref.read(sendBlocksProvider.notifier).state = 1;
                        ref.read(shouldUpdateMemoryProvider.notifier).state = true;
                        context.replace('/home');
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
      ),
    );
  }
}


// class ConfirmLiquidPayment extends ConsumerStatefulWidget {
//   const ConfirmLiquidPayment({super.key});
//
//   @override
//   _ConfirmLiquidPaymentState createState() => _ConfirmLiquidPaymentState();
// }
//
// class _ConfirmLiquidPaymentState extends ConsumerState<ConfirmLiquidPayment> {
//   final TextEditingController controller = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   bool isProcessing = false;
//   late String btcFormat;
//   late String currency;
//   late double currencyRate;
//   late dynamic sendTxState;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//     sendTxState = ref.read(sendTxProvider);
//     btcFormat = ref.read(settingsProvider).btcFormat;
//     currency = ref.read(settingsProvider).currency;
//     currencyRate = ref.read(selectedCurrencyProvider(currency));
//
//     final sendAmount = sendTxState.btcBalanceInDenominationFormatted(btcFormat);
//     controller.text = sendAmount == 0
//         ? ''
//         : (btcFormat == 'sats' ? sendAmount.toStringAsFixed(0) : sendAmount.toString());
//     addressController.text = sendTxState.address;
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     addressController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final btcBalanceInFormat = ref.read(btcBalanceInFormatProvider(btcFormat));
//     final valueInBtc = ref.watch(btcBalanceInFormatProvider('BTC')) == '0.00000000'
//         ? 0
//         : double.parse(ref.watch(btcBalanceInFormatProvider('BTC')));
//     final balanceInSelectedCurrency = (valueInBtc * currencyRate).toStringAsFixed(2);
//     Future.microtask(() => {ref.read(shouldUpdateMemoryProvider.notifier).state = false});
//
//     return PopScope(
//       canPop: !isProcessing,
//       onPopInvoked: (bool canPop) {
//         if (isProcessing) {
//           showMessageSnackBarInfo(
//             message: "Transaction in progress, please wait.".i18n,
//             context: context,
//           );
//         } else {
//           ref.read(sendTxProvider.notifier).resetToDefault();
//           ref.read(sendBlocksProvider.notifier).state = 1;
//           ref.read(shouldUpdateMemoryProvider.notifier).state = true;
//           context.replace('/home');
//         }
//       },
//       child: SafeArea(
//         child: KeyboardDismissOnTap(
//           child: Scaffold(
//             resizeToAvoidBottomInset: false,
//             backgroundColor: Colors.black,
//             appBar: AppBar(
//               backgroundColor: Colors.black,
//               title: Text('Confirm Payment'.i18n, style: const TextStyle(color: Colors.white)),
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () {
//                   if (!isProcessing) {
//                     context.pop();
//                   } else {
//                     showMessageSnackBarInfo(
//                       message: "Transaction in progress, please wait.".i18n,
//                       context: context,
//                     );
//                   }
//                 },
//               ),
//             ),
//             body: Column(
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         LiquidCards(
//                           titleFontSize: titleFontSize,
//                           liquidFormart: liquidFormat,
//                           liquidBalanceInFormat: liquidBalanceInFormat,
//                           balance: balance,
//                           dynamicPadding: dynamicPadding,
//                           dynamicMargin: dynamicMargin,
//                           dynamicCardHeight: dynamicCardHeight,
//                           ref: ref,
//                           controller: controller,
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: dynamicPadding),
//                           child: Center(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(5.0),
//                                 border: Border.all(color: Colors.grey, width: 1),
//                               ),
//                               child: Padding(
//                                 padding: EdgeInsets.all(dynamicPadding / 2),
//                                 child: Text(
//                                   sendTxState.address,
//                                   style: TextStyle(
//                                     fontSize: titleFontSize / 1.5,
//                                     color: Colors.white,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: dynamicPadding / 2),
//                           child: FocusScope(
//                             child: TextFormField(
//                               controller: controller,
//                               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                               inputFormatters: ref.watch(inputCurrencyProvider) == 'Sats'
//                                   ? [DecimalTextInputFormatter(decimalRange: 0)]
//                                   : (showBitcoinRelatedWidgets.state
//                                   ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)]
//                                   : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2)]),
//                               style: TextStyle(fontSize: dynamicFontSize * 3, color: Colors.white),
//                               textAlign: TextAlign.center,
//                               decoration: InputDecoration(
//                                 border: InputBorder.none,
//                                 hintText: showBitcoinRelatedWidgets.state ? '0' : '0.00',
//                                 hintStyle: const TextStyle(color: Colors.white),
//                               ),
//                               onChanged: (value) async {
//                                 if (showBitcoinRelatedWidgets.state) {
//                                   ref.read(inputAmountProvider.notifier).state =
//                                   controller.text.isEmpty ? '0.0' : controller.text;
//                                   if (value.isEmpty) {
//                                     ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
//                                     ref.read(sendTxProvider.notifier).updateDrain(false);
//                                   }
//                                   final amountInSats = calculateAmountInSatsToDisplay(
//                                     value,
//                                     ref.watch(inputCurrencyProvider),
//                                     ref.watch(currencyNotifierProvider),
//                                   );
//                                   ref.read(sendTxProvider.notifier).updateAmountFromInput(amountInSats.toString(), 'sats');
//                                 } else {
//                                   ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
//                                 }
//                                 ref.read(sendTxProvider.notifier).updateDrain(false);
//                               },
//                             ),
//                           ),
//                         ),
//                         if (showBitcoinRelatedWidgets.state) ...[
//                           Text(
//                             '${ref.watch(bitcoinValueInCurrencyProvider).toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
//                             style: TextStyle(
//                               fontSize: dynamicFontSize / 1.5,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           SizedBox(height: dynamicSizedBox),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8.0),
//                             child: DropdownButtonHideUnderline(
//                               child: DropdownButton<String>(
//                                 hint: Text(
//                                   "Select Currency",
//                                   style: TextStyle(
//                                       fontSize: dynamicFontSize / 2.7, color: Colors.white),
//                                 ),
//                                 dropdownColor: const Color(0xFF2B2B2B),
//                                 value: ref.watch(inputCurrencyProvider),
//                                 items: const [
//                                   DropdownMenuItem(
//                                     value: 'BTC',
//                                     child: Center(
//                                       child: Text('BTC',
//                                           style: TextStyle(color: Color(0xFFD98100))),
//                                     ),
//                                   ),
//                                   DropdownMenuItem(
//                                     value: 'USD',
//                                     child: Center(
//                                       child: Text('USD',
//                                           style: TextStyle(color: Color(0xFFD98100))),
//                                     ),
//                                   ),
//                                   DropdownMenuItem(
//                                     value: 'EUR',
//                                     child: Center(
//                                       child: Text('EUR', style: TextStyle(color: Color(0xFFD98100))),
//                                     ),
//                                   ),
//                                   DropdownMenuItem(
//                                     value: 'BRL',
//                                     child: Center(
//                                       child: Text('BRL', style: TextStyle(color: Color(0xFFD98100))),
//                                     ),
//                                   ),
//                                   DropdownMenuItem(
//                                     value: 'Sats',
//                                     child: Center(
//                                       child: Text('Sats', style: TextStyle(color: Color(0xFFD98100))),
//                                     ),
//                                   ),
//                                 ],
//                                 onChanged: (value) {
//                                   ref.read(inputCurrencyProvider.notifier).state = value.toString();
//                                   controller.text = '';
//                                   ref.read(sendTxProvider.notifier).updateAmountFromInput('0', 'sats');
//                                   ref.read(sendTxProvider.notifier).updateDrain(false);
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                         SizedBox(height: dynamicSizedBox),
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: Colors.white,
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(10),
//                               onTap: () async {
//                                 final assetId = ref.watch(sendTxProvider).assetId;
//                                 try {
//                                   if (assetId == '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d') {
//                                     final pset = await ref.watch(liquidDrainWalletProvider.future);
//                                     final sendingBalance = pset.balances[0].value + pset.absoluteFees.toInt();
//                                     final controllerValue = sendingBalance.abs();
//                                     final selectedCurrency = ref.watch(inputCurrencyProvider);
//                                     final amountToSetInSelectedCurrency = calculateAmountInSelectedCurrency(
//                                         controllerValue, selectedCurrency, ref.watch(currencyNotifierProvider));
//                                     controller.text = selectedCurrency == 'BTC'
//                                         ? amountToSetInSelectedCurrency
//                                         : selectedCurrency == 'Sats'
//                                         ? double.parse(amountToSetInSelectedCurrency).toStringAsFixed(0)
//                                         : double.parse(amountToSetInSelectedCurrency).toStringAsFixed(2);
//                                     ref.read(sendTxProvider.notifier).updateAmountFromInput(
//                                         controllerValue.toString(), 'sats');
//                                     ref.read(sendTxProvider.notifier).updateDrain(true);
//                                   } else {
//                                     await ref.watch(liquidDrainWalletProvider.future);
//                                     final sendingBalance = ref.watch(assetBalanceProvider);
//                                     controller.text = fiatInDenominationFormatted(sendingBalance);
//                                     ref.read(sendTxProvider.notifier).updateAmountFromInput(
//                                         controller.text, btcFormat);
//                                   }
//                                 } catch (e) {
//                                   showMessageSnackBar(
//                                     message: e.toString().i18n,
//                                     error: true,
//                                     context: context,
//                                   );
//                                 }
//                               },
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: dynamicPadding / 1, vertical: dynamicPadding / 2.5),
//                                 child: Text(
//                                   'Max',
//                                   style: TextStyle(
//                                     fontSize: dynamicFontSize / 1,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: dynamicSizedBox),
//                         Slider(
//                           value: 16 - ref.watch(sendBlocksProvider).toDouble(),
//                           onChanged: (value) => ref.read(sendBlocksProvider.notifier).state = 16 - value,
//                           min: 1,
//                           max: 15,
//                           divisions: 14,
//                           label: ref.watch(sendBlocksProvider).toInt().toString(),
//                           activeColor: Colors.orange,
//                         ),
//                         SizedBox(height: dynamicSizedBox),
//                         ref.watch(liquidFeeProvider).when(
//                           data: (int fee) {
//                             return Text(
//                               '${'Fee:'.i18n} $fee${' sats'}',
//                               style: TextStyle(
//                                   fontSize: dynamicFontSize / 1.5,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white),
//                               textAlign: TextAlign.center,
//                             );
//                           },
//                           loading: () => LoadingAnimationWidget.progressiveDots(
//                               size: dynamicFontSize / 1.5, color: Colors.white),
//                           error: (error, stack) => TextButton(
//                               onPressed: () {
//                                 ref.refresh(feeProvider);
//                               },
//                               child: Text(sendTxState.amount == 0 ? '' : error.toString().i18n,
//                                   style: TextStyle(color: Colors.white, fontSize: dynamicFontSize / 1.5))),
//                         ),
//                         SizedBox(height: dynamicSizedBox),
//                         ref.watch(liquidFeeValueInCurrencyProvider).when(
//                           data: (double feeValue) {
//                             return Text(
//                               '${feeValue.toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
//                               style: TextStyle(
//                                   fontSize: dynamicFontSize / 1.5,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white),
//                               textAlign: TextAlign.center,
//                             );
//                           },
//                           loading: () => LoadingAnimationWidget.progressiveDots(
//                               size: dynamicFontSize / 1.5, color: Colors.black),
//                           error: (error, stack) => Text('',
//                               style: TextStyle(color: Colors.black, fontSize: dynamicFontSize / 1.5)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Center(
//                     child: ActionSlider.standard(
//                       sliderBehavior: SliderBehavior.stretch,
//                       width: double.infinity,
//                       backgroundColor: Colors.black,
//                       toggleColor: Colors.orange,
//                       action: (controller) async {
//                         setState(() {
//                           isProcessing = true;
//                         });
//                         controller.loading();
//                         try {
//                           final tx = await ref.watch(sendLiquidTransactionProvider.future);
//                           showFullscreenTransactionSendModal(
//                             context: context,
//                             asset: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).name,
//                             amount: btcInDenominationFormatted(ref.watch(sendTxProvider).amount, btcFormat),
//                             fiat: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).isFiat,
//                             fiatAmount: ref.watch(sendTxProvider).amount.toString(),
//                             txid: tx,
//                             isLiquid: true,
//                             receiveAddress: ref.read(sendTxProvider).address,
//                             confirmationBlocks: ref.read(sendBlocksProvider.notifier).state.toInt(),
//                           );
//
//                           ref.read(sendTxProvider.notifier).resetToDefault();
//                           ref.read(sendBlocksProvider.notifier).state = 1;
//                           context.replace('/home');
//                         } catch (e) {
//                           controller.failure();
//                           showMessageSnackBar(
//                             message: e.toString().i18n,
//                             error: true,
//                             context: context,
//                           );
//                           controller.reset();
//                         } finally {
//                           setState(() {
//                             isProcessing = false;
//                           });
//                         }
//                       },
//                       child: Text('Slide to send'.i18n, style: const TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
