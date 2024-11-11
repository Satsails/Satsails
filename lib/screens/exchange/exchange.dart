import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/exchange/components/lightningSwaps.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/exchange/components/liquid_swap_cards.dart';
import 'package:Satsails/screens/exchange/components/peg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

final selectedExchangeTypeProvider = StateProvider<String>((ref) => "Stable ⇄ Liquid");
final transactionInProgressProvider = StateProvider.autoDispose<bool>((ref) => false);

class Exchange extends ConsumerWidget {
  Exchange({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final selectedType = ref.watch(selectedExchangeTypeProvider);
    final showLnUrl = ref.watch(coinosLnProvider).token.isNotEmpty;

    return PopScope(
      onPopInvoked: (pop) async {
        if (ref.watch(transactionInProgressProvider)) {
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
          ref.read(selectedExchangeTypeProvider.notifier).state = "Stable ⇄ Liquid";
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Exchange'.i18n(ref), style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (!ref.watch(transactionInProgressProvider)) {
                ref.read(sendTxProvider.notifier).resetToDefault();
                ref.read(sendBlocksProvider.notifier).state = 1;
                ref.read(selectedExchangeTypeProvider.notifier).state = "Stable ⇄ Liquid";
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  dropdownColor: Colors.grey[900],
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.orange,
                    size: MediaQuery.of(context).size.width * 0.08,
                  ),
                  underline: const SizedBox(),
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: (String? newValue) {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    ref.read(sendBlocksProvider.notifier).state = 1;
                    if (newValue != null) {
                      ref.read(selectedExchangeTypeProvider.notifier).state = newValue;
                    }
                  },
                  items: <String>[
                    'Stable ⇄ Liquid',
                    'Liquid ⇄ BTC',
                    if (showLnUrl) 'Lightning ⇄ Bitcoin' // Only show if `showLnUrl` is true
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          value.i18n(ref),
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: MediaQuery.of(context).size.width * 0.045,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: dynamicSizedBox),
            if (selectedType == 'Stable ⇄ Liquid') const Expanded(child: LiquidSwapCards()),
            if (selectedType == 'Liquid ⇄ BTC') const Expanded(child: Peg()),
            if (selectedType == 'Lightning ⇄ Bitcoin' && showLnUrl) const Expanded(child: LightningSwaps()),
          ],
        ),
      ),
    );
  }
}