import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LiquidWidget extends ConsumerWidget {
  const LiquidWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liquidAddressAsyncValue = ref.watch(liquidReceiveAddressAmountProvider);
    return liquidAddressAsyncValue.when(
      data: (liquidAddress) {
        return Column(
          children: [
            buildQrCode(liquidAddress, context),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildAddressText(liquidAddress, context, ref),
            ),
            const AmountInput()
          ],
        );
      },
      loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: MediaQuery.of(context).size.width * 0.6, color: Colors.orange)),
      error: (error, stack) => Center(child: LoadingAnimationWidget.threeArchedCircle(size: MediaQuery.of(context).size.width * 0.6, color: Colors.orange)),
    );
  }
}