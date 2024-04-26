import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/screens/exchange/components/button_picker.dart';
import 'package:satsails/providers/sideswap_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';



class Exchange extends HookConsumerWidget {
  Exchange({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final titleFontSize =MediaQuery.of(context).size.height * 0.03;
    final pegIn = ref.watch(pegInProvider);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormart));
    final liquidFormart = ref.watch(settingsProvider).btcFormat;
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(liquidFormart));
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final status = ref.watch(sideswapStatusProvider);

    useEffect(() {
      ref.read(initializeBalanceProvider);
      return null;
    }, []);

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
            Flexible(
              child: Text(
                "Balance to spend:",
                style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey),
              ),
            ),
            if(pegIn)
              SizedBox(height: titleFontSize * 1.5, child: Text('$btcBalanceInFormat $btcFormart', style: TextStyle(fontSize: titleFontSize, color: Colors.grey), textAlign: TextAlign.center))
            else
              SizedBox(height: titleFontSize * 1.5, child:Text('$liquidBalanceInFormat $liquidFormart', style: TextStyle(fontSize: titleFontSize, color: Colors.grey), textAlign: TextAlign.center)),
            SizedBox(height: dynamicSizedBox / 2),
            if (pegIn) _buildBitcoinCard(ref, dynamicPadding, titleFontSize, pegIn) else _buildLiquidCard(ref, dynamicPadding, titleFontSize, pegIn),
            GestureDetector(
              onTap: () => ref.read(pegInProvider.notifier).state = !pegIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Switch", style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey)),
                  Icon(EvaIcons.swap, size: titleFontSize, color: Colors.grey),
                ],
              ),
            ),
            if (pegIn) _buildLiquidCard(ref, dynamicPadding, titleFontSize, pegIn) else _buildBitcoinCard(ref, dynamicPadding, titleFontSize, pegIn),
            if (pegIn) Text('Minimum amount: ${status.minPegInAmount / 100000000}BTC', style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey), textAlign: TextAlign.center) else Text('Minimum amount: ${status.minPegOutAmount / 100000000}BTC', style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey), textAlign: TextAlign.center),
            SizedBox(height: dynamicSizedBox),
            const Flexible(
              child: Text(
                "Bitcoin is for security",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const Flexible(
              child: Text(
                "Liquid Bitcoin for Lightening network use and cheap transactions",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBitcoinCard (WidgetRef ref, double dynamicPadding, double titleFontSize, bool pegIn) {
    final sideSwapStatus = ref.watch(sideswapStatusProvider);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final valueToReceive = ref.watch(sendTxProvider).amount / 100000000 * ( 1- sideSwapStatus.serverFeePercentPegIn! / 100);

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
              if (!pegIn) Padding(
                padding: EdgeInsets.only(bottom: dynamicPadding / 2 , top: dynamicPadding / 3),
                child: Column(
                  children: [
                    Text("Receive", style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white), textAlign: TextAlign.center),
                    Text("$valueToReceive", style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white), textAlign: TextAlign.center),
                  ],
                ),
              )
              else
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()],
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  onChanged: (value) async {
                    if (value.isEmpty) {
                      ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                    }
                    ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidCard (WidgetRef ref, double dynamicPadding, double titleFontSize, bool pegIn) {
    final sideSwapStatus = ref.watch(sideswapStatusProvider);
    final valueToReceive = ref.watch(sendTxProvider).amount / 100000000 * ( 1- sideSwapStatus.serverFeePercentPegIn! / 100);
    final btcFormart = ref.watch(settingsProvider).btcFormat;

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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: dynamicPadding, top: dynamicPadding / 3),
                child: const Text('Liquid Bitcoin', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
              ),
              if (pegIn) Padding(
                padding: EdgeInsets.only(bottom: dynamicPadding / 2, top: dynamicPadding / 3),
                child:Column(
                  children: [
                    Text("Receive", style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white), textAlign: TextAlign.center),
                    Text("$valueToReceive", style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white), textAlign: TextAlign.center),
                  ],
                ),
              )
              else
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()],
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  onChanged: (value) async {
                    if (value.isEmpty) {
                      ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                    }
                    ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
