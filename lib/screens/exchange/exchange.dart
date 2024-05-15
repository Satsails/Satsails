import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/exchange/components/button_picker.dart';
import 'package:Satsails/screens/exchange/components/liquid_swap_cards.dart';
import 'package:Satsails/screens/exchange/components/peg.dart';
import 'package:Satsails/screens/shared/offline_transaction_warning.dart';

class Exchange extends ConsumerWidget {
  Exchange({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final online = ref.watch(settingsProvider).online;
    final button = ref.watch(selectedButtonProvider);

    return PopScope(
      onPopInvoked: (pop) async {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(selectedButtonProvider.notifier).state = "Bitcoin Layer Swap";
        ref.read(sendBlocksProvider.notifier).state = 1;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Exchange'.i18n(ref)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const ButtonPicker(),
              OfflineTransactionWarning(online: online),
              SizedBox(height: dynamicSizedBox),
              if(button == 'Bitcoin Layer Swap')  const Expanded(child: Peg()),
              if(button == 'Swap') const Expanded(child: LiquidSwapCards()),
            ],
          ),
        ),
      ),
    );
  }
}
