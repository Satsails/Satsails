import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Future<bool> showConfirmationModal(
    BuildContext context, String amount, String address, int fee, String btcFormat, WidgetRef ref) async {
  final settings = ref.read(settingsProvider);
  final currency = settings.currency;
  // Reverted to using the original provider from your code
  final amountInCurrency = ref.read(bitcoinValueInCurrencyProvider);

  // Function to shorten the address for display
  String shortenAddress(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  // A local helper for creating styled detail rows
  Widget buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16.sp)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must explicitly confirm or cancel
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
            decoration: BoxDecoration(
                color: const Color(0xFF212121),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Confirm Transaction'.i18n,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),

                // Hero Amount Section
                Text(
                  '$amount $btcFormat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${currencyFormat(amountInCurrency, currency)} $currency',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18.sp,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Divider(color: Colors.white.withOpacity(0.15)),
                ),

                // Details Section
                buildDetailRow(
                  label: 'Recipient'.i18n,
                  value: shortenAddress(address),
                ),
                buildDetailRow(
                  label: 'Fee'.i18n,
                  value: '$fee sats',
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel'.i18n,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Confirm'.i18n,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
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
      );
    },
  ) ??
      false; // Default to false if dialog is dismissed
}

Widget buildTransactionDetailsCard(WidgetRef ref) {
  return Card(
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
          ref.watch(feeProvider).when(
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
          ref.watch(feeValueInCurrencyProvider).when(
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

class ConfirmBitcoinPayment extends ConsumerStatefulWidget {
  const ConfirmBitcoinPayment({super.key});

  @override
  _ConfirmBitcoinPaymentState createState() => _ConfirmBitcoinPaymentState();
}

class _ConfirmBitcoinPaymentState extends ConsumerState<ConfirmBitcoinPayment> {
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
    addressController.text = address;
    }

  @override
  void dispose() {
    controller.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendTxState = ref.watch(sendTxProvider);
    final btcBalanceInFormat = ref.read(btcBalanceInFormatProvider(btcFormat));
    final valueInBtc = ref.watch(btcBalanceInFormatProvider('BTC')) == '0.00000000'
        ? 0
        : double.parse(ref.watch(btcBalanceInFormatProvider('BTC')));
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
              centerTitle: false,
              title: Text('Send'.i18n, style: TextStyle(color: Colors.white, fontSize: 22.sp)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                              color: const Color(0x00333333).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Bitcoin Balance'.i18n,
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
                                  color: const Color(0x00333333).withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: TextFormField(
                                  controller: addressController,
                                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter recipient address'.i18n,
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.w),
                                      onPressed: () {
                                        context.pushNamed(
                                          'camera',
                                          extra: {'paymentType': PaymentType.Bitcoin},
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
                                  color: const Color(0x00333333).withOpacity(0.4),
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
                                              : ref.watch(inputCurrencyProvider) == 'BTC'
                                              ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)]
                                              : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2)],
                                          style: TextStyle(fontSize: 24.sp, color: Colors.white),
                                          textAlign: TextAlign.left,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0',
                                            hintStyle: const TextStyle(color: Colors.white70),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                          ),
                                          onChanged: (value) async {
                                            ref.read(inputAmountProvider.notifier).state = controller.text.isEmpty ? '0.0' : controller.text;
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
                                                        value: 'GBP',
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 16.w),
                                                          child: Text(
                                                            'GBP',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16.sp,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'CHF',
                                                        child: Padding(
                                                          padding: EdgeInsets.only(left: 16.w),
                                                          child: Text(
                                                            'CHF',
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
                                                    borderRadius: const BorderRadius.all(Radius.circular(12.0)), // Added border radius
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
                                                  final balance = ref.watch(balanceNotifierProvider).onChainBtcBalance;
                                                  final transactionBuilderParams = await ref
                                                      .watch(bitcoinTransactionBuilderProvider(sendTxState.amount).future)
                                                      .then((value) => value);
                                                  final transaction = await ref
                                                      .watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilderParams).future)
                                                      .then((value) => value);
                                                  final fee = (transaction.$1.feeAmount() ?? BigInt.zero).toInt();
                                                  final amountToSet = (balance - fee);
                                                  final selectedCurrency = ref.watch(inputCurrencyProvider);
                                                  final amountToSetInSelectedCurrency = calculateAmountInSelectedCurrency(
                                                      amountToSet, selectedCurrency, ref.watch(currencyNotifierProvider));
                                                  ref.read(sendTxProvider.notifier).updateAmountFromInput(amountToSet.toString(), 'sats');
                                                  controller.text = selectedCurrency == 'BTC'
                                                      ? amountToSetInSelectedCurrency
                                                      : selectedCurrency == 'Sats'
                                                      ? double.parse(amountToSetInSelectedCurrency).toStringAsFixed(0)
                                                      : double.parse(amountToSetInSelectedCurrency).toStringAsFixed(2);
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
                          SizedBox(height: 16.h),
                          bitcoinFeeSlider(ref),
                        ],
                      ),
                    ),
                  ),
                  // Action Slider
                  ActionSlider.standard(
                    sliderBehavior: SliderBehavior.stretch,
                    width: double.infinity,
                    backgroundColor: Colors.black,
                    toggleColor: const Color(0xFF212121),
                    action: (controller) async {
                      setState(() {
                        isProcessing = true;
                      });
                      controller.loading();

                      try {
                        // Get the current transaction details
                        final sendTxState = ref.read(sendTxProvider);
                        final fee = await ref.read(feeProvider.future);

                        // Show confirmation modal
                        final confirmed = await showConfirmationModal(
                          context,
                          btcInDenominationFormatted(sendTxState.amount, btcFormat),
                          sendTxState.address ?? '',
                          fee,
                          btcFormat,
                          ref,
                        );

                        if (confirmed) {
                          // Proceed with transaction only if user confirms
                          final tx = await ref.watch(sendBitcoinTransactionProvider.future);

                          showFullscreenTransactionSendModal(
                            context: context,
                            asset: 'Bitcoin',
                            amount: btcInDenominationFormatted(sendTxState.amount, btcFormat),
                            fiat: false,
                            txid: tx,
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