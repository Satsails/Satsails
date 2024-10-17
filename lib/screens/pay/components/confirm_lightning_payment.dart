import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/screens/pay/components/lightning_cards.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final totalAmountProvider = FutureProvider.autoDispose.family<double, bool>((ref, sendLiquid) async {
  final fees = await ref.watch(boltzSubmarineFeesProvider.future);
  final sendTxState = ref.read(sendTxProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final sendAmount = sendTxState.btcBalanceInDenominationFormatted(btcFormat);
  double amountInSats = btcFormat == 'sats' ? sendAmount : (sendAmount * 100000000);

  if (sendLiquid) {
    double percentageFee = fees.lbtcFees.percentage / 100 * amountInSats;
    return amountInSats + percentageFee + fees.lbtcFees.minerFees;
  } else {
    double percentageFee = fees.btcFees.percentage / 100 * amountInSats;
    return amountInSats + percentageFee + fees.btcFees.minerFees;
  }
});

class ConfirmLightningPayment extends HookConsumerWidget {
  ConfirmLightningPayment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;
    final sendTxState = ref.read(sendTxProvider);
    final balance = ref.read(balanceNotifierProvider);
    final liquidFormat = ref.watch(settingsProvider).btcFormat;
    final liquidBalanceInFormat = ref.read(liquidBalanceInFormatProvider(liquidFormat));
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicMargin = MediaQuery.of(context).size.width * 0.04;
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final sendAmount = ref.read(sendTxProvider).btcBalanceInDenominationFormatted(btcFormat);
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormat));
    final fees = ref.watch(boltzSubmarineFeesProvider);
    final addressState = useState(sendTxState.address);
    final sendLiquid = ref.watch(sendLiquidProvider);
    final totalAmountAsyncValue = ref.watch(totalAmountProvider(sendLiquid));

    final isProcessing = useState(false);

    return PopScope(
      onPopInvoked: (pop) async {
        if (isProcessing.value) {
          Fluttertoast.showToast(
            msg: "Transaction in progress, please wait.".i18n(ref),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        } else {
          ref.read(sendTxProvider.notifier).resetToDefault();
          ref.read(sendBlocksProvider.notifier).state = 1;
          context.replace('/home');
        }
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
                context.pop();
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
                        balance: balance,
                        liquidFormart: liquidFormat,
                        btcFormart: btcFormat,
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
                      Text(
                        '$sendAmount',
                        style: TextStyle(fontSize: dynamicFontSize * 3, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      totalAmountAsyncValue.when(
                        data: (totalAmountToSendValue) {
                          final totalFeesValue = fees.when(
                            data: (feeData) {
                              double percentageFee = sendLiquid ?
                              feeData.lbtcFees.percentage / 100 * sendAmount :
                              feeData.btcFees.percentage / 100 * sendAmount;
                              return btcInDenominationFormatted(
                                percentageFee + (sendLiquid ? feeData.lbtcFees.minerFees : feeData.btcFees.minerFees),
                                btcFormat,
                              );
                            },
                            loading: () => 'Loading...',
                            error: (error, stack) => 'Error',
                          );

                          final minAmount = fees.when(
                            data: (feeData) => btcInDenominationFormatted(
                              double.parse(
                                sendLiquid ? feeData.lbtcLimits.minimal.toString() : feeData.btcLimits.minimal.toString(),
                              ),
                              btcFormat,
                            ),
                            loading: () => 'Loading...',
                            error: (error, stack) => 'Error',
                          );

                          String formattedTotalAmountToSend = btcInDenominationFormatted(totalAmountToSendValue, btcFormat);

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '${'Total fees'.i18n(ref)}: $totalFeesValue $btcFormat',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '${'Total amount to send'.i18n(ref)}: $formattedTotalAmountToSend $btcFormat',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  '${'Minimum amount:'.i18n(ref)} $minAmount $btcFormat',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => LoadingAnimationWidget.threeRotatingDots(color: Colors.grey, size: 20),
                        error: (error, stack) => Text(
                          'Error: $error',
                          style: TextStyle(
                            fontSize: dynamicFontSize / 1.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                      isProcessing.value = true;
                      controller.loading();
                      try {
                        if (sendAmount <= 0) {
                          throw 'Please enter an amount to pay'.i18n(ref);
                        }
                        if (sendLiquid) {
                          await ref.read(boltzPayProvider.future);
                          await ref.read(liquidSyncNotifierProvider.notifier).performSync();
                        } else {
                          await ref.read(bitcoinBoltzPayProvider.future);
                          await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
                        }
                        Fluttertoast.showToast(
                          msg: "Transaction Sent".i18n(ref),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
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
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        controller.reset();
                      } finally {
                        isProcessing.value = false;
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
