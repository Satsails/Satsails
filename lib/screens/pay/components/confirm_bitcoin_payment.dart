import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/models/address_model.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import '../../../providers/balance_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class ConfirmBitcoinPayment extends ConsumerWidget {
  const ConfirmBitcoinPayment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardMargin = screenWidth * 0.05;
    final cardPadding = screenWidth * 0.04;
    final titleFontSize = screenHeight * 0.03;
    final sendTxState = ref.watch(sendTxProvider);
    final initializeBalance = ref.watch(initializeBalanceProvider);
    final settingsValue = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(settingsValue));
    final TextEditingController _controller = TextEditingController(text: sendTxState.amount.toCurrencyString(leadingSymbol: CurrencySymbols.BITCOIN_SIGN, mantissaLength: 8));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Confirm Payment'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  margin: EdgeInsets.all(cardMargin),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: cardPadding, horizontal: cardPadding / 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bitcoin Balance', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                          initializeBalance.when(
                              data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text('$btcBalanceInFormat $settingsValue', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                              loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                              error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      items: const [
                        DropdownMenuItem(
                          value: 'btc',
                          child: Text('Bitcoin'),
                        ),
                        DropdownMenuItem(
                          value: 'usd',
                          child: Text('USD'),
                        ),
                        DropdownMenuItem(
                          value: 'eur',
                          child: Text('EUR'),
                        ),
                        DropdownMenuItem(
                          value: 'brl',
                          child: Text('BRL'),
                        ),
                      ],
                      value: ref.watch(sendCurrencyProvider),
                      onChanged: (String? value) {
                        ref.read(sendCurrencyProvider.notifier).state = value!;
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _controller,
                        style: const TextStyle(fontSize: 30),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          CurrencyInputFormatter(
                            leadingSymbol: CurrencySymbols.BITCOIN_SIGN,
                            mantissaLength: 8,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ActionSlider.standard(
                sliderBehavior: SliderBehavior.stretch,
                width: 300.0,
                backgroundColor: Colors.white,
                toggleColor: Colors.deepOrangeAccent,
                action: (controller) async {
                  controller.loading();
                  await Future.delayed(const Duration(seconds: 3));
                  controller.success();
                  await Future.delayed(const Duration(seconds: 1));
                  controller.reset();
                },
                child: const Text('Slide to confirm'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int checkAssetBalance(PaymentType paymentType, WidgetRef ref, sendTxProvider) {
  final balanceProvider = ref.watch(balanceNotifierProvider);
  if (paymentType == PaymentType.Bitcoin) {
    return balanceProvider.btcBalance;
  } else if (paymentType == PaymentType.Liquid) {
    switch (AssetMapper.mapAsset(sendTxProvider.assetId)) {
      case AssetId.LBTC:
        return balanceProvider.liquidBalance;
      case AssetId.USD:
        return balanceProvider.usdBalance;
      case AssetId.EUR:
        return balanceProvider.eurBalance;
      case AssetId.BRL:
        return balanceProvider.brlBalance;
      default:
        return balanceProvider.liquidBalance;
    }
  }
  else {
    return balanceProvider.liquidBalance;
  }
}