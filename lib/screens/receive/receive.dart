import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/receive/components/bitcoin_widget.dart';
import 'package:Satsails/screens/receive/components/custodial_lightning_widget.dart';
import 'package:Satsails/screens/receive/components/liquid_widget.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/providers/address_receive_provider.dart';


class Receive extends ConsumerWidget {
  const Receive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedNetworkTypeProvider);
    Future.microtask(() => {ref.read(shouldUpdateMemoryProvider.notifier).state = false});

    return WillPopScope(
      onWillPop: () async {
        try {
          ref.read(inputAmountProvider.notifier).state = '0.0';
          ref.invalidate(initialCoinosProvider);
          ref.read(selectedNetworkTypeProvider.notifier).state = "Bitcoin";
          Future.microtask(() => {
            ref.read(shouldUpdateMemoryProvider.notifier).state = true,
          });
          return true; // Allow the pop to proceed
        } catch (e) {
          return false; // Prevent pop if an error occurs
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Receive on ${selectedType.i18n}', style: const TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              ref.read(inputAmountProvider.notifier).state = '0.0';
              ref.invalidate(initialCoinosProvider);
              ref.read(selectedNetworkTypeProvider.notifier).state = "Bitcoin";
              Future.microtask(() => {
                ref.read(shouldUpdateMemoryProvider.notifier).state = true,
              });
              context.pop();
            },
          ),
        ),
        body: KeyboardDismissOnTap(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedType == 'Bitcoin network') const BitcoinWidget(),
              if (selectedType == 'Liquid network') const LiquidWidget(),
              // if (selectedType == 'Lightning network') const CustodialLightningWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
