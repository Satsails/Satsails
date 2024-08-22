import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:interactive_slider/interactive_slider.dart';
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
      GestureDetector(
        onTap: () {
          ref.read(pegInProvider.notifier).state = !pegIn;
          ref.read(sendTxProvider.notifier).updateAddress('');
          ref.read(sendTxProvider.notifier).updateAmount(0);
          ref.read(sendBlocksProvider.notifier).state = 1;
          controller.text = '';
        },
        child: CircleAvatar(
          radius: titleFontSize / 1.5,
          backgroundColor: Colors.orange,
          child: Icon(EvaIcons.swap, size: titleFontSize, color: Colors.black),
        ),
      ),
      _buildLiquidCard(ref, dynamicPadding, titleFontSize, pegIn),
    ];

    if (!pegIn) {
      cards = cards.reversed.toList();
    }

    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                //   add here the max depending on pegIn or pegOut
              ],
            ),
            SizedBox(height: dynamicSizedBox * 2),
            ...cards, // Spread operator to insert all elements of the list
            pegIn ? _bitcoinFeeSlider(ref, dynamicPadding, titleFontSize) : _pickBitcoinFeeSuggestions(ref, dynamicPadding, titleFontSize),
            if (!pegIn)
              Text(
                '${'Bitcoin Network fee:'.i18n(ref)} ${ref.watch(pegOutBitcoinCostProvider).toStringAsFixed(0)} sats',
                style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            pegIn ? _buildBitcoinFeeInfo(ref, dynamicPadding, titleFontSize) : _buildLiquidFeeInfo(ref, dynamicPadding, titleFontSize),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: pegIn
              ? _bitcoinSlideToSend(ref, dynamicPadding, titleFontSize, context)
              : _liquidSlideToSend(ref, dynamicPadding, titleFontSize, context),
        )
      ],
    );}

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
        padding: const EdgeInsets.all(8.0),
        child: LoadingAnimationWidget.prograssiveDots(size:  dynamicFontSize / 2, color: Colors.white),
      ),
      error: (error, stack) => Padding(
          padding: const EdgeInsets.all(8.0),
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
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ActionSlider.standard(
                sliderBehavior: SliderBehavior.stretch,
                width: double.infinity,
                backgroundColor: Colors.black,
                toggleColor: Colors.orange,
                action: (controller) async {
                  controller.loading();
                  await Future.delayed(const Duration(seconds: 3));
                  try {
                    if (ref.watch(sendTxProvider).amount < status.minPegOutAmount) {
                      throw 'Amount is below minimum peg out amount'.i18n(ref);
                    }
                    await ref.watch(sendLiquidTransactionProvider.future);
                    await ref.read(sideswapHiveStorageProvider(peg.orderId!).future);
                    controller.success();
                    Fluttertoast.showToast(msg: "Swap done! Check Analytics for more info".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                    ref.read(sendTxProvider.notifier).updateAddress('');
                    ref.read(sendTxProvider.notifier).updateAmount(0);
                    ref.read(sendBlocksProvider.notifier).state = 1;
                    ref.read(backgroundSyncNotifierProvider).performSync();
                    await Future.delayed(const Duration(seconds: 3));
                    Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    controller.failure();
                    Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                    controller.reset();
                  }
                },
                child:Text('Swap'.i18n(ref), style: TextStyle(color: Colors.white), textAlign: TextAlign.center)
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: LoadingAnimationWidget.prograssiveDots(size:  titleFontSize * 2, color: Colors.white)),
      ),
      error: (error, stack) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize))
      ),
    );
  }


  Widget _bitcoinSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
    final pegStatus = ref.watch(sideswapPegStatusProvider);

    return pegStatus.when(
      data: (peg) {
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ActionSlider.standard(
                sliderBehavior: SliderBehavior.stretch,
                width: double.infinity,
                backgroundColor: Colors.black,
                toggleColor: Colors.orange,
                action: (controller) async {
                  controller.loading();
                  await Future.delayed(const Duration(seconds: 3));
                  try {
                    if (ref.watch(sendTxProvider).amount < ref.watch(sideswapStatusProvider).minPegInAmount) {
                      throw 'Amount is below minimum peg in amount'.i18n(ref);
                    }
                    await ref.watch(sendBitcoinTransactionProvider.future);
                    await ref.read(sideswapHiveStorageProvider(peg.orderId!).future);
                    controller.success();
                    Fluttertoast.showToast(msg: "Swap done! Check Analytics for more info".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                    ref.read(sendTxProvider.notifier).updateAddress('');
                    ref.read(sendTxProvider.notifier).updateAmount(0);
                    ref.read(sendBlocksProvider.notifier).state = 1;
                    ref.read(backgroundSyncNotifierProvider).performSync();
                    await Future.delayed(const Duration(seconds: 3));
                    Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    controller.failure();
                    Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                    controller.reset();
                  }
                },
                child: Text('Swap'.i18n(ref), style: TextStyle(color: Colors.white), textAlign: TextAlign.center)
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: LoadingAnimationWidget.prograssiveDots(size:  titleFontSize * 2, color: Colors.white)),
      ),
      error: (error, stack) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize / 2))
      ),
    );
  }

  Widget _pickBitcoinFeeSuggestions(WidgetRef ref, double dynamicPadding, double titleFontSize) {
    final status = ref.watch(sideswapStatusProvider).bitcoinFeeRates ?? [];
    final speed = ref.watch(bitcoinReceiveSpeedProvider).i18n(ref);
    return Column(
      children: [
        _liquidFeeSlider(ref, dynamicPadding, titleFontSize),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(speed, style: TextStyle(fontSize:  titleFontSize / 2, color: Colors.white)),
        ),
        DropdownButton<dynamic>(
          hint: Text("How fast would you like to receive your bitcoin".i18n(ref), style: TextStyle(fontSize:  titleFontSize / 2)),
          dropdownColor: Colors.white,
          items: status.map((dynamic value) {
            return DropdownMenuItem<dynamic>(
              value: value,
              child: Center(
                child: Text(
                  "${value["blocks"]} blocks - ${value["value"]} sats/vbyte",
                  style: TextStyle(fontSize:  titleFontSize / 2, color: Colors.white),
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
        ),
      ],
    );
  }

  Widget _bitcoinFeeSlider(WidgetRef ref, double dynamicPadding, double titleFontSize) {
    return InteractiveSlider(
      centerIcon: const Icon(Clarity.block_solid, color: Colors.black),
      foregroundColor: Colors.deepOrange,
      unfocusedHeight: titleFontSize ,
      focusedHeight: titleFontSize,
      initialProgress: 15,
      min: 5.0,
      max: 1.0,
      onChanged: (dynamic value){
        ref.read(sendBlocksProvider.notifier).state = value;
      },
    );
  }

  Widget _liquidFeeSlider(WidgetRef ref, double dynamicPadding, double titleFontSize) {
    return Column(
      children: [
        SizedBox(height: dynamicPadding / 2),
        Text("Choose Fee:".i18n(ref), style: TextStyle(fontSize:  titleFontSize / 2, color: Colors.white)),
        InteractiveSlider(
          padding: EdgeInsets.only(bottom: dynamicPadding / 2),
          foregroundColor: Colors.black,
          unfocusedHeight: titleFontSize ,
          focusedHeight: titleFontSize,
          initialProgress: 15,
          min: 5.0,
          max: 1.0,
          onChanged: (dynamic value){
            ref.read(sendBlocksProvider.notifier).state = value;
          },
        ),
        // Slider(value: ref.watch(sendBlocksProvider).toDouble(), onChanged: (value) => ref.read(sendBlocksProvider.notifier).state = value, min: 1, max: 15, divisions: 14, label: ref.watch(sendBlocksProvider).toInt().toString()),
      ],
    );
  }

  Widget _buildBitcoinFeeInfo (WidgetRef ref, double dynamicPadding, double titleFontSize) {
    return Column(
        children: [
          ref.watch(feeProvider).when(
            data: (int fee) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${'Sending Transaction fee:'.i18n(ref)}$fee sats",
                  style: TextStyle(fontSize:  titleFontSize / 2, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            },
            loading: () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: LoadingAnimationWidget.prograssiveDots(size:  titleFontSize / 2, color: Colors.white),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () { ref.refresh(feeProvider); },
                  child: Text(ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize / 2))
              ),
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
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${'Sending Transaction fee:'.i18n(ref)}$fee sats",
                  style: TextStyle(fontSize:  titleFontSize / 2, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            },
            loading: () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: LoadingAnimationWidget.prograssiveDots(size:  titleFontSize / 2, color: Colors.white),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () { ref.refresh(liquidFeeProvider); },
                  child: Text(ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize / 2))
              ),
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
          Text('Bitcoin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          if (!pegIn)
            Padding(
              padding: EdgeInsets.symmetric(vertical: dynamicPadding / 4),
              child: Column(
                children: [
                  Text("Receive".i18n(ref), style: TextStyle(fontSize: titleFontSize / 1.5, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                  if (double.parse(formattedValueToReceive) <= 0)
                    Text("0", style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)
                  else
                    Column(
                      children: [
                        Text(" ~ $formattedValueToReceive", style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center),
                        Text("or".i18n(ref), style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center),
                        Text(valueInCurrency.toStringAsFixed(2) + ' $currency', style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white), textAlign: TextAlign.center),
                      ],
                    ),
                  Text(
                    '${'Minimum amount:'.i18n(ref)} ${btcInDenominationFormatted(pegIn ? status.minPegInAmount.toDouble() : status.minPegOutAmount.toDouble(), btcFormart)} $btcFormart',
                    style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            sideSwapPeg.when(
              data: (peg) {
                return TextFormField(
                  keyboardType: TextInputType.number,
                  controller: controller,
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()],
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
                );
              },
              loading: () => Center(child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
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
          Text('Liquid', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          if (pegIn)
            Padding(
              padding: EdgeInsets.symmetric(vertical: dynamicPadding / 4),
              child: Column(
                children: [
                  Text("Receive".i18n(ref), style: TextStyle(fontSize: titleFontSize / 1.5, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                  if (double.parse(formattedValueToReceive) <= 0)
                    Text("0", style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)
                  else
                    Column(
                      children: [
                        Text(" ~ $formattedValueToReceive", style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center),
                        Text("or".i18n(ref), style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center),
                        Text(valueInCurrency.toStringAsFixed(2) + ' $currency', style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white), textAlign: TextAlign.center),
                      ],
                    ),
                  Text(
                    '${'Minimum amount:'.i18n(ref)} ${btcInDenominationFormatted(pegIn ? status.minPegInAmount.toDouble() : status.minPegOutAmount.toDouble(), btcFormart)} $btcFormart',
                    style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            sideSwapPeg.when(
              data: (peg) {
                return TextFormField(
                  keyboardType: TextInputType.number,
                  controller: controller,
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()],
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
                );
              },
              loading: () => Center(child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
              error: (error, stack) => Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize: titleFontSize / 2)),
            ),
        ],
      ),
    );
  }
}



