import 'package:Satsails/screens/receive/components/bitcoin_widget.dart';
import 'package:Satsails/screens/receive/components/lightning_widget.dart';
import 'package:Satsails/screens/receive/components/liquid_widget.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:group_button/group_button.dart';

final selectedButtonProvider = StateProvider.autoDispose<String>((ref) => "Bitcoin");

class Receive extends ConsumerWidget {
  Receive({super.key});

  final groupButtonControllerProvider = Provider<GroupButtonController>((ref) {
    return GroupButtonController(selectedIndex: 1);
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final selectedIndex = ref.watch(selectedButtonProvider);
    final controller = ref.watch(groupButtonControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Receive'.i18n(ref), style: TextStyle(fontSize: screenHeight * 0.03, color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenHeight * 0.03, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(inputAmountProvider.notifier).state = '0.0';
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GroupButton(
              isRadio: true,
              controller: controller,
              onSelected: (index, isSelected, isLongPress) {
                switch (index) {
                  case 'Bitcoin':
                    ref.read(selectedButtonProvider.notifier).state = "Bitcoin";
                    ref.read(inputCurrencyProvider.notifier).state = 'BTC';
                    ref.read(inputAmountProvider.notifier).state = '0.0';
                    break;
                  case 'Liquid':
                    ref.read(selectedButtonProvider.notifier).state = "Liquid";
                    ref.read(inputCurrencyProvider.notifier).state = 'BTC';
                    ref.read(inputAmountProvider.notifier).state = '0.0';
                    break;
                  case 'Lightning':
                    ref.read(selectedButtonProvider.notifier).state = "Lightning";
                    ref.read(inputCurrencyProvider.notifier).state = 'BTC';
                    ref.read(inputAmountProvider.notifier).state = '0.0';
                    break;
                  default:
                    'Bitcoin';
                }
              },
              buttons: const ["Lightning", 'Bitcoin', "Liquid"],
              options: GroupButtonOptions(
                unselectedTextStyle: TextStyle(
                    fontSize: screenWidth * 0.04, color: Colors.orange),
                selectedTextStyle: TextStyle(
                    fontSize: screenWidth * 0.04, color: Colors.black),
                selectedColor: Colors.orange,
                mainGroupAlignment: MainGroupAlignment.center,
                crossGroupAlignment: CrossGroupAlignment.center,
                groupRunAlignment: GroupRunAlignment.center,
                unselectedColor: Colors.black,
                groupingType: GroupingType.row,
                alignment: Alignment.center,
                elevation: 0,
                textPadding: EdgeInsets.zero,
                unselectedBorderColor: Colors.orange,
                selectedShadow: <BoxShadow>[
                  const BoxShadow(color: Colors.transparent)
                ],
                unselectedShadow: <BoxShadow>[
                  const BoxShadow(color: Colors.transparent)
                ],
                borderRadius: BorderRadius.circular(screenWidth * 0.01),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 2% of screen height
            if (selectedIndex == 'Bitcoin')
              const BitcoinWidget(),
            if (selectedIndex == "Liquid")
              const LiquidWidget(),
            if (selectedIndex == "Lightning")
              const LightningWidget(),
          ],
        ),
      ),
    );
  }
}