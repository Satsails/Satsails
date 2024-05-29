import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import '../../../providers/balance_provider.dart';
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
    final sendTxState = ref.watch(sendTxProvider);
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

    useEffect(() {
      controller.text = sendAmount == 0 ? '' : sendAmount.toString();
      return null;
    }, []);

    return PopScope(
      onPopInvoked:(pop) async {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(sendBlocksProvider.notifier).state = 1;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Confirm lightning payment'.i18n(ref), style: const TextStyle(color: Colors.black, fontSize: 17)),
        ),
        body:SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: dynamicCardHeight,
                  child:SizedBox(
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      margin: EdgeInsets.all(dynamicMargin),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.deepPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: dynamicPadding, horizontal: dynamicPadding / 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Instant Bitcoin'.i18n(ref), style: const TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                              initializeBalance.when(
                                  data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text('$liquidBalanceInFormat $liquidFormart', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                                  loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                                  error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Text(
                          sendTxState.address,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                      readOnly: controller.text.isNotEmpty,
                      keyboardType: TextInputType.number,
                      inputFormatters: [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()],
                      style: TextStyle(fontSize: dynamicFontSize * 3),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: showBitcoinRelatedWidgets.state ? '0' : '0.00',
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
                  '~ ${ref.watch(bitcoinValueInCurrencyProvider).toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                  style: TextStyle(
                    fontSize: dynamicFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: dynamicSizedBox),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: ActionSlider.standard(
                        sliderBehavior: SliderBehavior.stretch,
                        width: double.infinity,
                        backgroundColor: Colors.white,
                        toggleColor: Colors.blueAccent,
                        action: (controller) async {
                          controller.loading();
                          await Future.delayed(const Duration(seconds: 3));
                          try {
                            await ref.read(boltzPayProvider.future);
                            controller.success();
                            Fluttertoast.showToast(msg: "Transaction Sent".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                            await Future.delayed(const Duration(seconds: 3));
                            ref.read(sendTxProvider.notifier).resetToDefault();
                            ref.read(backgroundSyncNotifierProvider).performSync();
                            Navigator.pushNamed(context, '/home');
                          } catch (e) {
                            controller.failure();
                            Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                            controller.reset();
                          }
                        },
                        child: Text('Slide to send'.i18n(ref)),
                      ),
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

