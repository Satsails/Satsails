import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
class LightningWidget extends ConsumerStatefulWidget {
  final String selectedCurrency;

  const LightningWidget({Key? key, this.selectedCurrency = 'Liquid'}) : super(key: key);

  @override
  _LightningWidgetState createState() => _LightningWidgetState();
}

class _LightningWidgetState extends ConsumerState<LightningWidget> {
  late String selectedCurrency;

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                'Receive in'.i18n(ref),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF2B2B2B),
                value: selectedCurrency,
                items: <String>['Liquid', 'Bitcoin'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                      child: Text(
                        value,
                        style: const TextStyle(color: Color(0xFFD98100)),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    ref.read(inputAmountProvider.notifier).state = '0.0';
                    selectedCurrency = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (selectedCurrency == 'Liquid')
          LiquidReceiveWidget()
        else
          BitcoinReceiveWidget(),
      ],
    );
  }
}


class LiquidReceiveWidget extends ConsumerStatefulWidget {
  const LiquidReceiveWidget({Key? key}) : super(key: key);

  @override
  _LiquidReceiveWidgetState createState() => _LiquidReceiveWidgetState();
}

class _LiquidReceiveWidgetState extends ConsumerState<LiquidReceiveWidget> {
  late TextEditingController controller;
  String transactionId = '';
  bool showInvoice = false;
  Future<BtcBoltz>? _boltzSwapFuture;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    // Optionally initialize the controller with existing amount
    final inputAmount = ref.read(inputAmountProvider);
    if (inputAmount != '0.0') {
      controller.text = inputAmount;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onCreateInvoice() {
    String inputValue = controller.text;
    ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;

    setState(() {
      showInvoice = true;
    });
  }

  Future<void> checkTransactionStatus() async {
    try {
      final data = await ref.read(claimSingleBoltzTransactionProvider(transactionId).future);
      if (data) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              contentPadding: const EdgeInsets.all(16.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 50.0),
                  const SizedBox(height: 16.0),
                  Text(
                    "Transaction Received".i18n(ref),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Your balance will update soon".i18n(ref),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK", style: TextStyle(color: Colors.green)),
                  onPressed: () {
                    ref.read(inputAmountProvider.notifier).state = '0.0';
                    ref.read(inputCurrencyProvider.notifier).state = 'BTC';
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      await Fluttertoast.showToast(
        msg: "Waiting for transaction...".i18n(ref),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final fees = ref.watch(boltzReverseFeesProvider);

    return Column(
      children: [
        AmountInput(controller: controller),
        CustomElevatedButton(
          onPressed: _onCreateInvoice,
          text: 'Create Address'.i18n(ref),
          controller: controller,
        ),
        SizedBox(height: height * 0.02),
        fees.when(
          data: (data) {
            final inputCurrency = ref.watch(inputCurrencyProvider);
            final currencyRate = ref.read(selectedCurrencyProvider(inputCurrency));
            final formattedValueInBtc = btcInDenominationFormatted(data.lbtcLimits.minimal.toDouble(), 'BTC');
            final valueToDisplay = currencyRate * double.parse(formattedValueInBtc);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Minimum amount:'.i18n(ref) + ' ' + (
                    inputCurrency == 'BTC'
                        ? formattedValueInBtc
                        : inputCurrency == 'Sats'
                        ? data.lbtcLimits.minimal.toString()
                        : valueToDisplay.toStringAsFixed(2)
                ),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          },
          loading: () => Center(
            child: LoadingAnimationWidget.threeRotatingDots(color: Colors.grey, size: 20),
          ),
          error: (error, stack) => Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              alignment: Alignment.center,
              child: Text(
                'Unable to get minimum amount'.i18n(ref),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (showInvoice)
          Consumer(
            builder: (context, ref, child) {
              final boltzReceiveAsyncValue = ref.watch(boltzReceiveProvider);

              return boltzReceiveAsyncValue.when(
                data: (data) {
                  transactionId = data.swap.id;
                  return Column(
                    children: [
                      buildQrCode(data.swap.invoice, context),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildAddressText(
                          data.swap.invoice,
                          context,
                          ref,
                          MediaQuery.of(context).size.height * 0.02 / 1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: CustomElevatedButton(
                          onPressed: checkTransactionStatus,
                          text: 'Claim transaction'.i18n(ref),
                          controller: controller,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: LoadingAnimationWidget.threeArchedCircle(
                    size: MediaQuery.of(context).size.width * 0.6,
                    color: Colors.orange,
                  ),
                ),
                error: (error, stack) => Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    alignment: Alignment.center,
                    child: Text(
                      '$error'.i18n(ref),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class BitcoinReceiveWidget extends ConsumerStatefulWidget {
  const BitcoinReceiveWidget({super.key});

  @override
  _BitcoinReceiveWidgetState createState() => _BitcoinReceiveWidgetState();
}

class _BitcoinReceiveWidgetState extends ConsumerState<BitcoinReceiveWidget> {
  late TextEditingController controller;
  String transactionId = '';
  bool showInvoice = false;
  Future<BtcBoltz>? _boltzSwapFuture;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    // Optionally initialize the controller with existing amount
    final inputAmount = ref.read(inputAmountProvider);
    if (inputAmount != '0.0') {
      controller.text = inputAmount;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onCreateInvoice() async {
    String inputValue = controller.text;
    ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;

    setState(() {
      showInvoice = true;
      _boltzSwapFuture = ref.read(bitcoinBoltzReceiveProvider.future);
    });
  }

  Future<void> checkTransactionStatus() async {
    try {
      final data = await ref.read(claimSingleBitcoinBoltzTransactionProvider(transactionId).future);
      if (data) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              contentPadding: const EdgeInsets.all(16.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 50.0),
                  const SizedBox(height: 16.0),
                  Text(
                    "Transaction Received".i18n(ref),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Your balance will update soon".i18n(ref),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK", style: TextStyle(color: Colors.green)),
                  onPressed: () {
                    ref.read(inputAmountProvider.notifier).state = '0.0';
                    ref.read(inputCurrencyProvider.notifier).state = 'BTC';
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      await Fluttertoast.showToast(
        msg: "Waiting for transaction...".i18n(ref),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fees = ref.watch(boltzReverseFeesProvider);
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        AmountInput(controller: controller),
        CustomElevatedButton(
          onPressed: _onCreateInvoice,
          text: 'Create Address'.i18n(ref),
          controller: controller,
        ),
        SizedBox(height: height * 0.02),
        fees.when(
          data: (data) {
            final inputCurrency = ref.watch(inputCurrencyProvider);
            final currencyRate = ref.read(selectedCurrencyProvider(inputCurrency));
            final formattedValueInBtc = btcInDenominationFormatted(data.btcLimits.minimal.toDouble(), 'BTC');
            final valueToDisplay = currencyRate * double.parse(formattedValueInBtc);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Minimum amount:'.i18n(ref) + ' ' + (
                    inputCurrency == 'BTC'
                        ? formattedValueInBtc
                        : inputCurrency == 'Sats'
                        ? data.btcLimits.minimal.toString()
                        : valueToDisplay.toStringAsFixed(2)
                ),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          },
          loading: () => Center(
            child: LoadingAnimationWidget.threeRotatingDots(color: Colors.grey, size: 20),
          ),
          error: (error, stack) => Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              alignment: Alignment.center,
              child: Text(
                'Unable to get minimum amount'.i18n(ref),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (showInvoice)
          FutureBuilder<BtcBoltz>(
            future: _boltzSwapFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: LoadingAnimationWidget.threeArchedCircle(
                    size: MediaQuery.of(context).size.width * 0.6,
                    color: Colors.orange,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    alignment: Alignment.center,
                    child: Text(
                      '${snapshot.error}'.i18n(ref),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                final data = snapshot.data!;
                transactionId = data.swap.id;
                return Column(
                  children: [
                    buildQrCode(data.swap.invoice, context),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildAddressText(
                        data.swap.invoice,
                        context,
                        ref,
                        MediaQuery.of(context).size.height * 0.02 / 1.5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomElevatedButton(
                        onPressed: checkTransactionStatus,
                        text: 'Claim transaction'.i18n(ref),
                        controller: controller,
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
      ],
    );
  }
}


