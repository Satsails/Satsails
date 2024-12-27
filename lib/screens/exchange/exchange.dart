import 'package:Satsails/helpers/transaction_helpers.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Exchange extends ConsumerStatefulWidget {
  const Exchange({super.key});

  @override
  _ExchangeState createState() => _ExchangeState();
}

class _ExchangeState extends ConsumerState<Exchange> {
  final TextEditingController controller = TextEditingController();

  @override
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
          style: TextStyle(color: Colors.white, fontSize: 20.sp), // Responsive font size
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
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                buildBalanceCardWithMaxButton(ref, controller),
                SizedBox(height: 0.01.sh),
                buildExchangeCard(context, ref, controller),
                SizedBox(height: 0.01.sh),
                buildAdvancedOptionsCard(ref),
                SizedBox(height: 0.01.sh),
                feeSelection(ref),
                SizedBox(height: 0.01.sh),
                slideToSend(ref, context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

