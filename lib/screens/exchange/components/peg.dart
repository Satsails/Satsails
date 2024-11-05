import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:action_slider/action_slider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';

final bitcoinReceiveSpeedProvider = StateProvider.autoDispose<String>((ref) => 'Fastest');
final inputInFiatProvider = StateProvider.autoDispose<bool>((ref) => false);
final precisionFiatValueProvider = StateProvider<String>((ref) => "0.00");

class Peg extends ConsumerStatefulWidget {
  const Peg({super.key});

  @override
  _PegState createState() => _PegState();
}

class _PegState extends ConsumerState<Peg> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;
    final pegIn = ref.watch(pegInProvider);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormart));
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(btcFormart));
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;

    List<Widget> cards = [
      _buildBitcoinCard(ref, dynamicPadding, titleFontSize, pegIn),
      SizedBox(height: dynamicSizedBox),
      _buildLiquidCard(ref, dynamicPadding, titleFontSize, pegIn),
    ];

    if (!pegIn) {
      cards = cards.reversed.toList();
    }

    return SafeArea(
      child: FlutterKeyboardDoneWidget(
        doneWidgetBuilder: (context) {
          return const Text(
            'Done',
          );
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Balance to Spend: ".i18n(ref),
                      style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          pegIn ? '$btcBalanceInFormat $btcFormart' : '$liquidBalanceInFormat $btcFormart',
                          style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        _buildBitcoinMaxButton(ref, dynamicPadding, titleFontSize, btcFormart, pegIn),
                      ],
                    ),
                    SizedBox(height: dynamicSizedBox * 2),
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          children: cards,
                        ),
                        Positioned(
                          top: titleFontSize / 2,
                          bottom: titleFontSize / 2,
                          child: GestureDetector(
                            onTap: () {
                              ref.read(pegInProvider.notifier).state = !pegIn;
                              ref.read(sendTxProvider.notifier).updateAddress('');
                              ref.read(sendTxProvider.notifier).updateAmount(0);
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                              ref.read(inputInFiatProvider.notifier).state = false;ref.read(sendBlocksProvider.notifier).state = 1;
                              ref.read(inputInFiatProvider.notifier).state = false;
                              ref.read(precisionFiatValueProvider.notifier).state = "0.00";controller.text = '';
                            },
                            child: CircleAvatar(
                              radius: titleFontSize,
                              backgroundColor: Colors.orange,
                              child: Icon(EvaIcons.swap, size: titleFontSize, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    pegIn ? _bitcoinFeeSlider(ref, dynamicPadding, titleFontSize) : _bitcoinFeeSuggestionsModal(ref, dynamicPadding, titleFontSize),
                    pegIn ? _buildBitcoinFeeInfo(ref, dynamicPadding, titleFontSize) : _buildLiquidFeeInfo(ref, dynamicPadding, titleFontSize),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: dynamicSizedBox * 2),
              child: pegIn
                  ? _bitcoinSlideToSend(ref, dynamicPadding, titleFontSize, context)
                  : _liquidSlideToSend(ref, dynamicPadding, titleFontSize, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBitcoinMaxButton(WidgetRef ref, double dynamicPadding, double dynamicFontSize, String btcFormart, bool pegIn) {
    final sideSwapPeg = ref.watch(sideswapPegProvider);

    return sideSwapPeg.maybeWhen(
      data: (peg) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                try {
                  ref.read(inputInFiatProvider.notifier).state = false;
                  ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                  if(pegIn){
                    final bitcoin = ref.watch(balanceNotifierProvider).btcBalance;
                    final transactionBuilderParams = await ref.watch(bitcoinTransactionBuilderProvider(ref.watch(sendTxProvider).amount).future).then((value) => value);
                    final transaction = await ref.watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilderParams).future).then((value) => value);
                    final fee = await transaction.$1.feeAmount().then((value) => value);
                    final amountToSet = (bitcoin - fee!);
                    ref.read(sendTxProvider.notifier).updateAmountFromInput(amountToSet.toString(), 'sats');
                    ref.read(sendTxProvider.notifier).updateDrain(true);
                    controller.text = btcInDenominationFormatted(amountToSet.toDouble(), btcFormart);
                  } else {
                    final liquid = ref.watch(balanceNotifierProvider).liquidBalance;
                    controller.text = btcInDenominationFormatted(liquid.toDouble(), btcFormart);
                    ref.read(sendTxProvider.notifier).updateDrain(true);
                    ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormart);
                  }
                } catch (e) {
                  Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: dynamicPadding / 1, vertical: dynamicPadding / 2.5),
                child: Text(
                  'Max',
                  style: TextStyle(
                    fontSize: dynamicFontSize / 2,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.all(dynamicPadding / 2),
        child: LoadingAnimationWidget.progressiveDots(size:  dynamicFontSize / 2, color: Colors.white),
      ),
      error: (error, stack) => Padding(
          padding: EdgeInsets.all(dynamicPadding / 2),
          child:  Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  dynamicFontSize / 2))
      ),
      orElse: () => Container(), // Add a default case to ensure a Widget is always returned
    );
  }


  Widget _liquidSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
    final status = ref.watch(sideswapStatusProvider);
    final pegStatus = ref.watch(sideswapPegStatusProvider);

    return pegStatus.when(
      data: (peg) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ActionSlider.standard(
              sliderBehavior: SliderBehavior.stretch,
              width: double.infinity,
              backgroundColor: Colors.black,
              toggleColor: Colors.orange,
              action: (controller) async {
                ref.read(transactionInProgressProvider.notifier).state = true;
                controller.loading();
                try {
                  if (ref.watch(sendTxProvider).amount < status.minPegOutAmount) {
                    ref.read(transactionInProgressProvider.notifier).state = false;
                    throw 'Amount is below minimum peg out amount'.i18n(ref);
                  }
                  await ref.watch(sendLiquidTransactionProvider.future);
                  await ref.read(sideswapHiveStorageProvider(peg.orderId!).future);
                  ref.read(sendTxProvider.notifier).updateAddress('');
                  ref.read(sendTxProvider.notifier).updateAmount(0);
                  ref.read(sendBlocksProvider.notifier).state = 1;
                  Fluttertoast.showToast(msg: "Swap done!".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                  Future.microtask(() {
                    ref.read(selectedExpenseTypeProvider.notifier).state = "Swaps";
                    ref.read(navigationProvider.notifier).state = 1;
                  });
                  await ref.read(liquidSyncNotifierProvider.notifier).performSync();
                  controller.success();
                  ref.read(transactionInProgressProvider.notifier).state = false;
                  context.go('/home');
                } catch (e) {
                  controller.failure();
                  ref.read(transactionInProgressProvider.notifier).state = false;
                  Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                  controller.reset();
                }
              },
              child:Text('Slide to Swap'.i18n(ref), style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)
          ),
        );
      },
      loading: () => Center(child: LoadingAnimationWidget.progressiveDots(size:  titleFontSize * 2, color: Colors.white)),
      error: (error, stack) => Text(ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize)),
    );
  }


  Widget _bitcoinSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
    final pegStatus = ref.watch(sideswapPegStatusProvider);

    return pegStatus.when(
      data: (peg) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ActionSlider.standard(
              sliderBehavior: SliderBehavior.stretch,
              width: double.infinity,
              backgroundColor: Colors.black,
              toggleColor: Colors.orange,
              action: (controller) async {
                ref.read(transactionInProgressProvider.notifier).state = true;
                controller.loading();
                try {
                  if (ref.watch(sendTxProvider).amount < ref.watch(sideswapStatusProvider).minPegInAmount) {
                    ref.read(transactionInProgressProvider.notifier).state = false;
                    throw 'Amount is below minimum peg in amount'.i18n(ref);
                  }
                  await ref.watch(sendBitcoinTransactionProvider.future);
                  await ref.read(sideswapHiveStorageProvider(peg.orderId!).future);
                  ref.read(sendTxProvider.notifier).updateAddress('');
                  ref.read(sendTxProvider.notifier).updateAmount(0);
                  ref.read(sendBlocksProvider.notifier).state = 1;
                  Fluttertoast.showToast(msg: "Swap done!".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                  Future.microtask(() {
                    ref.read(selectedExpenseTypeProvider.notifier).state = "Swaps";
                    ref.read(navigationProvider.notifier).state = 1;
                  });
                  await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
                  controller.success();
                  ref.read(transactionInProgressProvider.notifier).state = false;
                  context.go('/home');
                } catch (e) {
                  ref.read(transactionInProgressProvider.notifier).state = false;
                  controller.failure();
                  Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                  controller.reset();
                }
              },
              child: Text('Slide to Swap'.i18n(ref), style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.all(dynamicPadding / 2),
        child: Center(child: LoadingAnimationWidget.progressiveDots(size:  titleFontSize * 2, color: Colors.white)),
      ),
      error: (error, stack) => Padding(
          padding: EdgeInsets.all(dynamicPadding / 2),
          child: Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize / 2))
      ),
    );
  }

  Widget _bitcoinFeeSuggestionsModal(WidgetRef ref, double dynamicPadding, double titleFontSize) {
    final networkFee = ref.watch(pegOutBitcoinCostProvider).toStringAsFixed(0);

    return Column(
      children: [
        _liquidFeeSlider(ref, dynamicPadding, titleFontSize),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: dynamicPadding / 2),
            Text(
              '${'Receiving Bitcoin fee:'.i18n(ref)} $networkFee sats',
              style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: SingleChildScrollView(
                        child: AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(dynamicPadding),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "!",
                                    style: TextStyle(fontSize: titleFontSize, color: Colors.black),
                                  )
                              ),
                              SizedBox(height: dynamicPadding / 2),
                              _pickBitcoinFeeSuggestions(ref, dynamicPadding, titleFontSize),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                  padding: EdgeInsets.all(dynamicPadding / 2.3),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "!",
                    style: TextStyle(fontSize: titleFontSize / 1.8, color: Colors.black),
                  )
              ),
            ),
            SizedBox(height: dynamicPadding / 2),
          ],
        ),
      ],
    );
  }

  Widget _pickBitcoinFeeSuggestions(WidgetRef ref, double dynamicPadding, double titleFontSize) {
    final status = ref.watch(sideswapStatusProvider).bitcoinFeeRates ?? [];
    final selectedBlocks = ref.watch(pegOutBlocksProvider);

    return DropdownButton<dynamic>(
      hint: Text(
        "How fast would you like to receive your bitcoin".i18n(ref),
        style: TextStyle(fontSize: titleFontSize / 2.3, color: Colors.grey),
      ),
      dropdownColor: selectedBlocks == 12 ? const Color(0xFF1A1A1A) : const Color(0xFF2B2B2B),
      items: status.map((dynamic value) {
        return DropdownMenuItem<dynamic>(
          value: value,
          child: Center(
            child: Text(
              "${value["blocks"]} blocks - ${value["value"]} sats/vbyte",
              style: TextStyle(
                fontSize: titleFontSize / 2,
                color: selectedBlocks == value["blocks"]
                    ? const Color(0xFFFF9800)
                    : const Color(0xFFD98100),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (dynamic newValue) {
        if (newValue != null) {
          ref.read(bitcoinReceiveSpeedProvider.notifier).state = "${newValue["value"]} sats/vbyte";
          ref.read(pegOutBlocksProvider.notifier).state = newValue["blocks"];
        }
      },
    );
  }


  Widget _bitcoinFeeSlider(WidgetRef ref, double dynamicPadding, double titleFontSize) {
    return Column(
      children: [
        SizedBox(height: dynamicPadding / 2),
        Text("Choose your fee:".i18n(ref), style: TextStyle(fontSize:  titleFontSize / 2, color: Colors.white)),
        Slider(
          value: 6 - ref.watch(sendBlocksProvider).toDouble(),
          onChanged: (value) => ref.read(sendBlocksProvider.notifier).state = 6 - value,
          min: 1,
          max: 5,
          divisions: 4,
          label: ref.watch(sendBlocksProvider).toInt().toString(),
          activeColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _liquidFeeSlider(WidgetRef ref, double dynamicPadding, double titleFontSize) {
    return Column(
      children: [
        SizedBox(height: dynamicPadding / 2),
        Text("Choose your fee:".i18n(ref), style: TextStyle(fontSize:  titleFontSize / 2, color: Colors.white)),
        Slider(
          value: 16 - ref.watch(sendBlocksProvider).toDouble(),
          onChanged: (value) => ref.read(sendBlocksProvider.notifier).state = 16 - value,
          min: 1,
          max: 15,
          divisions: 14,
          label: ref.watch(sendBlocksProvider).toInt().toString(),
          activeColor: Colors.orange,
        )
      ],
    );
  }

  Widget _buildBitcoinFeeInfo (WidgetRef ref, double dynamicPadding, double titleFontSize) {
    return Column(
        children: [
          ref.watch(feeProvider).when(
            data: (int fee) {
              return Text(
                "${'Sending Transaction fee:'.i18n(ref)}$fee sats",
                style: TextStyle(fontSize:  titleFontSize / 2, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              );
            },
            loading: () => LoadingAnimationWidget.progressiveDots(size:  titleFontSize / 2, color: Colors.white),
            error: (error, stack) => TextButton(
                onPressed: () { ref.refresh(feeProvider); },
                child: Text(ref.watch(sendTxProvider).amount == 0 ? 'Enter a value to send'.i18n(ref) : error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize / 2))
            ),
          ),
        ]
    );
  }

  Widget _buildLiquidFeeInfo (WidgetRef ref, double dynamicPadding, double titleFontSize) {
    return Column(
        children: [
          ref.watch(liquidFeeProvider).when(
            data: (int fee) {
              return Text(
                "${'Sending Transaction fee:'.i18n(ref)}$fee sats",
                style: TextStyle(fontSize:  titleFontSize / 2, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              );
            },
            loading: () => LoadingAnimationWidget.progressiveDots(size:  titleFontSize / 2, color: Colors.white),
            error: (error, stack) => TextButton(
                onPressed: () { ref.refresh(liquidFeeProvider); },
                child: Text(ref.watch(sendTxProvider).amount == 0 ? 'Enter a value to send'.i18n(ref) : error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize / 2))
            ),
          ),
        ]
    );

  }

  Widget _buildBitcoinCard(WidgetRef ref, double dynamicPadding, double titleFontSize, bool pegIn) {
    final sideSwapStatus = ref.watch(sideswapStatusProvider);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final currency = ref.read(settingsProvider).currency;
    final currencyRate = ref.read(selectedCurrencyProvider(currency));
    final valueToReceive = ref.watch(sendTxProvider).amount * (1 - sideSwapStatus.serverFeePercentPegIn / 100) - ref.watch(pegOutBitcoinCostProvider);
    final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
    final valueInCurrency = double.parse(formattedValueInBtc) * currencyRate;
    final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormart);
    final sideSwapPeg = ref.watch(sideswapPegProvider);
    final status = ref.watch(sideswapStatusProvider);
    final valueToSendInCurrency = ref.watch(sendTxProvider).amount / 100000000 * currencyRate;

    return Container(
      width: MediaQuery.of(ref.context).size.width * 0.7,
      height: MediaQuery.of(ref.context).size.height * 0.2,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Bitcoin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          if (!pegIn)
            Column(
              children: [
                if (double.parse(formattedValueToReceive) <= 0)
                  Text("0", style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)
                else
                  Column(
                    children: [
                      Text(formattedValueToReceive, style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center),
                      Text('${valueInCurrency.toStringAsFixed(2)} $currency', style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white), textAlign: TextAlign.center),
                      SizedBox(height: dynamicPadding / 2),
                      Text(
                        '${'Minimum amount:'.i18n(ref)} ${btcInDenominationFormatted(pegIn ? status.minPegInAmount.toDouble() : status.minPegOutAmount.toDouble(), btcFormart)} $btcFormart',
                        style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            )
          else
            sideSwapPeg.when(
              data: (peg) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!ref.watch(inputInFiatProvider))
                          IntrinsicWidth(
                            child: TextFormField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              controller: controller,
                              inputFormatters: [
                                CommaTextInputFormatter(),
                                btcFormart == 'sats'
                                    ? DecimalTextInputFormatter(decimalRange: 0)
                                    : DecimalTextInputFormatter(decimalRange: 8),
                              ],
                              style: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize),
                              ),
                              onChanged: (value) async {
                                if (value.isEmpty) {
                                  ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                                  ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                                  ref.read(sendTxProvider.notifier).updateDrain(false);
                                }
                                ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
                                ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                                ref.read(sendTxProvider.notifier).updateDrain(false);
                              },
                            ),
                          ),
                        if (ref.watch(inputInFiatProvider))
                          IntrinsicWidth(
                            child: TextFormField(
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              controller: controller,
                              inputFormatters: [
                                CommaTextInputFormatter(),
                                DecimalTextInputFormatter(decimalRange: 2),
                              ],
                              style: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize),
                              ),
                              onChanged: (value) async {
                                if (value.isEmpty) {
                                  ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                                  ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                                  ref.read(sendTxProvider.notifier).updateDrain(false);
                                }
                                String send = btcFormart == 'sats'
                                    ? calculateAmountToDisplayFromFiatInSats(controller.text, currency, ref.watch(currencyNotifierProvider))
                                    : calculateAmountToDisplayFromFiat(controller.text, currency, ref.watch(currencyNotifierProvider));

                                ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormart);
                                ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                                ref.read(sendTxProvider.notifier).updateDrain(false);
                              },
                            ),
                          ),
                        SizedBox(width: 8),
                        if (!ref.watch(inputInFiatProvider))
                          Text(
                            btcFormart == 'sats' ? 'Sats' : 'BTC',
                            style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 2),
                          ),
                        if (ref.watch(inputInFiatProvider))
                          Text(
                            currency,
                            style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 2),
                          ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        bool currentIsFiat = ref.read(inputInFiatProvider);
                        if (currentIsFiat) {
                          String btcValue = btcFormart == 'sats'
                              ? calculateAmountToDisplayFromFiatInSats(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider))
                              : calculateAmountToDisplayFromFiat(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider));

                          controller.text = btcFormart == 'sats' ? btcInDenominationFormatted(double.parse(btcValue), btcFormart) : btcValue;
                        } else {
                          String fiatValue = calculateAmountInSelectedCurrency(ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                          ref.read(precisionFiatValueProvider.notifier).state = fiatValue;
                          controller.text = double.parse(fiatValue) < 0.01 ? '' : double.parse(fiatValue).toStringAsFixed(2);
                        }
                        ref.read(inputInFiatProvider.notifier).state = !currentIsFiat;
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward, size: titleFontSize / 1.5, color: Colors.white),
                          Icon(Icons.arrow_upward, size: titleFontSize / 1.5, color: Colors.white),
                        ],
                      ),
                    ),
                    SizedBox(height: dynamicPadding / 2),
                    if (!ref.watch(inputInFiatProvider))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "About ".i18n(ref),
                            style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 2),
                          ),
                          Text(
                            '${valueToSendInCurrency.toStringAsFixed(0)} $currency',
                            style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    if (ref.watch(inputInFiatProvider))
                      Text(
                        '${btcInDenominationFormatted(ref.watch(sendTxProvider).amount.toDouble(), btcFormart)} $btcFormart',
                        style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                  ],
                );
              },
              loading: () => Center(child: LoadingAnimationWidget.progressiveDots(size: titleFontSize, color: Colors.white)),
              error: (error, stack) => Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize: titleFontSize / 2)),
            ),
        ],
      ),
    );
  }


  Widget _buildLiquidCard(WidgetRef ref, double dynamicPadding, double titleFontSize, bool pegIn) {
    final sideSwapStatus = ref.watch(sideswapStatusProvider);
    final valueToReceive = ref.watch(sendTxProvider).amount * (1 - sideSwapStatus.serverFeePercentPegOut / 100);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final currency = ref.read(settingsProvider).currency;
    final currencyRate = ref.read(selectedCurrencyProvider(currency));
    final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormart);
    final sideSwapPeg = ref.watch(sideswapPegProvider);
    final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
    final valueInCurrency = double.parse(formattedValueInBtc) * currencyRate;
    final status = ref.watch(sideswapStatusProvider);
    final valueToSendInCurrency = ref.watch(sendTxProvider).amount / 100000000 * currencyRate;

    return Container(
      width: MediaQuery.of(ref.context).size.width * 0.7,
      height: MediaQuery.of(ref.context).size.height * 0.2,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Liquid Bitcoin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          if (pegIn)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (double.parse(formattedValueToReceive) <= 0)
                  Text("0", style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)
                else
                  Column(
                    children: [
                      IntrinsicWidth(
                        child: Row(
                          children: [
                            Text(formattedValueToReceive, style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center),
                            SizedBox(width: 8),
                            Text(
                              btcFormart == 'sats' ? 'Sats' : 'BTC',
                              style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 2),
                            ),
                          ],
                        ),
                      ),
                      Text('${valueInCurrency.toStringAsFixed(2)} $currency', style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey), textAlign: TextAlign.center),
                      SizedBox(height: dynamicPadding / 2),
                      Text(
                        '${'Minimum amount:'.i18n(ref)} ${btcInDenominationFormatted(pegIn ? status.minPegInAmount.toDouble() : status.minPegOutAmount.toDouble(), btcFormart)} $btcFormart',
                        style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            )
          else
            sideSwapPeg.when(
              data: (peg) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!ref.watch(inputInFiatProvider))
                          IntrinsicWidth(
                            child: TextFormField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              controller: controller,
                              inputFormatters: [
                                CommaTextInputFormatter(),
                                btcFormart == 'sats'
                                    ? DecimalTextInputFormatter(decimalRange: 0)
                                    : DecimalTextInputFormatter(decimalRange: 8),
                              ],
                              style: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize),
                              ),
                              onChanged: (value) async {
                                if (value.isEmpty) {
                                  ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                                  ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                                  ref.read(sendTxProvider.notifier).updateDrain(false);
                                }
                                ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
                                ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                                ref.read(sendTxProvider.notifier).updateDrain(false);
                              },
                            ),
                          ),
                        if (ref.watch(inputInFiatProvider))
                          IntrinsicWidth(
                            child: TextFormField(
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              controller: controller,
                              inputFormatters: [
                                CommaTextInputFormatter(),
                                DecimalTextInputFormatter(decimalRange: 2),
                              ],
                              style: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize),
                              ),
                              onChanged: (value) async {
                                if (value.isEmpty) {
                                  ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                                  ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                                  ref.read(sendTxProvider.notifier).updateDrain(false);
                                }
                                String send = btcFormart == 'sats'
                                    ? calculateAmountToDisplayFromFiatInSats(controller.text, currency, ref.watch(currencyNotifierProvider))
                                    : calculateAmountToDisplayFromFiat(controller.text, currency, ref.watch(currencyNotifierProvider));

                                ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormart);
                                ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                                ref.read(sendTxProvider.notifier).updateDrain(false);
                              },
                            ),
                          ),
                        SizedBox(width: 8),
                        if (!ref.watch(inputInFiatProvider))
                          Text(
                            btcFormart == 'sats' ? 'Sats' : 'BTC',
                            style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 2),
                          ),
                        if (ref.watch(inputInFiatProvider))
                          Text(
                            currency,
                            style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 2),
                          ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        bool currentIsFiat = ref.read(inputInFiatProvider);
                        if (currentIsFiat) {
                          String btcValue = btcFormart == 'sats'
                              ? calculateAmountToDisplayFromFiatInSats(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider))
                              : calculateAmountToDisplayFromFiat(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider));

                          controller.text = btcFormart == 'sats' ? btcInDenominationFormatted(double.parse(btcValue), btcFormart) : btcValue;
                        } else {
                          String fiatValue = calculateAmountInSelectedCurrency(ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                          ref.read(precisionFiatValueProvider.notifier).state = fiatValue;
                          controller.text = double.parse(fiatValue) < 0.01 ? '' : double.parse(fiatValue).toStringAsFixed(2);
                        }
                        ref.read(inputInFiatProvider.notifier).state = !currentIsFiat;
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_downward, size: titleFontSize / 1.5, color: Colors.white),
                          Icon(Icons.arrow_upward, size: titleFontSize / 1.5, color: Colors.white),
                        ],
                      ),
                    ),
                    SizedBox(height: dynamicPadding / 2),
                    if (!ref.watch(inputInFiatProvider))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "About ".i18n(ref),
                            style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 2),
                          ),
                          Text(
                            '${valueToSendInCurrency.toStringAsFixed(0)} $currency',
                            style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    if (ref.watch(inputInFiatProvider))
                      Text(
                        '${btcInDenominationFormatted(ref.watch(sendTxProvider).amount.toDouble(), btcFormart)} $btcFormart',
                        style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                  ],
                );
              },
              loading: () => Center(child: LoadingAnimationWidget.progressiveDots(size: titleFontSize, color: Colors.white)),
              error: (error, stack) => Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize: titleFontSize / 2)),
            ),
        ],
      ),
    );
  }
}



