import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConfirmBitcoinPayment extends ConsumerStatefulWidget {
  ConfirmBitcoinPayment({Key? key}) : super(key: key);

  @override
  _ConfirmBitcoinPaymentState createState() => _ConfirmBitcoinPaymentState();
}

class _ConfirmBitcoinPaymentState extends ConsumerState<ConfirmBitcoinPayment> {
  final TextEditingController controller = TextEditingController();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    final btcFormat = ref.read(settingsProvider).btcFormat;
    final sendAmount = ref.read(sendTxProvider).btcBalanceInDenominationFormatted(btcFormat);
    controller.text = sendAmount == 0
        ? ''
        : (btcFormat == 'sats' ? sendAmount.toStringAsFixed(0) : sendAmount.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final titleFontSize = screenHeight * 0.03;
    final sendTxState = ref.watch(sendTxProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormat));
    final currency = ref.read(settingsProvider).currency;
    final currencyRate = ref.read(selectedCurrencyProvider(currency));
    final valueInBtc = ref.watch(btcBalanceInFormatProvider('BTC')) == '0.00000000'
        ? 0
        : double.parse(ref.watch(btcBalanceInFormatProvider('BTC')));
    final balanceInSelectedCurrency = (valueInBtc * currencyRate).toStringAsFixed(2);

    final dynamicFontSize = screenHeight * 0.02;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicMargin = MediaQuery.of(context).size.width * 0.05;
    final dynamicSizedBox = screenHeight * 0.01;

    return PopScope(
      canPop: !isProcessing, // Determines if the screen can be popped
      onPopInvokedWithResult: (didPop, result) async {
        if (isProcessing) {
          Fluttertoast.showToast(
            msg: "Transaction in progress, please wait.".i18n(ref),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          ref.read(sendTxProvider.notifier).resetToDefault();
          ref.read(sendBlocksProvider.notifier).state = 1;
          context.replace('/home');
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
                  if (!isProcessing) {
                    context.pop();
                  } else {
                    Fluttertoast.showToast(
                      msg: "Transaction in progress, please wait.".i18n(ref),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.orange,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Balance Card
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            elevation: 10,
                            margin: EdgeInsets.all(dynamicMargin),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight < 800 ? dynamicPadding : dynamicPadding * 2,
                                    horizontal: dynamicPadding * 2),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Bitcoin Balance'.i18n(ref),
                                        style: TextStyle(fontSize: titleFontSize / 1.5, color: Colors.black),
                                        textAlign: TextAlign.center),
                                    Column(
                                      children: [
                                        Text('$btcBalanceInFormat $btcFormat',
                                            style: TextStyle(fontSize: titleFontSize, color: Colors.black, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
                                        Text('$balanceInSelectedCurrency $currency',
                                            style: TextStyle(fontSize: titleFontSize, color: Colors.black),
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Address Display
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: dynamicPadding),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(dynamicPadding / 2),
                                child: Text(
                                  sendTxState.address,
                                  style: TextStyle(
                                    fontSize: titleFontSize / 1.5,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Amount Input
                        Padding(
                          padding: EdgeInsets.only(top: dynamicPadding / 2),
                          child: FocusScope(
                            child: TextFormField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: ref.watch(inputCurrencyProvider) == 'Sats'
                                  ? [DecimalTextInputFormatter(decimalRange: 0)]
                                  : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)],
                              style: TextStyle(fontSize: dynamicFontSize * 3, color: Colors.white),
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
                        ),
                        SizedBox(height: dynamicSizedBox),
                        // Currency Value Display
                        Text(
                          '${ref.watch(bitcoinValueInCurrencyProvider).toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                          style: TextStyle(
                            fontSize: dynamicFontSize / 1.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Currency Selector
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text(
                                "Select Currency",
                                style: TextStyle(fontSize: dynamicFontSize / 2.7, color: Colors.white),
                              ),
                              dropdownColor: const Color(0xFF2B2B2B),
                              value: ref.watch(inputCurrencyProvider),
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
                                ref.read(sendTxProvider.notifier).updateDrain(false);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: dynamicSizedBox),
                        // Max Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () async {
                                try {
                                  final balance = ref.watch(balanceNotifierProvider).btcBalance;
                                  final transactionBuilderParams = await ref
                                      .watch(bitcoinTransactionBuilderProvider(sendTxState.amount).future)
                                      .then((value) => value);
                                  final transaction = await ref
                                      .watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilderParams).future)
                                      .then((value) => value);
                                  final fee = await transaction.$1.feeAmount().then((value) => value);
                                  final amountToSet = (balance - fee!);
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
                                    horizontal: dynamicPadding / 1, vertical: dynamicPadding / 2.5),
                                child: Text(
                                  'Max',
                                  style: TextStyle(
                                    fontSize: dynamicFontSize / 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: dynamicSizedBox),
                        // Slider for Transaction Speed
                        Slider(
                          value: 6 - ref.watch(sendBlocksProvider).toDouble(),
                          onChanged: (value) => ref.read(sendBlocksProvider.notifier).state = 6 - value,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: ref.watch(sendBlocksProvider).toInt().toString(),
                          activeColor: Colors.orange,
                        ),
                        Padding(
                          padding: EdgeInsets.all(dynamicPadding / 2),
                          child: Text(
                            "${"Transaction in ".i18n(ref)}${getTimeFrame(ref.watch(sendBlocksProvider).toInt(), ref)}",
                            style: TextStyle(
                              fontSize: dynamicFontSize / 1.5,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: dynamicSizedBox),
                        // Fee Display
                        ref.watch(feeProvider).when(
                          data: (int fee) {
                            return Text(
                              '${'Fee:'.i18n(ref)} $fee sats',
                              style: TextStyle(
                                  fontSize: dynamicFontSize / 1.5, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            );
                          },
                          loading: () => LoadingAnimationWidget.progressiveDots(
                              size: dynamicFontSize / 1.5, color: Colors.white),
                          error: (error, stack) => TextButton(
                            onPressed: () {
                              ref.refresh(feeProvider);
                            },
                            child: Text(sendTxState.amount == 0 ? '' : error.toString().i18n(ref),
                                style: TextStyle(color: Colors.white, fontSize: dynamicFontSize / 1.5)),
                          ),
                        ),
                        // Fee in Selected Currency
                        ref.watch(feeValueInCurrencyProvider).when(
                          data: (double feeValue) {
                            return Text(
                              '${feeValue.toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                              style: TextStyle(
                                fontSize: dynamicFontSize / 1.5,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                          loading: () => LoadingAnimationWidget.progressiveDots(
                              size: dynamicFontSize / 1.5, color: Colors.white),
                          error: (error, stack) => Text('',
                              style: TextStyle(color: Colors.white, fontSize: dynamicFontSize / 1.5)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Action Slider
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
                          await ref.watch(sendBitcoinTransactionProvider.future);
                          await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
                          Fluttertoast.showToast(
                            msg: "Transaction Sent".i18n(ref),
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          ref.read(sendTxProvider.notifier).resetToDefault();
                          ref.read(sendBlocksProvider.notifier).state = 1;
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
