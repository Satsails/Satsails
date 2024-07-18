import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_button/group_button.dart';

final topSelectedButtonProvider = StateProvider<String>((ref) => "Pix Address");
final groupButtonControllerProvider = Provider<GroupButtonController>((ref) {
  return GroupButtonController(selectedIndex: 0);
});

class PixButtons extends ConsumerWidget {
  const PixButtons({super.key});

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
            ref.read(topSelectedButtonProvider.notifier).state = "Pix Address";
            break;
          case 1:
            ref.read(topSelectedButtonProvider.notifier).state = "Check Pix Transactions";
            break;
          default:
            ref.read(topSelectedButtonProvider.notifier).state = "Pix Address";
        }
      },
      buttons: ["Pix Address".i18n(ref), "Check Pix Transactions".i18n(ref)],
      options: GroupButtonOptions(
        unselectedTextStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black),
        selectedTextStyle: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white),
        selectedColor: Colors.deepOrange,
        spacing: screenWidth * 0.005, // 1% of screen width
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
        borderRadius: BorderRadius.circular(screenWidth * 0.075),
      ),
    );
  }
}