import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/screens/pay/components/liquid_cards.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
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
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';

class ConfirmLiquidPayment extends ConsumerStatefulWidget {
  ConfirmLiquidPayment({Key? key}) : super(key: key);

  @override
  _ConfirmLiquidPaymentState createState() => _ConfirmLiquidPaymentState();
}

class _ConfirmLiquidPaymentState extends ConsumerState<ConfirmLiquidPayment> {
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
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;
    final sendTxState = ref.watch(sendTxProvider);
    final liquidFormat = ref.watch(settingsProvider).btcFormat;
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(liquidFormat));
    final balance = ref.watch(balanceNotifierProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicMargin = MediaQuery.of(context).size.width * 0.04;
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final showBitcoinRelatedWidgets = ref.watch(showBitcoinRelatedWidgetsProvider.notifier);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final sendAmount = ref.watch(sendTxProvider).btcBalanceInDenominationFormatted(btcFormat);

    // Update controller text when showBitcoinRelatedWidgets.state changes
    ref.listen<bool>(showBitcoinRelatedWidgetsProvider, (previous, next) {
      setState(() {
        controller.text = sendAmount == 0
            ? ''
            : (btcFormat == 'sats' ? sendAmount.toStringAsFixed(0) : sendAmount.toString());
      });
    });

    return PopScope(
      canPop: !isProcessing, // Determines if the screen can be popped
      onPopInvoked: (bool canPop) {
        if (isProcessing) {
          showBottomOverlayMessageInfo(
            message: "Transaction in progress, please wait.".i18n(ref),
            context: context,
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
            backgroundColor: Colors.black,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (!isProcessing) {
                    context.pop();
                  } else {
                    showBottomOverlayMessageInfo(
                      message: "Transaction in progress, please wait.".i18n(ref),
                      context: context,
                    );
                  }
                },
              ),
              title: Text('Confirm Payment'.i18n(ref), style: const TextStyle(color: Colors.white)),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        LiquidCards(
                          titleFontSize: titleFontSize,
                          liquidFormart: liquidFormat,
                          liquidBalanceInFormat: liquidBalanceInFormat,
                          balance: balance,
                          dynamicPadding: dynamicPadding,
                          dynamicMargin: dynamicMargin,
                          dynamicCardHeight: dynamicCardHeight,
                          ref: ref,
                          controller: controller,
                        ),
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
                        Padding(
                          padding: EdgeInsets.only(top: dynamicPadding / 2),
                          child: FocusScope(
                            child: TextFormField(
                              controller: controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: ref.watch(inputCurrencyProvider) == 'Sats'
                                  ? [DecimalTextInputFormatter(decimalRange: 0)]
                                  : (showBitcoinRelatedWidgets.state
                                  ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)]
                                  : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2)]),
                              style: TextStyle(fontSize: dynamicFontSize * 3, color: Colors.white),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: showBitcoinRelatedWidgets.state ? '0' : '0.00',
                                hintStyle: const TextStyle(color: Colors.white),
                              ),
                              onChanged: (value) async {
                                if (showBitcoinRelatedWidgets.state) {
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
                                } else {
                                  ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                                }
                                ref.read(sendTxProvider.notifier).updateDrain(false);
                              },
                            ),
                          ),
                        ),
                        if (showBitcoinRelatedWidgets.state) ...[
                          Text(
                            '${ref.watch(bitcoinValueInCurrencyProvider).toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                            style: TextStyle(
                              fontSize: dynamicFontSize / 1.5,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: dynamicSizedBox),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: Text(
                                  "Select Currency",
                                  style: TextStyle(
                                      fontSize: dynamicFontSize / 2.7, color: Colors.white),
                                ),
                                dropdownColor: const Color(0xFF2B2B2B),
                                value: ref.watch(inputCurrencyProvider),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'BTC',
                                    child: Center(
                                      child: Text('BTC',
                                          style: TextStyle(color: Color(0xFFD98100))),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'USD',
                                    child: Center(
                                      child: Text('USD',
                                          style: TextStyle(color: Color(0xFFD98100))),
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
                        ],
                        SizedBox(height: dynamicSizedBox),
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
                                final assetId = ref.watch(sendTxProvider).assetId;
                                try {
                                  if (assetId == '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d') {
                                    final pset = await ref.watch(liquidDrainWalletProvider.future);
                                    final sendingBalance = pset.balances[0].value + pset.absoluteFees;
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
                                  } else {
                                    await ref.watch(liquidDrainWalletProvider.future);
                                    final sendingBalance = ref.watch(assetBalanceProvider);
                                    controller.text = fiatInDenominationFormatted(sendingBalance);
                                    ref.read(sendTxProvider.notifier).updateAmountFromInput(
                                        controller.text, btcFormat);
                                  }
                                } catch (e) {
                                  showMessageSnackBar(
                                    message: e.toString().i18n(ref),
                                    error: true,
                                    context: context,
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
                        Slider(
                          value: 16 - ref.watch(sendBlocksProvider).toDouble(),
                          onChanged: (value) => ref.read(sendBlocksProvider.notifier).state = 16 - value,
                          min: 1,
                          max: 15,
                          divisions: 14,
                          label: ref.watch(sendBlocksProvider).toInt().toString(),
                          activeColor: Colors.orange,
                        ),
                        SizedBox(height: dynamicSizedBox),
                        ref.watch(liquidFeeProvider).when(
                          data: (int fee) {
                            return Text(
                              '${'Fee:'.i18n(ref)} $fee${' sats'}',
                              style: TextStyle(
                                  fontSize: dynamicFontSize / 1.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
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
                                  style: TextStyle(color: Colors.white, fontSize: dynamicFontSize / 1.5))),
                        ),
                        SizedBox(height: dynamicSizedBox),
                        ref.watch(liquidFeeValueInCurrencyProvider).when(
                          data: (double feeValue) {
                            return Text(
                              '${feeValue.toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                              style: TextStyle(
                                  fontSize: dynamicFontSize / 1.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            );
                          },
                          loading: () => LoadingAnimationWidget.progressiveDots(
                              size: dynamicFontSize / 1.5, color: Colors.black),
                          error: (error, stack) => Text('',
                              style: TextStyle(color: Colors.black, fontSize: dynamicFontSize / 1.5)),
                        ),
                      ],
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
                          final tx = await ref.watch(sendLiquidTransactionProvider.future);
                          await ref.read(liquidSyncNotifierProvider.notifier).performSync();
                          showFullscreenTransactionSendModal(
                            context: context,
                            asset: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).name,
                            amount: btcInDenominationFormatted(ref.watch(sendTxProvider).amount, btcFormat),
                            fiat: AssetMapper.mapAsset(ref.watch(sendTxProvider).assetId).isFiat,
                            fiatAmount: ref.watch(sendTxProvider).amount.toString(),
                            txid: tx,
                            isLiquid: true,
                          );
                          ref.read(sendTxProvider.notifier).resetToDefault();
                          ref.read(sendBlocksProvider.notifier).state = 1;
                          context.replace('/home');
                        } catch (e) {
                          controller.failure();
                          showMessageSnackBar(
                            message: e.toString().i18n(ref),
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
                      child: Text('Slide to send'.i18n(ref),
                          style: const TextStyle(color: Colors.white)),
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
