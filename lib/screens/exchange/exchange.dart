// import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/screens/exchange/components/button_picker.dart';

final cardOrderProvider = StateProvider<bool>((ref) => false);

class Exchange extends HookConsumerWidget {
  Exchange({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final titleFontSize =MediaQuery.of(context).size.height * 0.03;
    final isReversed = ref.watch(cardOrderProvider);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormart));
    final initializeBalance = ref.watch(initializeBalanceProvider);
    final liquidFormart = ref.watch(settingsProvider).btcFormat;
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(liquidFormart));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Exchange'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ButtonPicker(),
            SizedBox(height: dynamicSizedBox),
            const Flexible(
              child: Text(
                "Balance to spend:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            if(isReversed)
              initializeBalance.when(
                  data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text('$btcBalanceInFormat $btcFormart', style: TextStyle(fontSize: titleFontSize, color: Colors.grey), textAlign: TextAlign.center)),
                  loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.grey)),
                  error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
              )
            else
              initializeBalance.when(
                  data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text('$liquidBalanceInFormat $liquidFormart', style: TextStyle(fontSize: titleFontSize, color: Colors.grey), textAlign: TextAlign.center)),
                  loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.grey)),
                  error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
              ),
            SizedBox(height: dynamicSizedBox),
            if (isReversed) _buildBitcoinCard(ref, dynamicPadding, titleFontSize, isReversed) else _buildLiquidCard(ref, dynamicPadding, titleFontSize, isReversed),
            Text("Switch", style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey)),
            GestureDetector(
              onTap: () => ref.read(cardOrderProvider.notifier).state = !isReversed,
              child: Icon(EvaIcons.swap, size: titleFontSize, color: Colors.grey),
            ),
            if (isReversed) _buildLiquidCard(ref, dynamicPadding, titleFontSize, isReversed) else _buildBitcoinCard(ref, dynamicPadding, titleFontSize, isReversed),
            SizedBox(height: dynamicSizedBox),
            const Flexible(
              child: Text(
                "Bitcoin is for security",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const Flexible(
              child: Text(
                "Liquid Bitcoin is to use on Lightening network and cheap transactions",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBitcoinCard (WidgetRef ref, double dynamicPadding, double titleFontSize, bool isReversed) {
    final controller = TextEditingController();

    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 10,
        margin: EdgeInsets.all(dynamicPadding),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: dynamicPadding, top: dynamicPadding / 3),
                child: Text('Bitcoin', style: TextStyle(fontSize: titleFontSize / 1.5, color: Colors.white), textAlign: TextAlign.center),
              ),
              if (!isReversed) Text('value of receber bicho', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)
              else
              Padding(
                padding: EdgeInsets.symmetric(vertical: dynamicPadding, horizontal: dynamicPadding / 2),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '',
                  ),
                  style: TextStyle(fontSize: titleFontSize / 1.5),
                  textAlign: TextAlign.center,
                  onChanged: (value) async {
                    // ref.read(sendAmountProvider.notifier).state = ((double.parse(value) * 100000000).toInt());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidCard (WidgetRef ref, double dynamicPadding, double titleFontSize, bool isReversed) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 10,
        margin: EdgeInsets.all(dynamicPadding),
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
            padding: EdgeInsets.only(bottom: dynamicPadding, top: dynamicPadding / 3),
            child: const Text('Liquid Bitcoin', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
