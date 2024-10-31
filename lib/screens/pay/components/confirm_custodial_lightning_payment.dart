import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/validations/address_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/coinos.provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConfirmCustodialLightningPayment extends ConsumerStatefulWidget {
  ConfirmCustodialLightningPayment({Key? key}) : super(key: key);

  @override
  _ConfirmCustodialLightningPaymentState createState() =>
      _ConfirmCustodialLightningPaymentState();
}

class _ConfirmCustodialLightningPaymentState extends ConsumerState<ConfirmCustodialLightningPayment> {
  final TextEditingController controller = TextEditingController();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    final btcFormat = ref.read(settingsProvider).btcFormat;
    final sendAmount = ref.read(sendTxProvider).btcBalanceInDenominationFormatted(btcFormat);
    controller.text = sendAmount == 0 ? '' : (btcFormat == 'sats' ? sendAmount.toStringAsFixed(0) : sendAmount.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String shortenAddress(String address, {int startLength = 6, int endLength = 6}) {
    if (address.length <= startLength + endLength) {
      return address;
    } else {
      return address.substring(0, startLength) + '...' + address.substring(address.length - endLength);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final titleFontSize = screenHeight * 0.03;
    final sendTxState = ref.watch(sendTxProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final lightningBalance = ref.watch(balanceNotifierProvider).lightningBalance;
    final lightningBalanceInFormat = btcInDenominationFormatted(lightningBalance!, btcFormat);
    final sendAmount = ref.watch(sendTxProvider).btcBalanceInDenominationFormatted(btcFormat);
    final currency = ref.read(settingsProvider).currency;
    final currencyRate = ref.read(selectedCurrencyProvider(currency));
    final valueInBtc = lightningBalance! / 100000000;
    final balanceInSelectedCurrency = (valueInBtc * currencyRate).toStringAsFixed(2);

    final dynamicFontSize = screenHeight * 0.02;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicMargin = MediaQuery.of(context).size.width * 0.05;
    final dynamicSizedBox = screenHeight * 0.01;

    return WillPopScope(
      onWillPop: () async {
        if (isProcessing) {
          Fluttertoast.showToast(
            msg: "Transaction in progress, please wait.".i18n(ref),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return false;
        } else {
          ref.read(sendTxProvider.notifier).resetToDefault();
          context.replace('/home');
          return true;
        }
      },
      child: SafeArea(
        child: FlutterKeyboardDoneWidget(
          doneWidgetBuilder: (context) {
            return const Text(
              'Done',
            );
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text('Confirm Payment'.i18n(ref), style: const TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  context.pop();
                },
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(dynamicPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              elevation: 10,
                              margin: EdgeInsets.only(bottom: dynamicMargin),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: MediaQuery.of(context).size.height < 800 ? dynamicPadding : dynamicPadding * 2,
                                      horizontal: dynamicPadding * 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Lightning Balance'.i18n(ref),
                                          style: TextStyle(fontSize: titleFontSize / 1.5, color: Colors.black),
                                          textAlign: TextAlign.center),
                                      SizedBox(height: dynamicSizedBox),
                                      Text('$lightningBalanceInFormat $btcFormat',
                                          style: TextStyle(fontSize: titleFontSize, color: Colors.black, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                      Text('$balanceInSelectedCurrency $currency',
                                          style: TextStyle(fontSize: titleFontSize, color: Colors.black), textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: sendTxState.address));
                              Fluttertoast.showToast(
                                msg: "Address copied to clipboard".i18n(ref),
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.orange,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: EdgeInsets.all(dynamicPadding / 2),
                              child: Text(
                                shortenAddress(sendTxState.address),
                                style: TextStyle(
                                  fontSize: titleFontSize / 1.5,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(height: dynamicSizedBox * 2),
                          Text(
                            'Amount'.i18n(ref),
                            style: TextStyle(
                              fontSize: dynamicFontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: dynamicSizedBox),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: ref.watch(inputCurrencyProvider) == 'Sats'
                                      ? [DecimalTextInputFormatter(decimalRange: 0)]
                                      : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)],
                                  style: TextStyle(fontSize: dynamicFontSize * 2.5, color: Colors.white),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: TextStyle(color: Colors.white),
                                  ),
                                  onChanged: (value) async {
                                    ref.read(inputAmountProvider.notifier).state = controller.text.isEmpty ? '0.0' : controller.text;
                                    if (value.isEmpty) {
                                      ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                                    }
                                    final amountInSats = calculateAmountInSatsToDisplay(
                                      value,
                                      ref.watch(inputCurrencyProvider),
                                      ref.watch(currencyNotifierProvider),
                                    );
                                    ref.read(sendTxProvider.notifier).updateAmountFromInput(amountInSats.toString(), 'sats');
                                  },
                                ),
                              ),
                              SizedBox(width: dynamicPadding / 2),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.orange,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () async {
                                      try {
                                        final balance = ref.watch(balanceNotifierProvider).lightningBalance;
                                        final amountToSet = balance;
                                        final selectedCurrency = ref.watch(inputCurrencyProvider);
                                        final amountToSetInSelectedCurrency = calculateAmountInSelectedCurrency(
                                            amountToSet!, selectedCurrency, ref.watch(currencyNotifierProvider));
                                        ref.read(sendTxProvider.notifier).updateAmountFromInput(amountToSet.toString(), 'sats');
                                        controller.text = selectedCurrency == 'BTC'
                                            ? amountToSetInSelectedCurrency
                                            : selectedCurrency == 'Sats'
                                            ? double.parse(amountToSetInSelectedCurrency).toStringAsFixed(0)
                                            : double.parse(amountToSetInSelectedCurrency).toStringAsFixed(2);
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: e.toString().i18n(ref),
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: dynamicPadding / 1.5, vertical: dynamicPadding / 2.5),
                                      child: Text(
                                        'Max',
                                        style: TextStyle(
                                          fontSize: dynamicFontSize,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: dynamicSizedBox),
                          Text(
                            '${ref.watch(bitcoinValueInCurrencyProvider).toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                            style: TextStyle(
                              fontSize: dynamicFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: dynamicSizedBox * 2),
                          Text(
                            'Currency'.i18n(ref),
                            style: TextStyle(
                              fontSize: dynamicFontSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: dynamicSizedBox),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text(
                                "Select Currency",
                                style: TextStyle(fontSize: dynamicFontSize, color: Colors.white),
                              ),
                              dropdownColor: const Color(0xFF2B2B2B),
                              value: ref.watch(inputCurrencyProvider),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'BTC',
                                  child: Center(
                                    child: Text('BTC', style: TextStyle(color: Color(0xFFD98100))),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'USD',
                                  child: Center(
                                    child: Text('USD', style: TextStyle(color: Color(0xFFD98100))),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'EUR',
                                  child: Center(
                                    child: Text('EUR', style: TextStyle(color: Color(0xFFD98100))),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'BRL',
                                  child: Center(
                                    child: Text('BRL', style: TextStyle(color: Color(0xFFD98100))),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Sats',
                                  child: Center(
                                    child: Text('Sats', style: TextStyle(color: Color(0xFFD98100))),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                ref.read(inputCurrencyProvider.notifier).state = value.toString();
                                controller.text = '';
                                ref.read(sendTxProvider.notifier).updateAmountFromInput('0', 'sats');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: ActionSlider.standard(
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
                          final invoice = await getLnInvoiceWithAmount(sendTxState.address, sendTxState.amount);
                          ref.read(sendTxProvider.notifier).updateAddress(invoice);
                          await ref.read(sendPaymentProvider.future);
                          Fluttertoast.showToast(
                            msg: "Transaction Sent".i18n(ref),
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          ref.read(sendTxProvider.notifier).resetToDefault();
                          context.replace('/home');
                        } catch (e) {
                          controller.failure();
                          Fluttertoast.showToast(
                            msg: e.toString().i18n(ref),
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          controller.reset();
                        } finally {
                          setState(() {
                            isProcessing = false;
                          });
                        }
                      },
                      child: Text('Slide to send'.i18n(ref), style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
