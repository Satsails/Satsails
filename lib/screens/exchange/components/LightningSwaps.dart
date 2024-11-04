import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/coinos.provider.dart';
import 'package:Satsails/screens/exchange/components/ln_receive_fees.dart';
import 'package:Satsails/screens/exchange/components/ln_send_fees.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    final inProcessing = ref.watch(transactionInProgressProvider);
    final sendLn = ref.watch(sendLightningProvider);
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

    return PopScope(
      onPopInvoked: (pop) async {
        if (inProcessing) {
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
          context.pop();
        }
      },
      child: SafeArea(
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
                ],
              ),
              SizedBox(height: dynamicPadding),
              ...swapCards,
              if (!sendLn)
                DisplayFeesWidget()
              else
                ReceiveFeesWidget(),
              const Spacer(),
              if(sendLbtc)
                _liquidSlideToSend(ref, dynamicPadding, titleFontSize, context)
              else
                _bitcoinSlideToSend(ref, dynamicPadding, titleFontSize, context)
            ],
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
            var id;
            try {
              if (sendLn) {
                final receiveBoltz = await ref.read(boltzReceiveProvider.future);
                id = receiveBoltz.swap.id;
                final address = receiveBoltz.swap.invoice;
                ref.read(sendTxProvider.notifier).updateAddress(address);
                await ref.read(sendSwapToProvider.future);
                await ref.read(claimSingleBoltzTransactionProvider(receiveBoltz.swap.id).future);
                await ref.read(liquidSyncNotifierProvider.notifier).performSync();
              } else {
                await ref.read(receiveSwapFromProvider.future);
                final pay = await ref.read(boltzPayProvider.future);
                id = pay.swap.id;
                await ref.read(liquidSyncNotifierProvider.notifier).performSync();
                final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
                final lnBalance = await ref.read(coinosBalanceProvider.future);
                balanceNotifier.updateLightningBalance(lnBalance);
              }
              Fluttertoast.showToast(
                msg: "Swap done!".i18n(ref),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              ref.read(transactionInProgressProvider.notifier).state = false;
              context.go('/home');
            } catch (e) {
              if (id != null) {
                ref.read(deleteBoltzTransactionProvider(id).future);
              }
              ref.read(transactionInProgressProvider.notifier).state = false;
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
            var id;
            try {
              if (sendLn) {
                final receiveBoltz = await ref.read(bitcoinBoltzReceiveProvider.future);
                final address = receiveBoltz.swap.invoice;
                id = receiveBoltz.swap.id;
                ref.read(sendTxProvider.notifier).updateAddress(address);
                await ref.read(sendSwapToProvider.future);
                await ref.read(claimSingleBitcoinBoltzTransactionProvider(receiveBoltz.swap.id).future);
                await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
              } else {
                await ref.read(receiveSwapFromProvider.future);
                final pay = await ref.read(bitcoinBoltzPayProvider.future);
                id = pay.swap.id;
                await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
                final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
                final lnBalance = await ref.read(coinosBalanceProvider.future);
                balanceNotifier.updateLightningBalance(lnBalance);
              }
              Fluttertoast.showToast(
                msg: "Swap done!".i18n(ref),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              ref.read(transactionInProgressProvider.notifier).state = false;
              context.go('/home');
            } catch (e) {
              if (id != null) {
                ref.read(deleteBoltzTransactionProvider(id).future);
              }
              ref.read(transactionInProgressProvider.notifier).state = false;
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



