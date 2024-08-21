import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_button/group_button.dart';
import 'package:Satsails/providers/send_tx_provider.dart';

final selectedButtonProvider = StateProvider.autoDispose<String>((ref) => "Bitcoin Layer Swap");
final groupButtonControllerProvider = Provider.autoDispose<GroupButtonController>((ref) {
  return GroupButtonController(selectedIndex: 0);
});

class ButtonPicker extends ConsumerWidget {
  const ButtonPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final controller = ref.watch(groupButtonControllerProvider);

    return GroupButton(
      isRadio: true,
      controller: controller,
      onSelected: (index, isSelected, isLongPress) {
        switch (isSelected) {
          case 0:
            ref.read(sendTxProvider.notifier).updateAddress('');
            ref.read(sendTxProvider.notifier).updateAmount(0);
            ref.read(sendBlocksProvider.notifier).state = 1;
            ref.read(selectedButtonProvider.notifier).state = "Bitcoin Layer Swap";
            break;
          case 1:
            ref.read(sendTxProvider.notifier).updateAddress('');
            ref.read(sendTxProvider.notifier).updateAmount(0);
            ref.read(sendBlocksProvider.notifier).state = 1;
            ref.read(selectedButtonProvider.notifier).state = "Swap";
            break;
          default:
            ref.read(sendTxProvider.notifier).updateAddress('');
            ref.read(sendTxProvider.notifier).updateAmount(0);
            ref.read(sendBlocksProvider.notifier).state = 1;
            ref.read(selectedButtonProvider.notifier).state = "Bitcoin Layer Swap";
        }
      },
      buttons: ["BTC ⇄ Liquid".i18n(ref), 'Liquid ⇄ Stable'.i18n(ref)],
      options: GroupButtonOptions(
        unselectedTextStyle: TextStyle(
            fontSize: screenWidth * 0.04, color: Colors.orange), // 4% of screen width
        selectedTextStyle: TextStyle(
            fontSize: screenWidth * 0.04, color: Colors.black), // 4% of screen width
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
        borderRadius: BorderRadius.circular(screenWidth * 0.01), // 7.5% of screen width
      ),
    );
  }
}