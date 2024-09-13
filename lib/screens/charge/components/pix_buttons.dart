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
            ref.read(topSelectedButtonProvider.notifier).state = "History";
            break;
          default:
            ref.read(topSelectedButtonProvider.notifier).state = "Pix Address";
        }
      },
      buttons: ["Pix Address".i18n(ref), "History".i18n(ref)],
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
    );
  }
}