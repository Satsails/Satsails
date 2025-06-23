import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/receive/components/bitcoin_widget.dart';
import 'package:Satsails/screens/receive/components/receive_boltz.dart';
import 'package:Satsails/screens/receive/components/receive_non_native_asset.dart';
import 'package:Satsails/screens/receive/components/receive_spark_lightning_widget.dart';
import 'package:Satsails/screens/receive/components/liquid_widget.dart';
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
          centerTitle: false,
          title: Text(
            getReceiveTitle(selectedType, shiftPair),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: selectedType == 'SideShift' || selectedType == 'Boltz Network' ? 15.sp : 22.sp,
            ),
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
              else if (selectedType == 'Boltz Network') const ReceiveBoltz()
                else if (selectedType == 'SideShift') const ReceiveNonNativeAsset(),
            ],
          ),
        ),
      ),
    );
  }

  String getReceiveTitle(String selectedType, ShiftPair? shiftPair) {
    if (selectedType == 'Boltz Network') {
      return 'Receive Liquid Bitcoin on Lightning Network'.i18n;
    } else if (shiftPair != null && selectedType == 'SideShift') {
      return _getShiftPairDisplayName(shiftPair).i18n;
    } else {
      return 'Receive on $selectedType'.i18n;
    }
  }

  String _getShiftPairDisplayName(ShiftPair pair) {
    switch (pair) {
      case ShiftPair.usdtTronToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Tron';
      case ShiftPair.usdtBscToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on BSC';
      case ShiftPair.usdtEthToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Ethereum';
      case ShiftPair.usdtSolToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Solana';
      case ShiftPair.usdtPolygonToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Polygon';
      case ShiftPair.usdcEthToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on Ethereum';
      case ShiftPair.usdcTronToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on Tron';
      case ShiftPair.usdcBscToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on BSC';
      case ShiftPair.usdcSolToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on Solana';
      case ShiftPair.usdcPolygonToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on Polygon';
      case ShiftPair.ethToLiquidBtc:
        return 'Receive Liquid BTC from ETH';
      case ShiftPair.trxToLiquidBtc:
        return 'Receive Liquid BTC from TRX';
      case ShiftPair.bnbToLiquidBtc:
        return 'Receive Liquid BTC from BNB';
      case ShiftPair.solToLiquidBtc:
        return 'Receive Liquid BTC from SOL';
      case ShiftPair.btcToLiquidBtc:
        return 'Receive Liquid BTC from Bitcoin';
      case ShiftPair.usdtArbitrumToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Arbitrum';

      default:
        return 'Receive ${pair.toString().split('.').last}';
    }
  }
}