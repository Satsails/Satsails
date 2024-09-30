import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/exchange/components/button_picker.dart';
import 'package:Satsails/screens/exchange/components/liquid_swap_cards.dart';
import 'package:Satsails/screens/exchange/components/peg.dart';

class Exchange extends ConsumerWidget {
  Exchange({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final button = ref.watch(selectedButtonProvider);

    return PopScope(
      onPopInvoked: (pop) async {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(sendBlocksProvider.notifier).state = 1;
        ref.read(selectedButtonProvider.notifier).state = "Swap";
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
              ref.read(sendTxProvider.notifier).resetToDefault();
              ref.read(sendBlocksProvider.notifier).state = 1;
              ref.read(selectedButtonProvider.notifier).state = "Swap";
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            const ButtonPicker(),
            // OfflineTransactionWarning(online: online),
            SizedBox(height: dynamicSizedBox),
            if(button == 'Swap') const Expanded(child: LiquidSwapCards()),
            if(button == 'Bitcoin Layer Swap') const Expanded(child: Peg()),
          ],
        ),
      ),
    );
  }
}
