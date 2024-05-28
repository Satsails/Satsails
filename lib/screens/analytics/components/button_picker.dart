import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_button/group_button.dart';
import 'package:Satsails/providers/transaction_type_show_provider.dart';

final selectedButtonProvider = StateProvider.autoDispose<String>((ref) => "Bitcoin");
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
            ref.read(selectedButtonProvider.notifier).state = "Bitcoin";
            ref.read(transactionTypeShowProvider.notifier).state = "Bitcoin";
            break;
          case 1:
            ref.read(selectedButtonProvider.notifier).state = "Instant Bitcoin";
            ref.read(transactionTypeShowProvider.notifier).state = "Liquid";
            break;
          case 2:
            ref.read(selectedButtonProvider.notifier).state = "Swap";
            ref.read(transactionTypeShowProvider.notifier).state = "Swap";
            break;
          default:
            ref.read(selectedButtonProvider.notifier).state = "Bitcoin";
            ref.read(transactionTypeShowProvider.notifier).state = "Bitcoin";
        }
      },
      buttons: ["Bitcoin", "Instant Bitcoin".i18n(ref), 'Swaps'.i18n(ref)],
      options: GroupButtonOptions(
        unselectedTextStyle: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black), // 3% of screen width
        selectedTextStyle: TextStyle(fontSize: screenWidth * 0.03, color: Colors.white), // 3% of screen width
        selectedColor: Colors.deepOrange,
        spacing: screenWidth * 0.01, // 1% of screen width
        mainGroupAlignment: MainGroupAlignment.center,
        crossGroupAlignment: CrossGroupAlignment.center,
        groupRunAlignment: GroupRunAlignment.center,
        unselectedColor: Colors.white,
        groupingType: GroupingType.wrap,
        alignment: Alignment.center,
        elevation: 0,
        textPadding: EdgeInsets.zero,
        selectedShadow: <BoxShadow>[
          const BoxShadow(color: Colors.transparent)
        ],
        unselectedShadow: <BoxShadow>[
          const BoxShadow(color: Colors.transparent)
        ],
        borderRadius: BorderRadius.circular(screenWidth * 0.075), // 7.5% of screen width
      ),
    );
  }
}