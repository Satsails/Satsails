import 'package:Satsails/helpers/formatters.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/models/address_model.dart';
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
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Future<bool> showConfirmationModal(
    BuildContext context, int amountInSats, String address, int fee, String btcFormat, WidgetRef ref) async {
  final settings = ref.read(settingsProvider);
  final currency = settings.currency;

  // Perform all formatting and calculations precisely inside the modal
  final amountInBtcFormat = btcInDenominationFormatted(amountInSats, btcFormat);
  final amountInCurrency = ref.read(conversionToFiatProvider(amountInSats));

  String shortenAddress(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Card(
              color: const Color(0xFF333333),
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
                            style: TextStyle(color: Colors.grey[400], fontSize: 20.sp),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$amountInBtcFormat $btcFormat',
                                style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '$amountInCurrency $currency',
                                style: TextStyle(color: Colors.grey[400], fontSize: 18.sp),
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
                            style: TextStyle(color: Colors.grey[400], fontSize: 20.sp),
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
                              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey[700], height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fee'.i18n,
                            style: TextStyle(color: Colors.grey[400], fontSize: 20.sp),
                          ),
                          Text(
                            '$fee sats',
                            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancel'.i18n,
                            style: TextStyle(color: Colors.grey[400], fontSize: 18.sp, fontWeight: FontWeight.w600),
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
                            style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600),
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
  ) ??
      false;
}

Widget buildTransactionDetailsCard(WidgetRef ref) {
  final settings = ref.watch(settingsProvider);
  final currency = settings.currency;
  final amountInSats = ref.watch(sendTxProvider).amount;

  final amountInCurrency = ref.read(conversionToFiatProvider(amountInSats));

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
              Text('Amount:'.i18n, style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
              Text('$amountInCurrency $currency', style: TextStyle(fontSize: 16.sp, color: Colors.white)),
            ],
          ),
          SizedBox(height: 16.h),
          ref.watch(feeProvider).when(
            data: (int fee) {
              final feeInCurrency = ref.read(conversionToFiatProvider(fee));
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fee:'.i18n, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('$fee sats', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fee in $currency:'.i18n, style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('$feeInCurrency $currency', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              );
            },
            loading: () => LoadingAnimationWidget.progressiveDots(size: 16.sp, color: Colors.white),
            error: (error, stack) => TextButton(
              onPressed: () => ref.refresh(feeProvider),
              child: Text(
                ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
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
        : (Decimal.tryParse(converted) ?? Decimal.zero).toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    final sendTxState = ref.read(sendTxProvider);
    updateControllerText(sendTxState.amount);
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
    final settings = ref.watch(settingsProvider);
    final btcFormat = settings.btcFormat;
    final currency = settings.currency;

    final onChainBalanceSats = ref.watch(balanceNotifierProvider).onChainBtcBalance;
    final btcBalanceInFormat = btcInDenominationFormatted(onChainBalanceSats, btcFormat);
    final balanceInSelectedCurrency = ref.read(conversionToFiatProvider(onChainBalanceSats));

    return PopScope(
      canPop: !isProcessing,
      onPopInvoked: (bool canPop) {
        if (isProcessing) {
          showMessageSnackBarInfo(message: "Transaction in progress, please wait.".i18n, context: context);
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
                              color: const Color(0x00333333).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Text('Bitcoin Balance'.i18n, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                                Text('$btcBalanceInFormat $btcFormat', style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
                                Text('$balanceInSelectedCurrency $currency', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Text('Recipient Address'.i18n, style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
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
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.camera_alt, color: Colors.white, size: 24.w),
                                      onPressed: () => context.pushNamed('camera', extra: {'paymentType': PaymentType.Bitcoin}),
                                    ),
                                  ),
                                  onChanged: (value) => ref.read(sendTxProvider.notifier).updateAddress(value),
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
                                child: Text('Amount'.i18n, style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
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
                                            ref.read(inputAmountProvider.notifier).state = controller.text.isEmpty ? '0.0' : controller.text;
                                            if (value.isEmpty) {
                                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                                              ref.read(sendTxProvider.notifier).updateDrain(false);
                                              return;
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
                                            width: 80.w,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                dropdownColor: const Color(0xFF212121),
                                                value: ref.watch(inputCurrencyProvider),
                                                items: ['BTC', 'USD', 'EUR', 'BRL', 'Sats']
                                                    .map((value) => DropdownMenuItem(
                                                  value: value,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: 16.w),
                                                    child: Text(value, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                                  ),
                                                ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  ref.read(inputCurrencyProvider.notifier).state = value.toString();
                                                  controller.text = '';
                                                  ref.read(sendTxProvider.notifier).updateAmountFromInput('0', 'sats');
                                                  ref.read(sendTxProvider.notifier).updateDrain(false);
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
                                                try {
                                                  final balance = ref.read(balanceNotifierProvider).onChainBtcBalance;
                                                  final txBuilderParams = await ref.watch(bitcoinTransactionBuilderProvider(ref.read(sendTxProvider).amount).future);
                                                  final transaction = await ref.watch(buildDrainWalletBitcoinTransactionProvider(txBuilderParams).future);
                                                  final fee = (transaction.$1.feeAmount() ?? BigInt.zero).toInt();
                                                  final amountToSet = (balance - fee);
                                                  updateControllerText(amountToSet);
                                                  ref.read(sendTxProvider.notifier).updateAmountFromInput(amountToSet.toString(), 'sats');
                                                  ref.read(sendTxProvider.notifier).updateDrain(true);
                                                } catch (e) {
                                                  showMessageSnackBar(message: e.toString().i18n, error: true, context: context);
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                                                child: Text('Max', style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
                  ActionSlider.standard(
                    sliderBehavior: SliderBehavior.stretch,
                    width: double.infinity,
                    backgroundColor: Colors.black,
                    toggleColor: Colors.orange,
                    action: (controller) async {
                      setState(() => isProcessing = true);
                      controller.loading();
                      try {
                        final sendTxState = ref.read(sendTxProvider);
                        final fee = await ref.read(feeProvider.future);
                        final confirmed = await showConfirmationModal(
                          context,
                          sendTxState.amount, // Pass raw sats amount
                          sendTxState.address ?? '',
                          fee,
                          btcFormat,
                          ref,
                        );

                        if (confirmed) {
                          final tx = await ref.read(sendBitcoinTransactionProvider.future);
                          showFullscreenTransactionSendModal(
                            context: context,
                            asset: 'Bitcoin',
                            amount: btcInDenominationFormatted(sendTxState.amount, btcFormat),
                            fiat: false,
                            txid: tx,
                            receiveAddress: ref.read(sendTxProvider).address,
                            confirmationBlocks: ref.read(sendBlocksProvider).toInt(),
                          );
                          ref.read(sendTxProvider.notifier).resetToDefault();
                          ref.read(sendBlocksProvider.notifier).state = 1;
                          context.replace('/home');
                        } else {
                          controller.reset();
                        }
                      } catch (e) {
                        controller.failure();
                        showMessageSnackBar(message: e.toString().i18n, error: true, context: context);
                        controller.reset();
                      } finally {
                        setState(() => isProcessing = false);
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