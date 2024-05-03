import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/screens/exchange/components/button_picker.dart';
import 'package:satsails/providers/sideswap_provider.dart';
import 'package:satsails/screens/exchange/components/peg.dart';
import 'package:satsails/screens/shared/offline_transaction_warning.dart';

class Exchange extends ConsumerWidget {
  Exchange({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final online = ref.watch(settingsProvider).online;

    return PopScope(
      onPopInvoked: (pop) async {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(sendBlocksProvider.notifier).state = 1;
        ref.watch(closeSideswapProvider);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Exchange'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ButtonPicker(),
              OfflineTransactionWarning(online: online),
              SizedBox(height: dynamicSizedBox),
              // Expanded(child: Peg()),
            ],
          ),
        ),
      ),
    );
  }
}
