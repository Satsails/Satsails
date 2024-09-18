import 'package:Satsails/screens/receive/components/bitcoin_widget.dart';
import 'package:Satsails/screens/receive/components/lightning_widget.dart';
import 'package:Satsails/screens/receive/components/liquid_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_button/group_button.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/providers/address_receive_provider.dart';

final selectedButtonProvider = StateProvider.autoDispose<String>((ref) => "Bitcoin");
final FocusNode _focusNode = FocusNode();

class Receive extends ConsumerWidget {
  Receive({super.key});
  final groupButtonControllerProvider = Provider<GroupButtonController>((ref) {
    return GroupButtonController(selectedIndex: 1);
  });


  KeyboardActionsConfig _buildKeyboardActionsConfig() {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
                (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

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
        title: Text('Receive'.i18n(ref), style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenHeight * 0.03, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(inputAmountProvider.notifier).state = '0.0';
          },
        ),
      ),
      body: KeyboardActions(
        config: _buildKeyboardActionsConfig(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GroupButton(
                isRadio: true,
                controller: controller,
                onSelected: (value, index, isSelected) {
                  ref.read(selectedButtonProvider.notifier).state = value;
                  ref.read(inputCurrencyProvider.notifier).state = 'BTC';
                  ref.read(inputAmountProvider.notifier).state = '0.0';
                  ref.read(isBitcoinInputProvider.notifier).state = true;
                },
                buttons: const ['Lightning', 'Bitcoin', 'Liquid'],
                options: GroupButtonOptions(
                  unselectedTextStyle: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.orange,
                  ),
                  selectedTextStyle: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.black,
                  ),
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
                  selectedShadow: const <BoxShadow>[
                    BoxShadow(color: Colors.transparent)
                  ],
                  unselectedShadow: const <BoxShadow>[
                    BoxShadow(color: Colors.transparent)
                  ],
                  borderRadius: BorderRadius.circular(screenWidth * 0.01),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              if (selectedIndex == 'Bitcoin')
                BitcoinWidget(focusNode: _focusNode),
              if (selectedIndex == "Liquid")
                LiquidWidget(focusNode: _focusNode),
              if (selectedIndex == "Lightning")
                LightningWidget(focusNode: _focusNode),
            ],
          ),
        ),
      ),
    );
  }
}
