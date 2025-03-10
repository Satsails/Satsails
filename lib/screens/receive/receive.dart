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

final selectedReceiveTypeProvider = StateProvider<String>((ref) => "Bitcoin");

class Receive extends ConsumerWidget {
  const Receive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final selectedType = ref.watch(selectedReceiveTypeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Receive'.i18n, style: const TextStyle(color: Colors.white)),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // DropdownButton to select the receive type
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    dropdownColor: Colors.grey[900],
                    icon: Icon(Icons.arrow_drop_down, color: Colors.orange, size: screenWidth * 0.08),
                    underline: const SizedBox(),
                    style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        ref.read(selectedReceiveTypeProvider.notifier).state = newValue;
                        ref.read(inputCurrencyProvider.notifier).state = 'BTC';
                        ref.read(inputAmountProvider.notifier).state = '0.0';
                        ref.read(isBitcoinInputProvider.notifier).state = true;
                        ref.invalidate(initialCoinosProvider);
                      }
                    },
                    items: <String>['Bitcoin', 'Liquid', 'Lightning']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            value.i18n,
                            style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.045),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              if (selectedType == 'Bitcoin') const BitcoinWidget(),
              if (selectedType == 'Liquid') const LiquidWidget(),
              if (selectedType == 'Lightning') const CustodialLightningWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
