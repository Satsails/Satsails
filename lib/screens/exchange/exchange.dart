import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        backgroundColor: Colors.transparent, // Transparent to show extended body
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Text(
            'Exchange'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          bottom: false, // Allow content to extend to bottom
          child: Stack(
            children: [
              // Background for content area
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black, // Content background
                  ),
                ),
              ),
              KeyboardDismissOnTap(
                child: ListView(
                  children: [
                    buildBalanceCardWithMaxButton(ref, controller),
                    SizedBox(height: 0.01.sh),
                    buildExchangeCard(context, ref, controller),
                    SizedBox(height: 0.01.sh),
                    buildAdvancedOptionsCard(ref),
                    feeSelection(ref),
                    slideToSend(ref, context),
                    // Add bottom padding to scroll past nav bar
                    SizedBox(height: 100.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}