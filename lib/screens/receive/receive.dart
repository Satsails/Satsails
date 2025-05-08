import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/receive/components/bitcoin_widget.dart';
import 'package:Satsails/screens/receive/components/receive_spark_lightning_widget.dart';
import 'package:Satsails/screens/receive/components/liquid_widget.dart';
import 'package:Satsails/screens/receive/receive_non_native_asset.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';

class Receive extends ConsumerWidget {
  const Receive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedNetworkTypeProvider);
    final shiftPair = ref.watch(selectedShiftPairProvider);

    Future.microtask(() => {ref.read(shouldUpdateMemoryProvider.notifier).state = false});

    return WillPopScope(
      onWillPop: () async {
        try {
          ref.read(inputAmountProvider.notifier).state = '0.0';
          ref.invalidate(initialCoinosProvider);
          return true;
        } catch (e) {
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            shiftPair != null && selectedType == 'SideShift'
                ? 'Receive non native asset'.i18n
                : 'Receive on $selectedType'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 20.sp),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              ref.read(inputAmountProvider.notifier).state = '0.0';
              ref.invalidate(initialCoinosProvider);
              context.pop();
            },
          ),
        ),
        body: KeyboardDismissOnTap(
          child: ListView(
            children: [
              if (selectedType == 'Bitcoin Network') const BitcoinWidget()
              else if (selectedType == 'Liquid Network') const LiquidWidget()
              else if (selectedType == 'Spark Network') const ReceiveSparkLightningWidget()
                else if (selectedType == 'SideShift') const ReceiveNonNativeAsset(),
            ],
          ),
        ),
      ),
    );
  }
}