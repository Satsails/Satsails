import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_button/group_button.dart';

final selectedButtonProvider = StateProvider.autoDispose<String>((ref) => "Complete Receiving");
final groupButtonControllerProvider = Provider.autoDispose<GroupButtonController>((ref) {
  return GroupButtonController(selectedIndex: 0);
});

class BoltzButtonPicker extends ConsumerWidget {
  const BoltzButtonPicker({super.key});

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
            ref.read(selectedButtonProvider.notifier).state = "Complete Receiving";
            break;
          case 1:
            ref.read(selectedButtonProvider.notifier).state = "Complete Sending";
            break;
          default:
            ref.read(selectedButtonProvider.notifier).state = "Complete Receiving";
        }
      },
      buttons: ["Complete Receiving".i18n(ref), 'Complete Sending'.i18n(ref)],
      options: GroupButtonOptions(
        unselectedTextStyle: TextStyle(
            fontSize: screenWidth * 0.03, color: Colors.black),
        selectedTextStyle: TextStyle(
            fontSize: screenWidth * 0.03, color: Colors.white),
        selectedColor: Colors.deepOrange,
        mainGroupAlignment: MainGroupAlignment.center,
        spacing: screenWidth * 0.005, // 0.5% of screen width
        crossGroupAlignment: CrossGroupAlignment.center,
        groupRunAlignment: GroupRunAlignment.center,
        unselectedColor: Colors.white,
        groupingType: GroupingType.row,
        alignment: Alignment.center,
        elevation: 0,
        textPadding: EdgeInsets.zero,
        selectedShadow: <BoxShadow>[
          const BoxShadow(color: Colors.transparent)
        ],
        unselectedShadow: <BoxShadow>[
          const BoxShadow(color: Colors.transparent)
        ],
        borderRadius: BorderRadius.circular(screenWidth * 0.075),
      ),
    );
  }
}