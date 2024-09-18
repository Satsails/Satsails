import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/screens/pay/components/lightning_cards.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConfirmLightningPayment extends HookConsumerWidget {
  ConfirmLightningPayment({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;
    final sendTxState = ref.read(sendTxProvider);
    final initializeBalance = ref.watch(initializeBalanceProvider);
    final liquidFormart = ref.watch(settingsProvider).btcFormat;
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(liquidFormart));
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicMargin = MediaQuery.of(context).size.width * 0.04;
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final showBitcoinRelatedWidgets = ref.watch(showBitcoinRelatedWidgetsProvider.notifier);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final sendAmount = ref.watch(sendTxProvider).btcBalanceInDenominationFormatted(btcFormart);
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormart));
    final addressState = useState(sendTxState.address);


    useEffect(() {
      controller.text = sendAmount == 0 ? '' : (btcFormart == 'sats' ? sendAmount.toStringAsFixed(0) : sendAmount.toString());
      return null;
    }, []);

    return PopScope(
      onPopInvoked:(pop) async {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(sendBlocksProvider.notifier).state = 1;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text('Confirm lightning payment'.i18n(ref), style: const TextStyle(color: Colors.white, fontSize: 17)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: dynamicSizedBox),
                      LightningCards(
                        titleFontSize: titleFontSize,
                        initializeBalance: initializeBalance,
                        liquidFormart: liquidFormart,
                        btcFormart: btcFormart,
                        liquidBalanceInFormat: liquidBalanceInFormat,
                        btcBalanceInFormat: btcBalanceInFormat,
                        dynamicPadding: dynamicPadding,
                        dynamicMargin: dynamicMargin,
                        dynamicCardHeight: dynamicCardHeight,
                        ref: ref,
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
                                addressState.value,
                                style: TextStyle(
                                  fontSize: dynamicFontSize / 1.5,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: FocusScope(
                          child: TextFormField(
                            controller: controller,
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)],
                            style: TextStyle(fontSize: dynamicFontSize * 3, color: Colors.white),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: showBitcoinRelatedWidgets.state ? '0' : '0.00',
                              hintStyle: const TextStyle(color: Colors.white),
                            ),
                            onChanged: (value) async {
                              if (value.isEmpty) {
                                ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                              }
                              ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: dynamicSizedBox),
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
                      controller.loading();
                      await Future.delayed(const Duration(seconds: 3));
                      try {
                        final sendLiquid = ref.read(sendLiquidProvider);
                        sendLiquid ? await ref.read(boltzPayProvider.future) : await ref.read(bitcoinBoltzPayProvider.future);
                        controller.success();
                        Fluttertoast.showToast(msg: "Transaction Sent".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                        await Future.delayed(const Duration(seconds: 3));
                        ref.read(sendTxProvider.notifier).resetToDefault();
                        ref.read(backgroundSyncNotifierProvider).performSync();
                        Navigator.pushNamed(context, '/home');
                      } catch (e) {
                        controller.failure();
                        Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                        controller.reset();
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
    );
  }
}