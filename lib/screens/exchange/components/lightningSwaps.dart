import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/transaction_helpers.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';

final sendLightningProvider = StateProvider.autoDispose<bool>((ref) => false);
final sendLbtcProvider = StateProvider.autoDispose<bool>((ref) => true);

final currentBalanceProvider = StateProvider.autoDispose<String>((ref) {
  final btcFormat = ref.read(settingsProvider).btcFormat;
  final sendLn = ref.watch(sendLightningProvider);
  if (sendLn) {
    return ref.read(lightningBalanceInFormatProvider(btcFormat));
  } else if (ref.watch(sendLbtcProvider)) {
    return ref.read(liquidBalanceInFormatProvider(btcFormat));
  } else {
    return ref.read(btcBalanceInFormatProvider(btcFormat));
  }
});

class LightningSwaps extends ConsumerStatefulWidget {
  const LightningSwaps({super.key});

  @override
  _LightningSwapsState createState() => _LightningSwapsState();

}

class _LightningSwapsState extends ConsumerState<LightningSwaps> {

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final currentBalance = ref.watch(currentBalanceProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final sendLn = ref.watch(sendLightningProvider);
    final btcFormat = ref.read(settingsProvider).btcFormat;
    final sendLbtc = ref.watch(sendLbtcProvider);

    List<Column> cards = [
      buildCard('Liquid Bitcoin', ref, context, titleFontSize),
      buildCard('Bitcoin', ref, context, titleFontSize),
    ];

    List<Widget> swapCards = [
      Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sendLn
                ? [
              buildCard('Lightning', ref, context, titleFontSize),
              SizedBox(height: dynamicSizedBox),
              buildCardSwiper(context, ref, dynamicCardHeight, cards),
            ]
                : [
              buildCardSwiper(context, ref, dynamicCardHeight, cards),
              SizedBox(height: dynamicSizedBox),
              buildCard('Lightning', ref, context, titleFontSize),
            ],
          ),
          buildSwapGestureDetector(context, ref, titleFontSize),
        ],
      ),
    ];

    return SafeArea(
      child: FlutterKeyboardDoneWidget(
        doneWidgetBuilder: (context) {
          return const Text(
            'Done',
          );
        },
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
                  currentBalance,
                  style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                _buildMaxButton(ref, dynamicPadding, dynamicFontSize, btcFormat, titleFontSize, sendLn, sendLbtc),
              ],
            ),
            SizedBox(height: dynamicPadding),
            ...swapCards,
            if(sendLn)
              _bitcoinFeeSlider(ref, dynamicPadding, titleFontSize)
            else
              _liquidFeeSlider(ref, dynamicPadding, titleFontSize),
            const Spacer(),
            if(sendLbtc)
              _liquidSlideToSend(ref, dynamicPadding, titleFontSize, context)
            else
              _bitcoinSlideToSend(ref, dynamicPadding, titleFontSize, context)
          ],
        ),
      ),
    );
  }

  Widget _buildMaxButton(WidgetRef ref, double dynamicPadding, double dynamicFontSize, String btcFormat, double titleFontSize, bool sendLn, bool sendLbtc) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white, // Applied the same background color
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            ref.watch(sendTxProvider.notifier).updateDrain(true);
            if (sendLn) {
              final balance = ref.read(balanceNotifierProvider).lightningBalance;
              int maxAmount = (balance! * 0.995).toInt();
              controller.text = btcInDenominationFormatted(maxAmount, btcFormat);
            } else {
              if (!sendLbtc) {
                final balance = ref.read(balanceNotifierProvider).btcBalance;
                final address = await ref.read(createInvoiceForSwapProvider('bitcoin').future);
                ref.read(sendTxProvider.notifier).updateAddress(address);
                final transactionBuilderParams = await ref.watch(bitcoinTransactionBuilderProvider(balance).future).then((value) => value);
                final transaction = await ref.watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilderParams).future).then((value) => value);
                final fee = await transaction.$1.feeAmount().then((value) => value);
                final amountToSet = (balance - fee!);
                controller.text = btcInDenominationFormatted(amountToSet, btcFormat);
              } else {
                final address = await ref.read(createInvoiceForSwapProvider('liquid').future);
                ref.read(sendTxProvider.notifier).updateAddress(address);
                final pset = await ref.watch(liquidDrainWalletProvider.future);
                final sendingBalance = pset.balances[0].value + pset.absoluteFees;
                final controllerValue = sendingBalance.abs();
                controller.text = btcInDenominationFormatted(controllerValue, btcFormat);
              }
            }
            ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dynamicPadding, vertical: dynamicPadding / 2.5), // Adjusted padding to match the other button
            child: Text(
              'Max',
              style: TextStyle(
                fontSize: titleFontSize / 2,
                color: Colors.black, // Applied the same text color
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCardSwiper(BuildContext context, WidgetRef ref, double dynamicCardHeight, List<Column> cards) {
    return SizedBox(
      height: dynamicCardHeight,
      child: CardSwiper(
        scale: 0,
        padding: const EdgeInsets.all(0),
        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(vertical: true),
        cardsCount: cards.length,
        onSwipe: (int previousIndex, int? currentIndex, CardSwiperDirection direction) {
          controller.text = '';
          ref.read(sendTxProvider.notifier).updateAmount(0);
          ref.read(sendTxProvider.notifier).updateAddress('');
          ref.read(sendBlocksProvider.notifier).state = 1;
          ref.read(sendTxProvider.notifier).updateDrain(false);

          ref.read(sendLbtcProvider.notifier).state = !ref.watch(sendLbtcProvider);

          return true;
        },
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          return Align(
            alignment: Alignment.center,
            child: cards[index],
          );
        },
      ),
    );
  }

  Widget buildSwapGestureDetector(BuildContext context, WidgetRef ref, double titleFontSize) {
    return Positioned(
      top: titleFontSize / 1,
      bottom: titleFontSize / 1,
      child: GestureDetector(
        onTap: () {
          ref.read(sendTxProvider.notifier).updateAddress('');
          ref.read(sendTxProvider.notifier).updateAmount(0);
          ref.read(sendBlocksProvider.notifier).state = 1;
          ref.refresh(currentBalanceProvider);
          ref.read(sendTxProvider.notifier).updateDrain(false);
          ref.read(sendLightningProvider.notifier).state = !ref.watch(sendLightningProvider);
          ref.read(sendLbtcProvider.notifier).state = true;
          controller.text = '';
        },
        child: CircleAvatar(
          radius: titleFontSize,
          backgroundColor: Colors.orange,
          child: Icon(EvaIcons.swap, size: titleFontSize, color: Colors.black),
        ),
      ),
    );
  }

  Column buildCard(String title, WidgetRef ref, BuildContext context, double titleFontSize) {
    final btcFormat = ref.read(settingsProvider).btcFormat;

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title != 'Lightning')
                const Icon(Icons.swipe_vertical, color: Colors.grey),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: controller,
                inputFormatters: ref.read(settingsProvider).btcFormat == 'BTC'
                    ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)]
                    : [DecimalTextInputFormatter(decimalRange: 0)],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold),
                ),
                style: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold),
                onChanged: (value) async {
                  if (value.isEmpty) {
                    ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                    ref.read(sendTxProvider.notifier).updateDrain(false);
                  }
                  ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                  ref.read(sendTxProvider.notifier).updateDrain(false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _liquidSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
    final sendLn = ref.watch(sendLightningProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: dynamicPadding / 2),
      child: Align(
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
              if (sendLn) {
                final liquidAddress = await ref.read(liquidAddressProvider.future);
                ref.read(sendTxProvider.notifier).updateAddress(liquidAddress.confidential);
                await ref.read(sendCoinosLiquidProvider.future);
                await ref.read(liquidSyncNotifierProvider.notifier).performSync();
              } else {
                final addressFromCoinos = await ref.read(createInvoiceForSwapProvider('liquid').future);
                ref.read(sendTxProvider.notifier).updateAddress(addressFromCoinos);
                await ref.read(sendLiquidTransactionProvider.future);
                final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
                final lnBalance = await ref.read(coinosBalanceProvider.future);
                balanceNotifier.updateLightningBalance(lnBalance);
                await ref.read(liquidSyncNotifierProvider.notifier).performSync();
              }
              showMessageSnackBar(
                message: 'Swap done!'.i18n(ref),
                error: false,
                context: context,
              );
              controller.success();
              ref.read(transactionInProgressProvider.notifier).state = false;
              context.go('/home');
            } catch (e) {
              ref.read(transactionInProgressProvider.notifier).state = false;
              controller.failure();
              showMessageSnackBar(
                message: e.toString().i18n(ref),
                error: true,
                context: context,
              );
              controller.reset();
            }
          },
          child: Text(
            'Slide to Swap'.i18n(ref),
            style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _bitcoinSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
    final sendLn = ref.watch(sendLightningProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: dynamicPadding / 2),
      child: Align(
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
              if (sendLn) {
                final btcAddress = await ref.read(bitcoinAddressProvider.future);
                ref.read(sendTxProvider.notifier).updateAddress(btcAddress);
                await ref.read(sendCoinosBitcoinProvider.future);
                await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
              } else {
                final addressFromCoinos = await ref.read(createInvoiceForSwapProvider('bitcoin').future);
                ref.read(sendTxProvider.notifier).updateAddress(addressFromCoinos);
                await ref.read(sendBitcoinTransactionProvider.future);
                final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
                final lnBalance = await ref.read(coinosBalanceProvider.future);
                balanceNotifier.updateLightningBalance(lnBalance);
                await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
              }
              showMessageSnackBar(
                message: 'Swap done!'.i18n(ref),
                error: false,
                context: context,
              );
              controller.success();
              ref.read(transactionInProgressProvider.notifier).state = false;
              context.go('/home');
            } catch (e) {
              ref.read(transactionInProgressProvider.notifier).state = false;
              controller.failure();
              showMessageSnackBar(
                message: e.toString().i18n(ref),
                error: true,
                context: context,
              );
              controller.reset();
            }
          },
          child: Text(
            'Slide to Swap'.i18n(ref),
            style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white),
          ),
        ),
      ),
    );
  }
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





