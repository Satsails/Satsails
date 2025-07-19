import 'package:Satsails/helpers/formatters.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';

class ConfirmSparkBitcoinPayment extends ConsumerStatefulWidget {
  const ConfirmSparkBitcoinPayment({super.key});

  @override
  _ConfirmSparkBitcoinPaymentState createState() =>
      _ConfirmSparkBitcoinPaymentState();
}

class _ConfirmSparkBitcoinPaymentState extends ConsumerState<ConfirmSparkBitcoinPayment> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isProcessing = false;
  bool isInputBlocked = false;
  late String initialAddress;

  @override
  void initState() {
    super.initState();
    final btcFormat = ref.read(settingsProvider).btcFormat;
    final sendAmount = ref.read(sendTxProvider).btcBalanceInDenominationFormatted(btcFormat);

    // Block input if sendAmount is different from 0 on page load
    isInputBlocked = sendAmount != 0;

    // Set initial amount in the controller
    controller.text = sendAmount == 0 ? '' : (btcFormat == 'sats' ? sendAmount.toStringAsFixed(0) : sendAmount.toStringAsFixed(8));

    // Store initial address for rollback and set it in the controller
    initialAddress = ref.read(sendTxProvider).address;
    addressController.text = initialAddress;
  }

  @override
  void dispose() {
    controller.dispose();
    addressController.dispose();
    super.dispose();
  }

  String shortenAddress(String address, {int startLength = 6, int endLength = 6}) {
    if (address.length <= startLength + endLength + 70) {
      return address;
    } else {
      return '${address.substring(0, startLength)}...${address.substring(address.length - endLength)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendTxState = ref.read(sendTxProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final sparkBitcoinbalance = ref.watch(balanceNotifierProvider).sparkBitcoinbalance;
    final lightningBalanceInFormat = btcInDenominationFormatted(sparkBitcoinbalance!, btcFormat);
    int maxAmount = (sparkBitcoinbalance * 0.995).toInt();

    final currency = ref.read(settingsProvider).currency;
    final currencyRate = ref.read(selectedCurrencyProvider(currency));
    final valueInBtc = sparkBitcoinbalance / 100000000;
    final balanceInSelectedCurrency = (valueInBtc * currencyRate).toStringAsFixed(2);

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
              title: Text('Send'.i18n, style: const TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () {
                  if (!isProcessing) {
                    context.pop();
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
                              color: const Color(0x00333333).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Lightning Balance'.i18n,
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                ),
                                Text(
                                  '$lightningBalanceInFormat $btcFormat',
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
                          // Recipient Address Input Field with Camera Icon
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
                                  color: const Color(0x00333333).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: TextFormField(
                                  controller: addressController,
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Lightning or bitcoin address'.i18n,
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.w),
                                      onPressed: () async {
                                        final scannedData = await context.pushNamed('camera', extra: {'paymentType': 'Spark'});
                                        if (scannedData != null) {
                                          addressController.text = scannedData as String;
                                          ref.read(sendTxProvider.notifier).updateAddress(scannedData);
                                        }
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
                          // Amount Input
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
                                  color: const Color(0x00333333).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          enabled: !isInputBlocked,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: ref.watch(inputCurrencyProvider) == 'Sats'
                                              ? [DecimalTextInputFormatter(decimalRange: 0)]
                                              : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)],
                                          style: TextStyle(fontSize: 24.sp, color: Colors.white),
                                          textAlign: TextAlign.left,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0',
                                            hintStyle: const TextStyle(color: Colors.white70),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                          ),
                                          onChanged: (value) async {
                                            final amountInSats = calculateAmountInSatsToDisplay(
                                              value,
                                              ref.watch(inputCurrencyProvider),
                                              ref.watch(currencyNotifierProvider),
                                            );
                                            if (amountInSats > maxAmount) {
                                              showMessageSnackBar(
                                                message: "Balance insufficient to cover fees".i18n,
                                                error: true,
                                                context: context,
                                              );
                                            } else {
                                              ref.read(sendTxProvider.notifier).updateAmountFromInput(amountInSats.toString(), 'sats');
                                            }
                                          },
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 80.w,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                dropdownColor: const Color(0xFF212121),
                                                value: ref.watch(inputCurrencyProvider),
                                                items: [
                                                  DropdownMenuItem(value: 'BTC', child: Padding(padding: EdgeInsets.only(left: 16.w), child: Text('BTC', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)))),
                                                  DropdownMenuItem(value: 'USD', child: Padding(padding: EdgeInsets.only(left: 16.w), child: Text('USD', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)))),
                                                  DropdownMenuItem(value: 'EUR', child: Padding(padding: EdgeInsets.only(left: 16.w), child: Text('EUR', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)))),
                                                  DropdownMenuItem(value: 'BRL', child: Padding(padding: EdgeInsets.only(left: 16.w), child: Text('BRL', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)))),
                                                  DropdownMenuItem(value: 'Sats', child: Padding(padding: EdgeInsets.only(left: 16.w), child: Text('Sats', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)))),
                                                ],
                                                onChanged: (value) {
                                                  ref.read(inputCurrencyProvider.notifier).state = value.toString();
                                                  controller.text = '';
                                                  ref.read(sendTxProvider.notifier).updateAmountFromInput('0', 'sats');
                                                },
                                                icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
                                                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 8.sp),
                                            child: GestureDetector(
                                              onTap: () async {
                                                final amountToSetInSelectedCurrency = calculateAmountInSelectedCurrency(maxAmount, ref.watch(inputCurrencyProvider), ref.watch(currencyNotifierProvider));
                                                final amountInSats = calculateAmountInSatsToDisplay(
                                                  amountToSetInSelectedCurrency,
                                                  ref.watch(inputCurrencyProvider),
                                                  ref.watch(currencyNotifierProvider),
                                                );
                                                ref.read(sendTxProvider.notifier).updateAmountFromInput(amountInSats.toString(), 'sats');
                                                controller.text = ref.watch(inputCurrencyProvider) == 'BTC'
                                                    ? amountToSetInSelectedCurrency
                                                    : ref.watch(inputCurrencyProvider) == 'Sats'
                                                    ? double.parse(amountToSetInSelectedCurrency).toStringAsFixed(0)
                                                    : double.parse(amountToSetInSelectedCurrency).toStringAsFixed(2);
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
                          // Transaction Details
                          Card(
                            color: const Color(0x00333333).withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            margin: EdgeInsets.zero,
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
                                      Text(
                                        'Amount:'.i18n,
                                        style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        currencyFormat(Decimal.parse(ref.watch(bitcoinValueInCurrencyProvider).toString()), ref.watch(settingsProvider).currency),
                                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Lightning fees are dynamic. We reserve 0.5% for routing fees. Unused amounts will be returned.'.i18n,
                                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                  // Action Slider
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ActionSlider.standard(
                      sliderBehavior: SliderBehavior.stretch,
                      width: double.infinity,
                      backgroundColor: Colors.black,
                      toggleColor: Colors.orange,
                      action: (controller) async {
                        if (sendTxState.amount == 0) {
                          showMessageSnackBar(
                            message: "Amount cannot be zero".i18n,
                            error: true,
                            context: context,
                          );
                          controller.reset();
                          return;
                        }
                        setState(() {
                          isProcessing = true;
                        });
                        controller.loading();
                        try {
                          showFullscreenTransactionSendModal(
                            context: context,
                            asset: 'Lightning',
                            amount: btcInDenominationFormatted(sendTxState.amount, btcFormat),
                            fiat: false,
                            receiveAddress: ref.read(sendTxProvider).address,
                          );
                          ref.read(sendTxProvider.notifier).resetToDefault();
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