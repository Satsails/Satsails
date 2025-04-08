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

Future<bool> showConfirmationModal(BuildContext context, String amount, String address, int fee, String btcFormat, WidgetRef ref) async {
  final settings = ref.read(settingsProvider);
  final currency = settings.currency;
  final amountInCurrency = ref.read(bitcoinValueInCurrencyProvider);

  // Split address for stylish display (matching shortenString logic)
  String shortenAddress(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF212121),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 4,
        contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h), // Using ScreenUtil
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Center(
                child: Text(
                  'Confirm Transaction'.i18n,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp, // Using ScreenUtil
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24.h), // Using ScreenUtil

              // Amount
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h), // Using ScreenUtil
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount'.i18n,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16.sp, // Using ScreenUtil
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$amount $btcFormat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp, // Using ScreenUtil
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${currencyFormat(amountInCurrency, currency)} $currency',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14.sp, // Using ScreenUtil
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Recipient
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h), // Using ScreenUtil
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipient'.i18n,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16.sp, // Using ScreenUtil
                      ),
                    ),
                    SizedBox(height: 6.h), // Using ScreenUtil
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), // Using ScreenUtil
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(6.r), // Using ScreenUtil
                      ),
                      child: Expanded(
                        child: Text(
                          shortenAddress(address),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp, // Using ScreenUtil
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Fee
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h), // Using ScreenUtil
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fee'.i18n,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16.sp, // Using ScreenUtil
                      ),
                    ),
                    Text(
                      '$fee sats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp, // Using ScreenUtil
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel'.i18n,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16.sp, // Using ScreenUtil
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)), // Using ScreenUtil
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h), // Using ScreenUtil
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Confirm'.i18n,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp, // Using ScreenUtil
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 16.h), // Using ScreenUtil
      );
    },
  ) ?? false;
}

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

  void updateControllerText(int satsAmount) {
    final selectedCurrency = ref.read(inputCurrencyProvider);
    if (satsAmount == 0) {
      controller.text = '';
      return;
    }

    final converted = calculateAmountInSelectedCurrency(
      satsAmount,
      selectedCurrency,
      ref.read(currencyNotifierProvider),
    );

    controller.text = selectedCurrency == 'BTC'
        ? converted
        : selectedCurrency == 'Sats'
        ? satsAmount.toString()
        : double.parse(converted).toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    btcFormat = settings.btcFormat;
    currency = settings.currency;
    currencyRate = ref.read(selectedCurrencyProvider(currency));

    final sendTxState = ref.read(sendTxProvider);
    updateControllerText(sendTxState.amount);
    final address = sendTxState.address;
    if (address != null) {
      addressController.text = address;
    } else {
      addressController.text = '';
    }
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
              title: Text('Confirm Payment'.i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (!isProcessing) {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    ref.read(sendBlocksProvider.notifier).state = 1;
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
                        // Get the current transaction details
                        final sendTxState = ref.read(sendTxProvider);
                        final fee = await ref.read(liquidFeeProvider.future);

                        // Show confirmation modal
                        final confirmed = await showConfirmationModal(
                          context,
                          btcInDenominationFormatted(sendTxState.amount, btcFormat),
                          sendTxState.address ?? '',
                          fee,
                          btcFormat,
                          ref
                        );

                        if (confirmed) {
                          // Proceed with transaction only if user confirms
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
      ),
    );
  }
}
