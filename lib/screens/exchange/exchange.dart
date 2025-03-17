import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            'Exchange'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: KeyboardDismissOnTap(
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
      ),
    );
  }
}