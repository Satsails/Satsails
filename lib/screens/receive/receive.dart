import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/receive/components/bitcoin_widget.dart';
import 'package:Satsails/screens/receive/components/custodial_lightning_widget.dart';
import 'package:Satsails/screens/receive/components/liquid_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/providers/address_receive_provider.dart';

final selectedReceiveTypeProvider = StateProvider<String>((ref) => "Bitcoin network");

class Receive extends ConsumerWidget {
  const Receive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;

    final selectedType = ref.watch(selectedReceiveTypeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Receive on ${selectedType.i18n}', style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenHeight * 0.03, color: Colors.white),
          onPressed: () {
            ref.read(inputAmountProvider.notifier).state = '0.0';
            ref.invalidate(initialCoinosProvider);
            ref.read(selectedReceiveTypeProvider.notifier).state = "Bitcoin";
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
    );
  }
}
