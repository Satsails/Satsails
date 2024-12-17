import 'package:Satsails/helpers/transaction_helpers.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Exchange extends ConsumerStatefulWidget {
  const Exchange({super.key});

  @override
  _ExchangeState createState() => _ExchangeState();
}

class _ExchangeState extends ConsumerState<Exchange> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final fromAsset = ref.watch(fromAssetProvider);
    final toAsset = ref.watch(toAssetProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Exchange'.i18n(ref),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            ref.read(sendTxProvider.notifier).resetToDefault();
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: FlutterKeyboardDoneWidget(
            doneWidgetBuilder: (context) {
              return const Text('Done');
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildBalanceCardWithMaxButton(ref, 16, 20, controller),
                SizedBox(height: 16),
                buildExchangeCard(fromAsset, toAsset, context, ref, controller),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}