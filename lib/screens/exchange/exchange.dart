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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final swapType = ref.read(swapTypeProvider);
      if (swapType != null) {
        ref.read(swapTypeNotifierProvider.notifier).updateProviders(swapType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: FlutterKeyboardDoneWidget(
          doneWidgetBuilder: (context) {
            return const Text('Done');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                buildBalanceCardWithMaxButton(ref, 16, 20, controller),
                SizedBox(height: 16),
                buildExchangeCard(context, ref, controller),
                SizedBox(height: 16),
                buildAdvancedOptionsCard(ref, 16, 20),
                SizedBox(height: 16),
                feeSelection(ref, 16, 20),
                Spacer(),
                slideToSend(ref, 16, 20, context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}