import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LiquidWidget extends ConsumerWidget {
  const LiquidWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liquidAddressAsyncValue = ref.watch(liquidReceiveAddressAmountProvider);
    final height = MediaQuery.of(context).size.height;
    final TextEditingController controller = TextEditingController();

    return liquidAddressAsyncValue.when(
      data: (liquidAddress) {
        return Column(
          children: [
            AmountInput(controller: controller),
            buildQrCode(liquidAddress, context),
            Padding(
              padding: EdgeInsets.all(height * 0.01),
              child: buildAddressText(liquidAddress, context, ref),
            ),
            Padding(
              padding: EdgeInsets.all(height * 0.01),
              child: CustomElevatedButton(
                onPressed: () {
                  String inputValue = controller.text;
                  ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;
                },
                text: 'Create Address'.i18n(ref),
                controller: controller,
              ),
            ),
          ],
        );
      },
      loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: MediaQuery.of(context).size.width * 0.6, color: Colors.orange)),
      error: (error, stack) => Center(child: LoadingAnimationWidget.threeArchedCircle(size: MediaQuery.of(context).size.width * 0.6, color: Colors.orange)),
    );
  }
}
