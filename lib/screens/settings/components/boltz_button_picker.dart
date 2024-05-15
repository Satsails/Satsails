import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_button/group_button.dart';

final selectedButtonProvider = StateProvider.autoDispose<String>((ref) => "Claim Receiving");
final groupButtonControllerProvider = Provider.autoDispose<GroupButtonController>((ref) {
  return GroupButtonController(selectedIndex: 0);
});

class BoltzButtonPicker extends ConsumerWidget {
  const BoltzButtonPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(groupButtonControllerProvider);

    return GroupButton(
      isRadio: true,
      controller: controller,
      onSelected: (index, isSelected, isLongPress) {
        switch (isSelected) {
          case 0:
            ref.read(selectedButtonProvider.notifier).state = "Claim Receiving";
            break;
          case 1:
            ref.read(selectedButtonProvider.notifier).state = "Refund Sending";
            break;
          default:
            ref.read(selectedButtonProvider.notifier).state = "Claim Receiving";
        }
      },
      buttons: ["Claim Receiving".i18n(ref), 'Refund Sending'.i18n(ref)],
      options: GroupButtonOptions(
        unselectedTextStyle: const TextStyle(
            fontSize: 13, color: Colors.black),
        selectedTextStyle: const TextStyle(
            fontSize: 13, color: Colors.white),
        selectedColor: Colors.deepOrange,
        mainGroupAlignment: MainGroupAlignment.center,
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
        borderRadius: BorderRadius.circular(30.0),
      ),
    );
  }
}