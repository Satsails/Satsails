import 'package:Satsails/helpers/formatters.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/validations/address_validation.dart';
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

class ConfirmBoltzPayment extends ConsumerStatefulWidget {
  const ConfirmBoltzPayment({super.key});

  @override
  _ConfirmBoltzPaymentState createState() => _ConfirmBoltzPaymentState();
}

class _ConfirmBoltzPaymentState extends ConsumerState<ConfirmBoltzPayment> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isProcessing = false;
  late String btcFormat;
  bool isInvoice = false;
  late String currency;
  int _previousAmount = 0;

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
    final settings = ref.read(settingsProvider);
    btcFormat = settings.btcFormat;
    currency = settings.currency;

    final sendTxState = ref.read(sendTxProvider);
    _previousAmount = sendTxState.amount;
    updateControllerText(sendTxState.amount);
    if (isLightningInvoice(sendTxState.address)) {
      isInvoice = true;
    }
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
    final sendTxState = ref.watch(sendTxProvider);

    if (sendTxState.amount != _previousAmount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateControllerText(sendTxState.amount);
      });
      _previousAmount = sendTxState.amount;
    }

    final liquidBalanceSats = ref.watch(balanceNotifierProvider).liquidBtcBalance;
    final btcBalanceInFormat = btcInDenominationFormatted(liquidBalanceSats, btcFormat);
    final balanceInSelectedCurrency = ref.read(conversionToFiatProvider(liquidBalanceSats));

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
                                  'Balance'.i18n,
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
                                          extra: {'paymentType': PaymentType.Lightning},
                                        );
                                      },
                                    ),
                                  ),
                                  onChanged: (value) {
                                    ref.read(sendTxProvider.notifier).updateAddress(value);
                                    if (isLightningInvoice(value)) {
                                      try {
                                        final amount = invoiceAmount(value);
                                        ref.read(sendTxProvider.notifier).updateAmount(amount);
                                        ref.read(sendTxProvider.notifier).updatePaymentType(PaymentType.Lightning);
                                        setState(() {
                                          isInvoice = true;
                                        });
                                      } catch (e) {
                                        showMessageSnackBar(
                                          message: 'Invalid Lightning invoice'.i18n,
                                          error: true,
                                          context: context,
                                        );
                                        setState(() {
                                          isInvoice = false;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        isInvoice = false;
                                      });
                                    }
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
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters: ref.watch(inputCurrencyProvider) == 'Sats'
                                              ? [DecimalTextInputFormatter(decimalRange: 0)]
                                              : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)],
                                          style: TextStyle(fontSize: 24.sp, color: Colors.white),
                                          textAlign: TextAlign.left,
                                          readOnly: isInvoice,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0',
                                            hintStyle: const TextStyle(color: Colors.white70),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                          ),
                                          onChanged: (value) {
                                            if (!isInvoice) {
                                              ref.read(inputAmountProvider.notifier).state =
                                              controller.text.isEmpty ? '0.0' : controller.text;
                                              if (value.isEmpty) {
                                                ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                                                ref.read(sendTxProvider.notifier).updateDrain(false);
                                              } else {
                                                final amountInSats = calculateAmountInSatsToDisplay(
                                                  value,
                                                  ref.watch(inputCurrencyProvider),
                                                  ref.watch(currencyNotifierProvider),
                                                );
                                                ref.read(sendTxProvider.notifier).updateAmountFromInput(amountInSats.toString(), 'sats');
                                                ref.read(sendTxProvider.notifier).updateDrain(false);
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 80.w,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    dropdownColor: const Color(0xFF212121),
                                                    value: ref.watch(inputCurrencyProvider),
                                                    items: ['BTC', 'USD', 'EUR', 'BRL', 'Sats']
                                                        .map((currency) => DropdownMenuItem(
                                                      value: currency,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(left: 16.w),
                                                        child: Text(
                                                          currency,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.sp,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                        .toList(),
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        ref.read(inputCurrencyProvider.notifier).state = value;
                                                        final currentAmountSats = ref.read(sendTxProvider).amount;
                                                        final selectedCurrency = value;
                                                        final converted = calculateAmountInSelectedCurrency(
                                                          currentAmountSats,
                                                          selectedCurrency,
                                                          ref.read(currencyNotifierProvider),
                                                        );
                                                        controller.text = selectedCurrency == 'BTC'
                                                            ? converted
                                                            : selectedCurrency == 'Sats'
                                                            ? currentAmountSats.toString()
                                                            : (Decimal.tryParse(converted) ?? Decimal.zero).toStringAsFixed(2);
                                                      }
                                                    },
                                                    icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
                                                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                                  ),
                                                ),
                                              ],
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
                        final sendTxState = ref.read(sendTxProvider);
                        final invoice = await getLnInvoiceWithAmount(sendTxState.address, sendTxState.amount);
                        ref.read(sendTxProvider.notifier).updateAddress(invoice);
                        await ref.read(boltzPayProvider.future);

                        showFullscreenTransactionSendModal(
                          context: context,
                          asset: 'Lightning',
                          amount: btcInDenominationFormatted(sendTxState.amount, btcFormat),
                          fiat: false,
                          receiveAddress: ref.read(sendTxProvider).address,
                        );

                        ref.read(sendTxProvider.notifier).resetToDefault();
                        ref.read(sendBlocksProvider.notifier).state = 1;
                        context.replace('/home');
                      } catch (e) {
                        ref.read(sendTxProvider.notifier).updateAddress(addressController.text);
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