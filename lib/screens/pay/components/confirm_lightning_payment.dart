import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

Future<bool> showConfirmationModal(BuildContext context, String amount, String address, int fee, String btcFormat, WidgetRef ref) async {
  final settings = ref.read(settingsProvider);
  final currency = settings.currency;
  final amountInCurrency = ref.read(bitcoinValueInCurrencyProvider);

  String shortenAddress(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

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
    barrierDismissible: false,
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
                Text(
                  'Confirm Transaction'.i18n,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
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
                  '≈ ${currencyFormat(amountInCurrency, currency)} $currency',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18.sp,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Divider(color: Colors.white.withOpacity(0.15)),
                ),
                buildDetailRow(
                  label: 'Recipient'.i18n,
                  value: shortenAddress(address),
                ),
                buildDetailRow(
                  label: 'Network Fee'.i18n,
                  value: '$fee sats',
                ),
                SizedBox(height: 24.h),
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
      false;
}

class ConfirmLightningPayment extends ConsumerStatefulWidget {
  const ConfirmLightningPayment({super.key});

  @override
  _ConfirmLightningPaymentState createState() => _ConfirmLightningPaymentState();
}

class _ConfirmLightningPaymentState extends ConsumerState<ConfirmLightningPayment> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  bool isProcessing = false;
  late String btcFormat;
  bool isInvoice = false;
  late String currency;
  late double currencyRate;
  bool _isDraining = false;
  bool _isAmountlessInvoice = false;

  // State for variable amount invoices
  int? _minAmountSats;
  int? _maxAmountSats;

  void updateControllerText(int satsAmount) {
    final selectedCurrency = ref.read(inputCurrencyProvider);
    if (satsAmount == 0) {
      controller.text = '';
      return;
    }
    final converted = calculateAmountInSelectedCurrency(satsAmount, selectedCurrency, ref.read(currencyNotifierProvider));
    final newText = selectedCurrency == 'BTC'
        ? converted
        : selectedCurrency == 'Sats'
        ? satsAmount.toString()
        : double.parse(converted).toStringAsFixed(2);

    // Set text and move cursor to the end
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
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
    addressController.text = sendTxState.address;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && addressController.text.isNotEmpty) {
        _checkIfInvoice(addressController.text);
      }
    });
  }

  Future<void> _checkIfInvoice(String value) async {
    int? newMinSats;
    int? newMaxSats;
    bool newIsFixedInvoice = false;
    int newAmount = 0;
    bool newIsAmountlessInvoice = false;

    if (value.isNotEmpty) {
      try {
        final parsedInput = await ref.read(parseInputProvider(value).future);

        if (parsedInput is breez.InputType_Bolt11) {
          final invoice = parsedInput.invoice;
          final amount = invoice.amountMsat != null ? (invoice.amountMsat! ~/ BigInt.from(1000)).toInt() : 0;
          if (amount > 0) {
            newAmount = amount;
            newIsFixedInvoice = true;
          } else {
            newIsAmountlessInvoice = true;
          }
        } else if (parsedInput is breez.InputType_Bolt12Offer) {
          final offer = parsedInput.offer;
          newMinSats = offer.minAmount != null && offer.minAmount is breez.Amount_Bitcoin
              ? ((offer.minAmount as breez.Amount_Bitcoin).amountMsat ~/ BigInt.from(1000)).toInt()
              : 0;
        } else if (parsedInput is breez.InputType_LnUrlPay) {
          newMinSats = (parsedInput.data.minSendable ~/ BigInt.from(1000)).toInt();
          newMaxSats = (parsedInput.data.maxSendable ~/ BigInt.from(1000)).toInt();
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    ref.read(sendTxProvider.notifier).updateAmount(newAmount);

    if (newIsFixedInvoice) {
      updateControllerText(newAmount);
      ref.read(sendTxProvider.notifier).updatePaymentType(PaymentType.Lightning);
    }

    if (mounted) {
      setState(() {
        isInvoice = newIsFixedInvoice;
        _minAmountSats = newMinSats;
        _maxAmountSats = newMaxSats;
        _isAmountlessInvoice = newIsAmountlessInvoice;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    addressController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sendTxProvider);

    final btcBalanceInFormat = ref.read(liquidBalanceInFormatProvider(btcFormat));
    final valueInBtc =
    ref.watch(liquidBalanceInFormatProvider('BTC')) == '0.00000000' ? 0 : double.parse(ref.watch(liquidBalanceInFormatProvider('BTC')));
    final balanceInSelectedCurrency = (valueInBtc * currencyRate).toStringAsFixed(2);

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
                            decoration:
                            BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
                            child: Column(
                              children: [
                                Text('Lightning Balance'.i18n, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                                Text('$btcBalanceInFormat $btcFormat',
                                    style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
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
                                child: Text('Recipient Address'.i18n,
                                    style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration:
                                BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
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
                                      onPressed: () => context.pushNamed('camera', extra: {'paymentType': PaymentType.Lightning}),
                                    ),
                                  ),
                                  onChanged: (value) async {
                                    ref.read(sendTxProvider.notifier).updateAddress(value);
                                    await _checkIfInvoice(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Amount'.i18n,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      dropdownColor: const Color(0xFF212121),
                                      value: ref.watch(inputCurrencyProvider),
                                      items: ['BTC', 'USD', 'GBP', 'CHF', 'EUR', 'BRL', 'Sats']
                                          .map((String value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          ref.read(inputCurrencyProvider.notifier).state = value;
                                          updateControllerText(ref.read(sendTxProvider).amount);
                                        }
                                      },
                                      icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
                                      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                decoration:
                                BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
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
                                  readOnly: isInvoice,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                    suffixIcon: Align(
                                      widthFactor: 1.0,
                                      heightFactor: 1.0,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 12.w),
                                        child: GestureDetector(
                                          onTap: isInvoice
                                              ? null
                                              : () async {
                                            try {
                                              final input = addressController.text;
                                              if (input.isEmpty) {
                                                showMessageSnackBar(
                                                    message: "Please enter a recipient address first".i18n,
                                                    error: true,
                                                    context: context);
                                                return;
                                              }
                                              final parsedInput = await ref.read(parseInputProvider(input).future);

                                              if (parsedInput is breez.InputType_LnUrlPay) {
                                                final balance = ref.read(balanceNotifierProvider).liquidBtcBalance;
                                                ref.read(sendTxProvider.notifier).updateAmount(balance);
                                                updateControllerText(balance);
                                                setState(() {
                                                  _isDraining = true;
                                                });
                                              }
                                            } catch (e) {
                                              showMessageSnackBar(message: e.toString().i18n, error: true, context: context);
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                            decoration: BoxDecoration(
                                              color: isInvoice ? Colors.grey[700] : Colors.white,
                                              borderRadius: BorderRadius.circular(8.r),
                                            ),
                                            child: Text('Max',
                                                style: TextStyle(
                                                    color: isInvoice ? Colors.white54 : Colors.black,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (isInvoice) return;
                                    if (_isDraining) {
                                      setState(() {
                                        _isDraining = false;
                                      });
                                    }
                                    ref.read(inputAmountProvider.notifier).state = controller.text.isEmpty ? '0.0' : controller.text;
                                    if (value.isEmpty) {
                                      ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                                    } else {
                                      final amountInSats = calculateAmountInSatsToDisplay(
                                          value, ref.watch(inputCurrencyProvider), ref.watch(currencyNotifierProvider));
                                      ref.read(sendTxProvider.notifier).updateAmountFromInput(amountInSats.toString(), 'sats');
                                    }
                                  },
                                ),
                              ),
                              _buildAmountLimitsInfo(),
                            ],
                          ),
                          if (!isInvoice) ...[
                            SizedBox(height: 24.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Text('Comment (Optional)'.i18n,
                                      style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  decoration:
                                  BoxDecoration(color: const Color(0x00333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
                                  child: TextFormField(
                                    controller: commentController,
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter a comment'.i18n,
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  _isAmountlessInvoice
                      ? Container(
                    height: 75.h, // Approx height of the slider
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF212121),
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: Center(
                      child: Text(
                        'Invoices with no amount are not supported.\nTry to insert an lnurl (xxx@xxx.com)'.i18n,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                      : ActionSlider.standard(
                    sliderBehavior: SliderBehavior.stretch,
                    width: double.infinity,
                    backgroundColor: Colors.black,
                    toggleColor: const Color(0x00333333).withOpacity(0.4),
                    icon: const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.orange, // Orange arrow icon
                    ),
                    loadingIcon: const SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.orange, // Orange loading spinner
                      ),
                    ),
                    successIcon: const Icon(
                      Icons.check_rounded,
                      color: Colors.orange, // Orange success icon
                    ),
                    failureIcon: const Icon(
                      Icons.close_rounded,
                      color: Colors.orange, // Orange failure icon
                    ),
                    action: (sliderController) async {
                      setState(() => isProcessing = true);
                      sliderController.loading();

                      try {
                        final sendTxState = ref.read(sendTxProvider);
                        final amount = sendTxState.amount;

                        if (_minAmountSats != null && amount < _minAmountSats!) {
                          throw "Amount is below minimum";
                        }
                        if (_maxAmountSats != null && amount > _maxAmountSats!) {
                          throw "Amount is above maximum";
                        }

                        final paymentArgs = (
                        address: sendTxState.address,
                        amount: amount,
                        comment: commentController.text.isNotEmpty ? commentController.text : null,
                        isDraining: _isDraining,
                        );

                        final prepResponse = await ref.read(prepareLightningPaymentProvider(paymentArgs).future);

                        final bool confirmed = await showConfirmationModal(
                          context,
                          btcInDenominationFormatted(sendTxState.amount, btcFormat),
                          sendTxState.address,
                          prepResponse.networkFee,
                          btcFormat,
                          ref,
                        );

                        if (confirmed) {
                          await ref.read(sendLightningPaymentProvider(paymentArgs).future);

                          showFullscreenTransactionSendModal(
                            context: context,
                            asset: 'Lightning',
                            amount: btcInDenominationFormatted(sendTxState.amount, btcFormat),
                            fiat: false,
                            receiveAddress: sendTxState.address,
                          );

                          ref.read(sendTxProvider.notifier).resetToDefault();
                          ref.read(sendBlocksProvider.notifier).state = 1;
                          context.replace('/home');
                        } else {
                          sliderController.reset();
                          setState(() => isProcessing = false);
                        }
                      } catch (e) {
                        sliderController.failure();
                        showMessageSnackBar(message: e.toString().i18n, error: true, context: context);
                        Future.delayed(const Duration(seconds: 2), () => sliderController.reset());
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

  Widget _buildAmountLimitsInfo() {
    if (_minAmountSats == null) {
      return const SizedBox.shrink();
    }

    final selectedCurrency = ref.watch(inputCurrencyProvider);

    String formatFiat(int sats) {
      if (selectedCurrency == 'Sats' || selectedCurrency == 'BTC') {
        return calculateAmountInSelectedCurrency(sats, selectedCurrency, ref.read(currencyNotifierProvider));
      }
      final converted = double.parse(calculateAmountInSelectedCurrency(sats, selectedCurrency, ref.read(currencyNotifierProvider)));
      if (converted < 0.01) {
        return '0.01';
      }
      return converted.toStringAsFixed(2);
    }

    final minFormatted = formatFiat(_minAmountSats!);
    final maxFormatted = _maxAmountSats != null ? formatFiat(_maxAmountSats!) : null;

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Min: $minFormatted $selectedCurrency",
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          if (maxFormatted != null)
            Text(
              "Max: $maxFormatted $selectedCurrency",
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
        ],
      ),
    );
  }
}
