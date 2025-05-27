import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum SwapType {
  sideswapBtcToLbtc,
  sideswapLbtcToBtc,
  coinosLnToBTC,
  coinosLnToLBTC,
  coinosBtcToLn,
  coinosLbtcToLn,
  sideswapUsdtToLbtc,
  sideswapEuroxToLbtc,
  sideswapDepixToLbtc,
  sideswapLbtcToUsdt,
  sideswapLbtcToEurox,
  sideswapLbtcToDepix,
  sideswapEuroxToUsdt,
  sideswapUsdtToEurox,
  sideswapUsdtToDepix,
  sideswapDepixToUsdt,

}

const List<SwapType> fiatDisplayAllowedSwapTypes = [
  SwapType.sideswapLbtcToUsdt,
  SwapType.sideswapLbtcToEurox,
  SwapType.sideswapLbtcToDepix,
  SwapType.sideswapBtcToLbtc,
  SwapType.sideswapLbtcToBtc,
  SwapType.coinosLnToBTC,
  SwapType.coinosLnToLBTC,
  SwapType.coinosBtcToLn,
  SwapType.coinosLbtcToLn,
  SwapType.sideswapEuroxToUsdt,
  SwapType.sideswapUsdtToEurox,
  SwapType.sideswapUsdtToDepix,
  SwapType.sideswapDepixToUsdt,
];

const List<String> fiatAssets = [
  'USDT',
  'Eurox',
  'Depix',
];


List<String> getAssets(WidgetRef ref) {
  // this is hardcoded to false until we have spark
  final lightningAvailable = false; // Replace with actual logic to check if Lightning is available

  return [
    'Bitcoin',
    if (lightningAvailable) 'Lightning',
    'L-BTC',
    'USDT',
    'Eurox',
    'Depix'
  ];
}

final swapTypeProvider = StateProvider.autoDispose<SwapType?>((ref) {
  final fromAsset = ref.watch(fromAssetProvider);
  final toAsset = ref.watch(toAssetProvider);
  final combinedKey = '$fromAsset-$toAsset';

  switch (combinedKey) {
    case 'Bitcoin-L-BTC':
      return SwapType.sideswapBtcToLbtc;

    case 'L-BTC-Bitcoin':
      return SwapType.sideswapLbtcToBtc;

    case 'Lightning-Bitcoin':
      return SwapType.coinosLnToBTC;

    case 'Lightning-L-BTC':
      return SwapType.coinosLnToLBTC;

    case 'USDT-L-BTC':
      return SwapType.sideswapUsdtToLbtc;

    case 'Eurox-L-BTC':
      return SwapType.sideswapEuroxToLbtc;

    case 'Depix-L-BTC':
      return SwapType.sideswapDepixToLbtc;

    case 'L-BTC-USDT':
      return SwapType.sideswapLbtcToUsdt;

    case 'L-BTC-Eurox':
      return SwapType.sideswapLbtcToEurox;

    case 'L-BTC-Depix':
      return SwapType.sideswapLbtcToDepix;

    case 'USDT-Depix':
      return SwapType.sideswapUsdtToDepix;

    case 'Depix-USDT':
      return SwapType.sideswapDepixToUsdt;

    case 'Eurox-USDT':
      return SwapType.sideswapEuroxToUsdt;

    case 'USDT-Eurox':
      return SwapType.sideswapUsdtToEurox;


    default:
      return null;
  }
});

class SwapTypeNotifier extends StateNotifier<void> {
  SwapTypeNotifier(this.ref) : super(null);

  final Ref ref;

  void updateProviders(SwapType? swapType) {
    if (swapType == null) return;

    // Default settings for all swaps
    ref.read(inputInFiatProvider.notifier).state = false;
    ref.read(pegOutBlocksProvider.notifier).state = 2;

    switch (swapType) {
      case SwapType.sideswapUsdtToLbtc:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.USD);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.sideswapUsdtToDepix:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.USD);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.BRL);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = true;
        break;

      case SwapType.sideswapUsdtToEurox:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.USD);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.EUR);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = true;
        break;

      case SwapType.sideswapEuroxToLbtc:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.EUR);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.EUR));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.sideswapEuroxToUsdt:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.EUR);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.USD);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.EUR));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = true;
        break;

      case SwapType.sideswapDepixToLbtc:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.BRL);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.BRL));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.sideswapDepixToUsdt:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.BRL);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.USD);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.BRL));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = true;
        break;

      case SwapType.sideswapLbtcToUsdt:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.USD);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.sideswapLbtcToEurox:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.EUR);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.sideswapLbtcToDepix:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.BRL);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.sideswapBtcToLbtc:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(pegInProvider.notifier).state = true;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.sideswapLbtcToBtc:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(pegInProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.coinosLnToBTC:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.coinosLnToLBTC:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.coinosBtcToLn:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;

      case SwapType.coinosLbtcToLn:
        ref.read(assetToSellProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(assetToPurchaseProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(fiatToFiatSwap.notifier).state = false;
        break;
    }
  }
}


final swapTypeNotifierProvider = StateNotifierProvider.autoDispose<SwapTypeNotifier, void>((ref) {
  return SwapTypeNotifier(ref);
});


final balanceFromAssetProvider = StateProvider.autoDispose<String>((ref) {
  final fromAsset = ref.watch(swapTypeProvider);
  final balance = ref.watch(balanceNotifierProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;

  switch (fromAsset) {
    case SwapType.sideswapBtcToLbtc:
    case SwapType.coinosBtcToLn:
      return btcInDenominationFormatted(balance.btcBalance, btcFormat);
    case SwapType.sideswapLbtcToBtc:
    case SwapType.coinosLbtcToLn:
    case SwapType.sideswapLbtcToDepix:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToUsdt:
      return btcInDenominationFormatted(balance.liquidBalance, btcFormat);
    case SwapType.coinosLnToBTC:
    case SwapType.coinosLnToLBTC:
      return btcInDenominationFormatted(balance.lightningBalance!.toInt(), btcFormat);
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapUsdtToDepix:
    case SwapType.sideswapUsdtToEurox:
      return fiatInDenominationFormatted(balance.usdBalance);
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapEuroxToUsdt:
      return fiatInDenominationFormatted(balance.eurBalance);
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapDepixToUsdt:
      return fiatInDenominationFormatted(balance.brlBalance);
    default:
      return '0';
  }
});


List<String> getAvailableSwaps(String asset, WidgetRef ref) {
  // this is hardcoded to false until we have spark
  final lightningAvailable = false;

  switch (asset) {
    case 'Bitcoin':
      return ['L-BTC'];
    case 'L-BTC':
      return ['USDT', 'Depix', 'Eurox', 'Bitcoin'];
    case 'Lightning':
      return [];
    case 'USDT':
      return ['Depix', 'Eurox', 'L-BTC'];
    case 'Eurox':
      return ['USDT', 'L-BTC'];
    case 'Depix':
      return ['USDT', 'L-BTC'];
    default:
      return [];
  }
}

Widget getAssetImage(String? asset, {double? width, double? height}) {
  if (asset == null) return Container();

  switch (asset) {
    case 'Bitcoin':
      return Image.asset('lib/assets/bitcoin-logo.png', width: width ?? 28.0.sp, height: height ?? 28.0.sp);
    case 'Liquid Bitcoin':
    case 'L-BTC':
    case 'LBTC':
      return Image.asset('lib/assets/l-btc.png', width: width ?? 28.0.sp, height: height ?? 28.0.sp);
    case 'USDT':
      return Image.asset('lib/assets/tether.png', width: width ?? 28.0.sp, height: height ?? 28.0.sp);
    case 'Eurox':
    case 'EUROX':
    case 'EURx':
      return Image.asset('lib/assets/eurx.png', width: width ?? 28.0.sp, height: height ?? 28.0.sp);
    case 'Depix':
    case 'DEPIX':
      return Image.asset('lib/assets/depix.png', width: width ?? 28.0.sp, height: height ?? 28.0.sp);
    case 'Lightning':
    case 'Lightning Bitcoin':
      return Image.asset('lib/assets/Bitcoin_lightning_logo.png', width: width ?? 28.0.sp, height: height ?? 28.0.sp);
    default:
      return Image.asset('lib/assets/app_icon.png', width: width ?? 28.0.sp, height: height ?? 28.0.sp);
  }
}

final transactionInProgressProvider = StateProvider.autoDispose<bool>((ref) => false);
final fromAssetProvider = StateProvider.autoDispose<String>((ref) => 'Depix');
final fiatToFiatSwap = StateProvider.autoDispose<bool>((ref) =>  false);
final toAssetProvider = StateProvider.autoDispose<String>((ref) => 'L-BTC');
final inputInFiatProvider = StateProvider.autoDispose<bool>((ref) => false);
final bitcoinReceiveSpeedProvider = StateProvider.autoDispose<String>((ref) => 'Fastest');
final precisionFiatValueProvider = StateProvider.autoDispose<String>((ref) => "0.00");
final pegFee = StateProvider.autoDispose<String>((ref) => "0");
final networkFee = StateProvider.autoDispose<String>((ref) => "0");
final providerFee = StateProvider.autoDispose<String>((ref) => "0");

Widget bitcoinFeeSlider(WidgetRef ref) {
  final feeRateAsyncValue = ref.watch(bitcoinFeeRatePerBlockProvider);

  return Column(
    children: [
      Slider(
        value: 6 - ref.watch(sendBlocksProvider).toDouble(),
        onChanged: (value) => ref.read(sendBlocksProvider.notifier).state = 6 - value,
        min: 1,
        max: 5,
        divisions: 4,
        activeColor: Colors.orange,
      ),
      feeRateAsyncValue.when(
        data: (feeRate) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _simpleFeeText("Weeks", feeRate.minimumFee, ref),
              _simpleFeeText("Days", feeRate.economyFee, ref),
              _simpleFeeText("60 min", feeRate.hourFee, ref),
              _simpleFeeText("30 min", feeRate.halfHourFee, ref),
              _simpleFeeText("10 min", feeRate.fastestFee, ref),
            ],
          );
        },
        loading: () => Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            size: 20.w,
            color: Colors.white,
          ),
        ),
        error: (e, _) => Text(
          'Error',
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
      ),
    ],
  );
}

Widget _simpleFeeText(String label, double fee, WidgetRef ref) {
  final wholeFee = fee.toInt();

  return Column(
    children: [
      Text(
        label.i18n,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      SizedBox(height: 2.h),
      Text(
        "$wholeFee sat/vB",
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

Widget buildBalanceCardWithMaxButton(WidgetRef ref, TextEditingController controller) {
  final balance = ref.watch(balanceFromAssetProvider);
  final swapType = ref.watch(swapTypeProvider)!;
  final btcFormat = ref.watch(settingsProvider).btcFormat;

  return Padding(
    padding: EdgeInsets.only(top: 8.0.w),
    child: SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color(0x00333333).withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Balance Text
              Text(
                balance,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Max Button
              TextButton(
                onPressed: () async {
                  await handleMaxButtonPress(ref, swapType, controller, btcFormat);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Max',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> handleMaxButtonPress(
    WidgetRef ref,
    SwapType swapType,
    TextEditingController controller,
    String btcFormat,
    ) async {
  int balance;

  switch (swapType) {
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapUsdtToDepix:
    case SwapType.sideswapUsdtToEurox:
      balance = ref.read(balanceNotifierProvider).usdBalance;
      controller.text = fiatInDenominationFormatted(balance);
      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
      ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
      ref.read(sendTxProvider.notifier).updateDrain(true);
      break;

    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapEuroxToUsdt:
      balance = ref.read(balanceNotifierProvider).eurBalance;
      controller.text = fiatInDenominationFormatted(balance);
      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.EUR));
      ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
      ref.read(sendTxProvider.notifier).updateDrain(true);
      break;

    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapDepixToUsdt:
      balance = ref.read(balanceNotifierProvider).brlBalance;
      controller.text = fiatInDenominationFormatted(balance);
      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.BRL));
      ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
      ref.read(sendTxProvider.notifier).updateDrain(true);
      break;

    case SwapType.sideswapLbtcToDepix:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToUsdt:
      balance = ref.read(balanceNotifierProvider).liquidBalance;
      controller.text = btcInDenominationFormatted(balance.toDouble(), btcFormat);
      ref.read(inputInFiatProvider.notifier).state = false;
      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
      ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
      ref.read(sendTxProvider.notifier).updateDrain(true);
      break;

    case SwapType.sideswapBtcToLbtc:
      await handlePegIn(ref, controller, btcFormat);
      break;

    case SwapType.sideswapLbtcToBtc:
      await handlePegOut(ref, controller, btcFormat);
      break;
    case SwapType.coinosLnToBTC:
      await handleLightningToAsset(ref, controller, btcFormat);
      break;
    case SwapType.coinosLnToLBTC:
      await handleLightningToAsset(ref, controller, btcFormat);
      break;
    case SwapType.coinosBtcToLn:
      await handleBitcoinToLightning(ref, controller, btcFormat);
      break;
    case SwapType.coinosLbtcToLn:
      await handleLiquidBitcoinToLightning(ref, controller, btcFormat);
      break;

    default:
      throw UnsupportedError('Unsupported SwapType: $swapType');
  }
}

Future<void> handlePegIn(
    WidgetRef ref,
    TextEditingController controller,
    String btcFormat,
    ) async {
  final bitcoin = ref.watch(balanceNotifierProvider).btcBalance;
  ref.read(pegInProvider.notifier).state = true;
  final peg = await ref.watch(sideswapPegProvider.future);

  ref.read(inputInFiatProvider.notifier).state = false;
  ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');

  final transactionBuilderParams = await ref
      .watch(bitcoinTransactionBuilderProvider(ref.watch(sendTxProvider).amount).future)
      .then((value) => value);
  final transaction = await ref
      .watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilderParams).future)
      .then((value) => value);

  final fee = (transaction.$1.feeAmount() ?? BigInt.zero).toInt();
  final amountToSet = (bitcoin - fee);

  controller.text = btcInDenominationFormatted(amountToSet.toDouble(), btcFormat);
  ref.read(sendTxProvider.notifier).updateAmountFromInput(amountToSet.toString(), 'sats');
  ref.read(sendTxProvider.notifier).updateDrain(true);
}

Future<void> handlePegOut(
    WidgetRef ref,
    TextEditingController controller,
    String btcFormat,
    ) async {
  final liquid = ref.watch(balanceNotifierProvider).liquidBalance;
  ref.read(pegInProvider.notifier).state = false;
  final peg = await ref.watch(sideswapPegProvider.future);

  ref.read(inputInFiatProvider.notifier).state = false;
  ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');

  controller.text = btcInDenominationFormatted(liquid.toDouble(), btcFormat);
  ref.read(sendTxProvider.notifier).updateDrain(true);
  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
}

Future<void> handleLightningToAsset(WidgetRef ref, TextEditingController controller, String btcFormat) async {
  ref.read(inputInFiatProvider.notifier).state = false;
  final balance = ref.read(balanceNotifierProvider).lightningBalance;
  int maxAmount = (balance! * 0.995).toInt();
  controller.text = btcInDenominationFormatted(maxAmount, btcFormat);
  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
}

Future<void> handleBitcoinToLightning(WidgetRef ref, TextEditingController controller, String btcFormat) async {
  ref.read(inputInFiatProvider.notifier).state = false;
  final balance = ref.read(balanceNotifierProvider).btcBalance;
  final address = await ref.read(createInvoiceForSwapProvider('bitcoin').future);
  ref.read(sendTxProvider.notifier).updateAddress(address);

  final transactionBuilderParams =
  await ref.watch(bitcoinTransactionBuilderProvider(balance).future).then((value) => value);
  final transaction =
  await ref.watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilderParams).future).then((value) => value);

  final fee = (transaction.$1.feeAmount() ?? BigInt.zero).toInt();
  final amountToSet = (balance - fee);
  controller.text = btcInDenominationFormatted(amountToSet, btcFormat);
  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
}

Future<void> handleLiquidBitcoinToLightning(WidgetRef ref, TextEditingController controller, String btcFormat) async {
  ref.read(inputInFiatProvider.notifier).state = false;
  final address = await ref.read(createInvoiceForSwapProvider('liquid').future);
  ref.read(sendTxProvider.notifier).updateAddress(address);
  ref.read(sendTxProvider.notifier).updateDrain(true);

  final pset = await ref.watch(liquidDrainWalletProvider.future);
  final sendingBalance = pset.balances[0].value + pset.absoluteFees.toInt();
  final controllerValue = sendingBalance.abs();
  controller.text = btcInDenominationFormatted(controllerValue, btcFormat);
  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
}


Widget buildExchangeCard(BuildContext context, WidgetRef ref, TextEditingController controller) {
  final fromAsset = ref.watch(fromAssetProvider);
  final toAsset = ref.watch(toAssetProvider);

  return Card(
    color: const Color(0x00333333).withOpacity(0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: EdgeInsets.all(12.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From Asset'.i18n,
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 12.h), // Increased from 8.h
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: fromAsset,
                      dropdownColor: const Color(0xFF212121),
                      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                      items: getAssets(ref)
                          .where((asset) => asset != toAsset)
                          .map((asset) => DropdownMenuItem(
                        value: asset,
                        child: Row(
                          children: [
                            getAssetImage(asset),
                            SizedBox(width: 8.w),
                            Text(
                              asset,
                              style: TextStyle(color: Colors.white, fontSize: 16.sp),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.text = '';
                          ref.read(sendTxProvider.notifier).resetToDefault();
                          ref.read(sendBlocksProvider.notifier).state = 1;
                          ref.read(fromAssetProvider.notifier).state = value;
                          final availableSwaps = getAvailableSwaps(value, ref)
                              .where((swap) => swap != value)
                              .toList();
                          if (!availableSwaps.contains(toAsset)) {
                            ref.read(toAssetProvider.notifier).state = availableSwaps.first;
                          }
                          ref.read(swapTypeNotifierProvider.notifier).updateProviders(ref.watch(swapTypeProvider));
                        }
                      },
                      icon: Padding(
                        padding: EdgeInsets.only(left: 8.0.w),
                        child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ),
                      isDense: true,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(8.0.w),
                child: assetLogic(ref, context, controller, receiveAsset: false),
              ),
            ],
          ),
          SizedBox(height: 24.h), // Increased from 14.h
          Row(
            children: [
              SizedBox(width: 24.w), // Increased from 16.w
              const Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              SizedBox(width: 24.w), // Increased from 16.w
              GestureDetector(
                onTap: () {
                  controller.text = '';
                  ref.read(sendTxProvider.notifier).resetToDefault();
                  ref.read(sendBlocksProvider.notifier).state = 1;
                  final temp = ref.read(fromAssetProvider);
                  ref.read(fromAssetProvider.notifier).state = ref.read(toAssetProvider);
                  ref.read(toAssetProvider.notifier).state = temp;
                  ref.read(swapTypeNotifierProvider.notifier).updateProviders(ref.watch(swapTypeProvider));
                },
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h), // Added new spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To Asset'.i18n,
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 12.h), // Increased from 8.h
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: toAsset,
                      dropdownColor: const Color(0xFF212121),
                      borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                      items: getAvailableSwaps(fromAsset, ref)
                          .where((asset) => asset != fromAsset)
                          .map((asset) => DropdownMenuItem(
                        value: asset,
                        child: Row(
                          children: [
                            getAssetImage(asset),
                            SizedBox(width: 8.w),
                            Text(
                              asset,
                              style: TextStyle(color: Colors.white, fontSize: 16.sp),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(sendTxProvider.notifier).resetToDefault();
                          ref.read(sendBlocksProvider.notifier).state = 1;
                          controller.text = '';
                          ref.read(toAssetProvider.notifier).state = value;
                          final availableSwaps = getAssets(ref).where((swap) => swap != value).toList();
                          if (!availableSwaps.contains(fromAsset)) {
                            ref.read(fromAssetProvider.notifier).state = availableSwaps.first;
                          }
                          ref.read(swapTypeNotifierProvider.notifier).updateProviders(ref.watch(swapTypeProvider));
                        }
                      },
                      icon: Padding(
                        padding: EdgeInsets.only(left: 8.0.w),
                        child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ),
                      isDense: true,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(8.0.w),
                child: assetLogic(ref, context, controller, receiveAsset: true),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget assetLogic(
    WidgetRef ref,
    BuildContext context,
    TextEditingController controller, {
      bool receiveAsset = true,
    }) {
  final swapType = ref.watch(swapTypeProvider)!;

  double widgetHeight = 70.0.w;

  Widget child;
  switch (swapType) {
    case SwapType.sideswapBtcToLbtc:
      child = buildBitcoinPeg(ref, receiveAsset, controller);
      break;
    case SwapType.sideswapLbtcToBtc:
      child = buildLiquidPeg(ref, receiveAsset, controller);
      break;
    case SwapType.coinosLnToBTC:
    case SwapType.coinosLnToLBTC:
      child = buildCoinosSwap(ref, context, controller, receiveAsset);
      break;
    case SwapType.coinosBtcToLn:
    case SwapType.coinosLbtcToLn:
      child = buildCoinosSwap(ref, context, controller, receiveAsset);
      break;
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapDepixToUsdt:
    case SwapType.sideswapUsdtToEurox:
    case SwapType.sideswapUsdtToDepix:
    case SwapType.sideswapEuroxToUsdt:
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
      child = buildSideswapInstantSwap(ref, context, controller, receiveAsset: receiveAsset);
      break;
    default:
      child = Container();
  }

  return SizedBox(
    height: widgetHeight,
    child: child,
  );
}


Widget buildCoinosSwap(
    WidgetRef ref,
    BuildContext context,
    TextEditingController controller,
    bool receiveAsset,
    ) {
  final btcFormat = ref.read(settingsProvider).btcFormat;
  final inputInFiat = ref.watch(inputInFiatProvider);
  final currency = ref.read(settingsProvider).currency;
  final currencyRate = ref.read(selectedCurrencyProvider(currency));
  final sideSwapStatus = ref.watch(sideswapStatusProvider);

  final valueToReceive = ref.watch(sendTxProvider).amount *
      (1 - (receiveAsset ? sideSwapStatus.serverFeePercentPegOut / 100 : 0.001));

  final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormat);
  final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
  final valueInCurrency = currencyFormat(double.parse(formattedValueInBtc) * currencyRate, currency);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (receiveAsset)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 20.h),
            if (double.parse(formattedValueToReceive) <= 0)
              Text(
                "0",
                style: TextStyle(fontSize: 20.sp, color: Colors.grey),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        valueInCurrency,
                        style: TextStyle(fontSize: 20.sp, color: Colors.grey),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        currency,
                        style: TextStyle(fontSize: 8.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  IntrinsicWidth(
                    child: Row(
                      children: [
                        Text(
                          formattedValueToReceive,
                          style: TextStyle(fontSize: 20.sp, color: Colors.white),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          btcFormat,
                          style: TextStyle(fontSize: 8.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        )
      else
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Dropdown for unit selection
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: inputInFiat ? currency : btcFormat,
                    dropdownColor: const Color(0xFF212121),
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    items: [currency, btcFormat].map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(
                          option.toUpperCase(),
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (newUnit) {
                      if (newUnit != null && newUnit != (inputInFiat ? currency : btcFormat)) {
                        final isSwitchingToFiat = newUnit == currency;
                        ref.read(inputInFiatProvider.notifier).state = isSwitchingToFiat;
                        if (isSwitchingToFiat) {
                          String fiatValue = calculateAmountInSelectedCurrency(
                            ref.watch(sendTxProvider).amount,
                            currency,
                            ref.watch(currencyNotifierProvider),
                          );
                          controller.text = double.parse(fiatValue) < 0.01
                              ? ''
                              : double.parse(fiatValue).toStringAsFixed(2);
                        } else {
                          String btcValue = btcInDenominationFormatted(
                            ref.watch(sendTxProvider).amount.toDouble(),
                            btcFormat,
                          );
                          controller.text = btcValue;
                        }
                      }
                    },
                    icon: Padding(
                      padding: EdgeInsets.only(left: 8.0.w),
                      child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ),
                    isDense: true,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Input field
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IntrinsicWidth(
                  child: TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: controller,
                    inputFormatters: inputInFiat
                        ? [
                      CommaTextInputFormatter(),
                      DecimalTextInputFormatter(decimalRange: 2, integerRange: 7),
                    ]
                        : [
                      CommaTextInputFormatter(),
                      btcFormat == 'sats'
                          ? DecimalTextInputFormatter(decimalRange: 0)
                          : DecimalTextInputFormatter(decimalRange: 8, integerRange: 3),
                    ],
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 28.sp),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: controller.text.length > 10 ? 20.sp : 28.sp,
                    ),
                    onChanged: (value) async {
                      if (inputInFiat) {
                        if (value.isEmpty) {
                          ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                          ref.read(sendTxProvider.notifier).updateDrain(false);
                        } else {
                          String send = btcFormat == 'sats'
                              ? calculateAmountToDisplayFromFiatInSats(
                            value,
                            currency,
                            ref.watch(currencyNotifierProvider),
                          )
                              : calculateAmountToDisplayFromFiat(
                            value,
                            currency,
                            ref.watch(currencyNotifierProvider),
                          );
                          ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormat);
                          ref.read(sendTxProvider.notifier).updateDrain(false);
                        }
                      } else {
                        if (value.isEmpty) {
                          ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                          ref.read(sendTxProvider.notifier).updateDrain(false);
                        } else {
                          ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                          ref.read(sendTxProvider.notifier).updateDrain(false);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
    ],
  );
}

Widget buildSideswapInstantSwap(
    WidgetRef ref,
    BuildContext context,
    TextEditingController controller, {
      bool receiveAsset = true,
    }) {
  final btcFormat = ref.read(settingsProvider).btcFormat;
  final currency = ref.read(settingsProvider).currency;
  final currencyRateFromBitcoin = ref.watch(selectedCurrencyProvider(currency));
  final inputInFiat = ref.watch(inputInFiatProvider);
  final assetToSell = ref.watch(assetToSellProvider);
  final toAsset = ref.watch(toAssetProvider);
  final fromAsset = ref.watch(fromAssetProvider);
  final fiatToFiat = ref.watch(fiatToFiatSwap);

  String currentUnit = inputInFiat ? currency : btcFormat;
  List<String> options = fiatDisplayAllowedSwapTypes.contains(ref.watch(swapTypeProvider))
      ? [currency, btcFormat]
      : [];

  final quote = ref.watch(sideswapQuoteProvider);

  if (receiveAsset) {
    switch (quote.status) {
      case 'Success':
        final receiveAmount = assetToSell != quote.baseAsset ? quote.deliverAmount ?? 0 : quote.receiveAmount ?? 0;
        final formattedAmount = assetToSell != quote.baseAsset ? btcInDenominationFormatted(receiveAmount, btcFormat) : btcInDenominationFormatted(receiveAmount, btcFormat, false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: 4.h),
            Text(
              formattedAmount,
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
            ),
            if (!fiatAssets.contains(toAsset)) ...[
              Text(
                currencyFormat((btcFormat == 'sats' ? double.parse(formattedAmount) / 100000000 : double.parse(formattedAmount)) * currencyRateFromBitcoin, currency),
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
            ],
          ],
        );
      case 'LowBalance':
        return Text(
          'Insufficient balance',
          style: TextStyle(color: Colors.grey, fontSize: 16.sp),
        );
      case 'Loading':
      case 'Initial':
        return Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            size: 16.w,
            color: Colors.white,
          ),
        );
      default:
        const receiveAmount = 0;
        final formattedAmount = btcInDenominationFormatted(receiveAmount, btcFormat);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedAmount,
              style: TextStyle(color: Colors.white, fontSize: 20.sp),
            ),
            if (!fiatAssets.contains(toAsset)) ...[
              SizedBox(height: 4.h),
              Text(
                currencyFormat(0.0, currency),
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
            ],
          ],
        );
    }
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (options.isNotEmpty && !fiatToFiat)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentUnit,
                  dropdownColor: const Color(0xFF212121),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  items: options.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        option.toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    );
                  }).toList(),
                  onChanged: (newUnit) {
                    if (newUnit != null && newUnit != currentUnit) {
                      final isSwitchingToFiat = newUnit == currency;
                      ref.read(inputInFiatProvider.notifier).state = isSwitchingToFiat;
                      if (isSwitchingToFiat) {
                        String fiatValue = calculateAmountInSelectedCurrency(
                          ref.watch(sendTxProvider).amount,
                          currency,
                          ref.watch(currencyNotifierProvider),
                        );
                        controller.text = double.parse(fiatValue) < 0.01
                            ? ''
                            : double.parse(fiatValue).toStringAsFixed(2);
                      } else {
                        String btcValue = btcFormat == 'sats'
                            ? calculateAmountToDisplayFromFiatInSats(
                            controller.text, currency, ref.watch(currencyNotifierProvider))
                            : calculateAmountToDisplayFromFiat(
                            controller.text, currency, ref.watch(currencyNotifierProvider));
                        controller.text = btcFormat == 'sats'
                            ? btcInDenominationFormatted(double.parse(btcValue), btcFormat)
                            : btcValue;
                      }
                    }
                  },
                  icon: Padding(
                    padding: EdgeInsets.only(left: 8.0.w),
                    child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                  isDense: true,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                fromAsset,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
            ],
          ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IntrinsicWidth(
              child: TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: controller,
                inputFormatters: inputInFiat
                    ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2, integerRange: 7)]
                    : fiatAssets.contains(fromAsset)
                    ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2, integerRange: 7)]
                    : [
                  CommaTextInputFormatter(),
                  btcFormat == 'sats'
                      ? DecimalTextInputFormatter(decimalRange: 0)
                      : DecimalTextInputFormatter(decimalRange: 8, integerRange: 3),
                ],
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 28.sp),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: controller.text.length > 10 ? 20.sp : 28.sp,
                ),
                onChanged: (value) async {
                  if (inputInFiat) {
                    if (value.isEmpty) {
                      ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                      ref.read(sendTxProvider.notifier).updateDrain(false);
                    } else {
                      String send = btcFormat == 'sats'
                          ? calculateAmountToDisplayFromFiatInSats(
                          value, currency, ref.watch(currencyNotifierProvider))
                          : calculateAmountToDisplayFromFiat(
                          value, currency, ref.watch(currencyNotifierProvider));
                      ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormat);
                      ref.read(sendTxProvider.notifier).updateDrain(false);
                    }
                  } else {
                    if (value.isEmpty) {
                      ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                      ref.read(sendTxProvider.notifier).updateDrain(false);
                    } else {
                      ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                      ref.read(sendTxProvider.notifier).updateDrain(false);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget buildLiquidPeg(WidgetRef ref, bool pegIn, TextEditingController controller) {
  final sideSwapStatus = ref.watch(sideswapStatusProvider);
  final valueToReceive = ref.watch(sendTxProvider).amount * (1 - sideSwapStatus.serverFeePercentPegOut / 100) - ref.watch(pegOutBitcoinCostProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final currency = ref.read(settingsProvider).currency;
  final currencyRate = ref.read(selectedCurrencyProvider(currency));
  final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormat);
  final sideSwapPeg = ref.watch(sideswapPegProvider);
  final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
  final valueInCurrency = currencyFormat(double.parse(formattedValueInBtc) * currencyRate, currency);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (pegIn)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (double.parse(formattedValueToReceive) <= 0)
              Column(
                children: [
                  SizedBox(height: 20.h),
                  Text("0", style: TextStyle(fontSize: 20.sp, color: Colors.grey)),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(valueInCurrency, style: TextStyle(fontSize: 20.sp, color: Colors.grey)),
                      SizedBox(width: 2.w),
                      Text(currency, style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                    ],
                  ),
                  IntrinsicWidth(
                    child: Row(
                      children: [
                        Text(formattedValueToReceive, style: TextStyle(fontSize: 20.sp, color: Colors.white)),
                        SizedBox(width: 2.w),
                        Text(btcFormat, style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        )
      else
        sideSwapPeg.when(
          data: (peg) {
            // Define dropdown options (assuming fiat input is always allowed for peg-out)
            final options = [currency, btcFormat];
            final currentUnit = ref.watch(inputInFiatProvider) ? currency : btcFormat;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Dropdown for unit selection
                if (options.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentUnit,
                          dropdownColor: const Color(0xFF212121),
                          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                          items: options.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(
                                option.toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                              ),
                            );
                          }).toList(),
                          onChanged: (newUnit) {
                            if (newUnit != null && newUnit != currentUnit) {
                              final isSwitchingToFiat = newUnit == currency;
                              ref.read(inputInFiatProvider.notifier).state = isSwitchingToFiat;
                              if (isSwitchingToFiat) {
                                String fiatValue = calculateAmountInSelectedCurrency(
                                    ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                                controller.text = double.parse(fiatValue) < 0.01
                                    ? ''
                                    : double.parse(fiatValue).toStringAsFixed(2);
                              } else {
                                String btcValue = btcInDenominationFormatted(
                                    ref.watch(sendTxProvider).amount.toDouble(), btcFormat);
                                controller.text = btcValue;
                              }
                            }
                          },
                          icon: Padding(
                            padding: EdgeInsets.only(left: 8.0.w),
                            child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          ),
                          isDense: true,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        btcFormat,
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                SizedBox(height: 8.h), // Spacing between dropdown and input field
                // Input field
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IntrinsicWidth(
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: controller,
                        inputFormatters: ref.watch(inputInFiatProvider)
                            ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2, integerRange: 7)]
                            : [
                          CommaTextInputFormatter(),
                          btcFormat == 'sats'
                              ? DecimalTextInputFormatter(decimalRange: 0)
                              : DecimalTextInputFormatter(decimalRange: 8, integerRange: 3),
                        ],
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 28.sp),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: controller.text.length > 10 ? 20.sp : 28.sp,
                        ),
                        onChanged: (value) async {
                          if (ref.watch(inputInFiatProvider)) {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            } else {
                              String send = btcFormat == 'sats'
                                  ? calculateAmountToDisplayFromFiatInSats(value, currency, ref.watch(currencyNotifierProvider))
                                  : calculateAmountToDisplayFromFiat(value, currency, ref.watch(currencyNotifierProvider));
                              ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                          } else {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            } else {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => Center(child: LoadingAnimationWidget.fourRotatingDots(size: 16.w, color: Colors.white)),
          error: (error, stack) => Text(error.toString().i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp)),
        ),
    ],
  );
}

Widget buildBitcoinPeg(WidgetRef ref, bool pegIn, TextEditingController controller) {
  final sideSwapStatus = ref.watch(sideswapStatusProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final currency = ref.read(settingsProvider).currency;
  final currencyRate = ref.read(selectedCurrencyProvider(currency));
  final valueToReceive = ref.watch(sendTxProvider).amount * (1 - sideSwapStatus.serverFeePercentPegIn / 100) - ref.watch(pegOutBitcoinCostProvider);
  final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
  final valueInCurrency = currencyFormat(double.parse(formattedValueInBtc) * currencyRate, currency);
  final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormat);
  final sideSwapPeg = ref.watch(sideswapPegProvider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (pegIn)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (double.parse(formattedValueToReceive) <= 0)
              Column(
                children: [
                  SizedBox(height: 20.h),
                  Text("0", style: TextStyle(fontSize: 20.sp, color: Colors.grey)),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(valueInCurrency, style: TextStyle(fontSize: 20.sp, color: Colors.grey)),
                      SizedBox(width: 2.w),
                      Text(currency, style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                    ],
                  ),
                  IntrinsicWidth(
                    child: Row(
                      children: [
                        Text(formattedValueToReceive, style: TextStyle(fontSize: 20.sp, color: Colors.white)),
                        SizedBox(width: 2.w),
                        Text(btcFormat, style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        )
      else
        sideSwapPeg.when(
          data: (peg) {
            // Define dropdown options (assuming fiat input is always allowed for peg-out)
            final options = [currency, btcFormat];
            final currentUnit = ref.watch(inputInFiatProvider) ? currency : btcFormat;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Dropdown for unit selection
                if (options.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentUnit,
                          dropdownColor: const Color(0xFF212121),
                          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                          items: options.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(
                                option.toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                              ),
                            );
                          }).toList(),
                          onChanged: (newUnit) {
                            if (newUnit != null && newUnit != currentUnit) {
                              final isSwitchingToFiat = newUnit == currency;
                              ref.read(inputInFiatProvider.notifier).state = isSwitchingToFiat;
                              if (isSwitchingToFiat) {
                                String fiatValue = calculateAmountInSelectedCurrency(
                                    ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                                controller.text = double.parse(fiatValue) < 0.01
                                    ? ''
                                    : double.parse(fiatValue).toStringAsFixed(2);
                              } else {
                                String btcValue = btcInDenominationFormatted(
                                    ref.watch(sendTxProvider).amount.toDouble(), btcFormat);
                                controller.text = btcValue;
                              }
                            }
                          },
                          icon: Padding(
                            padding: EdgeInsets.only(left: 8.0.w),
                            child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          ),
                          isDense: true,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        btcFormat,
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                SizedBox(height: 8.h), // Spacing between dropdown and input field
                // Input field
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IntrinsicWidth(
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        controller: controller,
                        inputFormatters: ref.watch(inputInFiatProvider)
                            ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2, integerRange: 7)]
                            : [
                          CommaTextInputFormatter(),
                          btcFormat == 'sats'
                              ? DecimalTextInputFormatter(decimalRange: 0)
                              : DecimalTextInputFormatter(decimalRange: 8, integerRange: 3),
                        ],
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 28.sp),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: controller.text.length > 10 ? 20.sp : 28.sp,
                        ),
                        onChanged: (value) async {
                          if (ref.watch(inputInFiatProvider)) {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            } else {
                              String send = btcFormat == 'sats'
                                  ? calculateAmountToDisplayFromFiatInSats(value, currency, ref.watch(currencyNotifierProvider))
                                  : calculateAmountToDisplayFromFiat(value, currency, ref.watch(currencyNotifierProvider));
                              ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                          } else {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            } else {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => Center(child: LoadingAnimationWidget.fourRotatingDots(size: 16.w, color: Colors.white)),
          error: (error, stack) => Text(error.toString().i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp)),
        ),
    ],
  );
}

Widget buildAdvancedOptionsCard(WidgetRef ref) {
  return Card(
    color: const Color(0x00333333).withOpacity(0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    elevation: 4,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ExpansionTile(
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: 16.h),
        maintainState: true,
        shape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        collapsedShape: const Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        title: Text(
          'Transaction fees'.i18n,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Column(
              children: _getFeeRows(ref)
          ),
        ],
      ),
    ),
  );
}

List<Widget> _getFeeRows(WidgetRef ref) {
  final swapType = ref.watch(swapTypeProvider);
  final btcFormat = ref.read(settingsProvider).btcFormat;

  switch (swapType) {
    case SwapType.sideswapBtcToLbtc:
      final bitcoinFee = ref.watch(feeProvider);
      final sideswapStatus = ref.watch(sideswapStatusProvider);
      return bitcoinFee.when(
        data: (value) {
          return [
            _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegIn}%', ref),
            _feeRow('Network fee', '$value', ref),
            _feeRow(
              'Min amount',
              '${btcInDenominationFormatted(sideswapStatus.minPegInAmount, btcFormat)} $btcFormat',
              ref,
            ),
          ];
        },
        loading: () {
          return [
            _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%', ref),
            _feeRow('Network fee', 'Loading...', ref),
            _feeRow(
              'Min amount',
              '${btcInDenominationFormatted(sideswapStatus.minPegInAmount, btcFormat)} $btcFormat',
              ref,
            ),
          ];
        },
        error: (error, stack) {
          return [
            _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%', ref),
            _feeRow('Network fee', '0', ref),
            _feeRow(
              'Min amount',
              '${btcInDenominationFormatted(sideswapStatus.minPegInAmount, btcFormat)} $btcFormat',
              ref,
            ),
          ];
        },
      );

    case SwapType.sideswapLbtcToBtc:
      final pegOutCost = ref.watch(pegOutBitcoinCostProvider);
      final sideswapStatus = ref.watch(sideswapStatusProvider);
      final liquidFee = ref.watch(liquidFeeProvider);
      return liquidFee.when(
        data: (value) {
          return [
            _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%', ref),
            _feeRow(
              'Peg out fee',
              '${btcInDenominationFormatted(pegOutCost, btcFormat)} $btcFormat',
              ref,
            ),
            _feeRow('Network fee', '$value', ref),
            _feeRow(
              'Min amount',
              '${btcInDenominationFormatted(sideswapStatus.minPegOutAmount, btcFormat)} $btcFormat',
              ref,
            ),
          ];
        },
        loading: () {
          return [
            _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%', ref),
            _feeRow(
              'Peg out fee',
              '${btcInDenominationFormatted(pegOutCost, btcFormat)} $btcFormat',
              ref,
            ),
            _feeRow('Network fee', 'Loading...', ref),
            _feeRow(
              'Min amount',
              '${btcInDenominationFormatted(sideswapStatus.minPegOutAmount, btcFormat)} $btcFormat',
              ref,
            ),
          ];
        },
        error: (error, stack) {
          return [
            _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%', ref),
            _feeRow(
              'Peg out fee',
              '${btcInDenominationFormatted(pegOutCost, btcFormat)} $btcFormat',
              ref,
            ),
            _feeRow('Network fee', '0', ref),
            _feeRow(
              'Min amount',
              '${btcInDenominationFormatted(sideswapStatus.minPegOutAmount, btcFormat)} $btcFormat',
              ref,
            ),
          ];
        },
      );

    case SwapType.coinosLnToBTC:
      final pegOutCost = ref.watch(pegOutBitcoinCostProvider);
      return [
        _feeRow(
          'Network fee',
          '${btcInDenominationFormatted(pegOutCost, btcFormat)} $btcFormat',
          ref,
        ),
        _feeRow('Provider fee', '0.1%', ref),
      ];

    case SwapType.coinosLnToLBTC:
      return [
        _feeRow('Provider fee', '0.1%', ref),
      ];

    case SwapType.coinosBtcToLn:
      final bitcoinFee = ref.watch(feeProvider);
      return bitcoinFee.when(
        data: (value) {
          return [
            _feeRow('Network fee', '$value', ref),
          ];
        },
        loading: () {
          return [
            _feeRow('Network fee', '0', ref),
          ];
        },
        error: (error, stack) {
          return [
            _feeRow('Network fee', '0', ref),
          ];
        },
      );

    case SwapType.coinosLbtcToLn:
      final liquidFee = ref.watch(liquidFeeProvider);
      return liquidFee.when(
        data: (value) {
          return [
            _feeRow('Network fee', '$value', ref),
          ];
        },
        loading: () {
          return [
            _feeRow('Network fee', '0', ref),
          ];
        },
        error: (error, stack) {
          return [
            _feeRow('Network fee', '0', ref),
          ];
        },
      );

    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapDepixToUsdt:
    case SwapType.sideswapUsdtToEurox:
    case SwapType.sideswapUsdtToDepix:
    case SwapType.sideswapEuroxToUsdt:
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
    final quote = ref.watch(sideswapQuoteProvider);
    switch (quote.status) {
      case 'Success':
        final fixedFee = quote.fixedFee ?? 0;
        final serverFee = quote.serverFee ?? 0;
        final feeAsset = ref.read(fromAssetProvider);
        final btcFormat = ref.read(settingsProvider).btcFormat;
        final fixedFeeStr = formatAssetAmount(feeAsset, fixedFee, btcFormat);
        final serverFeeStr = formatAssetAmount(feeAsset, serverFee, btcFormat);
        return [
          _feeRow('Fixed fee', fixedFeeStr, ref),
          _feeRow('Server fee', serverFeeStr, ref),
        ];
      case 'LowBalance':
        return [
          Text(
            'Insufficient balance',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ];
      case 'Loading':
      case 'Initial':
        return [
          _feeRow('Fixed fee', 'Loading...', ref),
          _feeRow('Server fee', 'Loading...', ref),
        ];
      default:
        return [
          _feeRow('Fixed fee', formatAssetAmount(quote.feeAsset, 0, btcFormat), ref),
          _feeRow('Server fee', formatAssetAmount(quote.feeAsset, 0, btcFormat), ref),
        ];
    }

    default:
      return [
        _feeRow('Fee rate', '0%', ref),
      ];
  }
}

Widget _feeRow(String label, String value, WidgetRef ref) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.i18n,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget pickBitcoinFeeSuggestionsPegOut(WidgetRef ref) {
  final status = ref.watch(sideswapStatusProvider).bitcoinFeeRates ?? [];
  final selectedBlocks = ref.watch(pegOutBlocksProvider);

  // Reverse the status list
  final reversedStatus = status.reversed.toList();

  // If empty, show a placeholder message or return an empty widget
  if (reversedStatus.isEmpty) {
    return const SizedBox.shrink();
  }

  final indexFromBlocks = reversedStatus.indexWhere((item) => item["blocks"] == selectedBlocks);
  final validInitialIndex = indexFromBlocks >= 0 ? indexFromBlocks : 0;

  // Define fixed labels for display
  final labels = ["10 min", "30 min", "60 min", "Days", "Weeks"].reversed.toList();

  return Column(
    children: [
      Slider(
        value: validInitialIndex.toDouble(),
        onChanged: (value) {
          final index = value.round();
          final newValue = reversedStatus[index];
          ref.read(bitcoinReceiveSpeedProvider.notifier).state = "${newValue["value"]} sats/vbyte";
          ref.read(pegOutBlocksProvider.notifier).state = newValue["blocks"];
        },
        min: 0,
        max: (reversedStatus.length - 1).toDouble(),
        divisions: reversedStatus.length - 1,
        activeColor: Colors.orange,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(reversedStatus.length, (index) {
          final value = reversedStatus[index];
          final label = (labels.length > index) ? labels[index] : "";
          return _simpleFeeText(
            label,
            value["value"].toDouble(),
            ref,
          );
        }),
      ),
    ],
  );
}




Widget feeSelection(WidgetRef ref) {
  final swapType = ref.watch(swapTypeProvider);

  switch (swapType) {
    case SwapType.sideswapBtcToLbtc:
      return bitcoinFeeSlider(ref);
    case SwapType.sideswapLbtcToBtc:
      return pickBitcoinFeeSuggestionsPegOut(ref);
    case SwapType.coinosLnToBTC:
    case SwapType.coinosLnToLBTC:
      return const SizedBox.shrink();
    case SwapType.coinosBtcToLn:
      return bitcoinFeeSlider(ref);
    case SwapType.coinosLbtcToLn:
      return const SizedBox.shrink();
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
      return const SizedBox.shrink();
    default:
      return const SizedBox.shrink();
  }
}

Widget _liquidPegSlideToSend(WidgetRef ref, BuildContext context) {
  final status = ref.watch(sideswapStatusProvider);
  final pegStatus = ref.watch(sideswapPegStatusProvider);

  return pegStatus.when(
    data: (peg) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: ActionSlider.standard(
          width: double.infinity,
          backgroundColor: Colors.black,
          toggleColor: Colors.orange,
          action: (controller) async {
            ref.read(transactionInProgressProvider.notifier).state = true;
            controller.loading();
            try {
              if (ref.watch(sendTxProvider).amount < status.minPegOutAmount) {
                ref.read(transactionInProgressProvider.notifier).state = false;
                throw 'Amount is below minimum peg out amount'.i18n;
              }
              await ref.watch(sendLiquidTransactionProvider.future);
              await ref.read(sideswapHiveStorageProvider(peg.orderId!).future);
              showFullscreenExchangeModal(
                amount: ref.read(sendTxProvider).amount,
                context: context,
                swapType: ref.read(swapTypeProvider)!,
              );
              ref.read(sendTxProvider.notifier).updateAddress('');
              ref.read(sendTxProvider.notifier).updateAmount(0);
              ref.read(sendBlocksProvider.notifier).state = 1;
              Future.microtask(() {
                ref.read(navigationProvider.notifier).state = 0;
              });
              controller.success();
              ref.read(transactionInProgressProvider.notifier).state = false;
              ref.read(sendTxProvider.notifier).resetToDefault();
            } catch (e) {
              controller.failure();
              ref.read(transactionInProgressProvider.notifier).state = false;
              showMessageSnackBar(
                message: e.toString(),
                error: true,
                context: context,
              );
              controller.reset();
            }
          },
          child:  Text(
            'Slide to Swap'.i18n,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
    loading: () => Center(child: LoadingAnimationWidget.fourRotatingDots(size: 20.w, color: Colors.white)),
    error: (error, stack) => Text(ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
  );
}


Widget _bitcoinPegSlideToSend(WidgetRef ref, BuildContext context) {
  final pegStatus = ref.watch(sideswapPegStatusProvider);

  return pegStatus.when(
    data: (peg) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: ActionSlider.standard(
          width: double.infinity,
          backgroundColor: Colors.black,
          toggleColor: Colors.orange,
          action: (controller) async {
            ref.read(transactionInProgressProvider.notifier).state = true;
            controller.loading();
            try {
              if (ref.watch(sendTxProvider).amount < ref.watch(sideswapStatusProvider).minPegInAmount) {
                ref.read(transactionInProgressProvider.notifier).state = false;
                throw 'Amount is below minimum peg in amount'.i18n;
              }
              await ref.watch(sendBitcoinTransactionProvider.future);
              await ref.read(sideswapHiveStorageProvider(peg.orderId!).future);
              showFullscreenExchangeModal(
                amount: ref.read(sendTxProvider).amount,
                context: context,
                swapType: ref.read(swapTypeProvider)!,
              );
              ref.read(sendTxProvider.notifier).updateAddress('');
              ref.read(sendTxProvider.notifier).updateAmount(0);
              ref.read(sendBlocksProvider.notifier).state = 1;
              Future.microtask(() {
                ref.read(navigationProvider.notifier).state = 0;
              });
              controller.success();
              ref.read(transactionInProgressProvider.notifier).state = false;
              ref.read(sendTxProvider.notifier).resetToDefault();
            } catch (e) {
              ref.read(transactionInProgressProvider.notifier).state = false;
              controller.failure();
              showMessageSnackBar(
                message: e.toString(),
                error: true,
                context: context,
              );
              controller.reset();
            }
          },
          child: Text(
            'Slide to Swap'.i18n,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
    loading: () => Padding(
      padding: EdgeInsets.all(20.w),
      child: Center(child: LoadingAnimationWidget.fourRotatingDots(size: 20.w, color: Colors.white)),
    ),
    error: (error, stack) => Padding(
      padding: EdgeInsets.all(10.w),
      child: Text(error.toString().i18n, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
    ),
  );
}


Widget _instantSwapSlideToSend(WidgetRef ref, BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(bottom: 20.w),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: ActionSlider.standard(
        width: double.infinity,
        backgroundColor: Colors.black,
        toggleColor: Colors.orange,
        action: (controller) async {
          ref.read(transactionInProgressProvider.notifier).state = true;
          controller.loading();
          try {
            await ref.read(sideswapUploadAndSignInputsProvider.future).then((value) => value);
            showFullscreenExchangeModal(
              amount: ref.read(sendTxProvider).amount,
              context: context,
              swapType: ref.read(swapTypeProvider)!,
            );
            ref.read(sendTxProvider.notifier).updateAddress('');
            ref.read(sendTxProvider.notifier).updateAmount(0);
            ref.read(sendBlocksProvider.notifier).state = 1;
            Future.microtask(() {
              ref.read(navigationProvider.notifier).state = 0;
            });
            controller.success();
            ref.read(transactionInProgressProvider.notifier).state = false;
            ref.read(sendTxProvider.notifier).resetToDefault();
          } catch (e) {
            ref.read(transactionInProgressProvider.notifier).state = false;
            controller.failure();
            showMessageSnackBar(
              message: e.toString().i18n,
              error: true,
              context: context,
            );
            controller.reset();
          }
        },
        child: Text(
          'Slide to Swap'.i18n,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}


Widget _liquidLnSlideToSend(WidgetRef ref, BuildContext context, bool sendLn) {
  return Padding(
    padding: EdgeInsets.only(bottom: 20.w),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: ActionSlider.standard(
        width: double.infinity,
        backgroundColor: Colors.black,
        toggleColor: Colors.orange,
        action: (controller) async {
          ref.read(transactionInProgressProvider.notifier).state = true;
          controller.loading();
          try {
            if (sendLn) {
              final liquidAddress = ref.read(addressProvider).liquidAddress;
              ref.read(sendTxProvider.notifier).updateAddress(liquidAddress);
              await ref.read(sendCoinosLiquidProvider.future);
            } else {
              final addressFromCoinos = await ref.read(createInvoiceForSwapProvider('liquid').future);
              ref.read(sendTxProvider.notifier).updateAddress(addressFromCoinos);
              await ref.read(sendLiquidTransactionProvider.future);
              final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
              final lnBalance = await ref.read(coinosBalanceProvider.future);
              balanceNotifier.updateLightningBalance(lnBalance);
            }
            ref.read(sendBlocksProvider.notifier).state = 1;
            controller.success();
            showFullscreenExchangeModal(
              amount: ref.read(sendTxProvider).amount,
              context: context,
              swapType: ref.read(swapTypeProvider)!,
            );
            ref.read(transactionInProgressProvider.notifier).state = false;
            ref.read(sendTxProvider.notifier).resetToDefault();
          } catch (e) {
            ref.read(transactionInProgressProvider.notifier).state = false;
            controller.failure();
            showMessageSnackBar(
              message: e.toString().i18n,
              error: true,
              context: context,
            );
            controller.reset();
          }
        },
        child:  Text(
          'Slide to Swap'.i18n,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

Widget _bitcoinLnSlideToSend(WidgetRef ref, BuildContext context, bool sendLn) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10.w),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: ActionSlider.standard(
        width: double.infinity,
        backgroundColor: Colors.black,
        toggleColor: Colors.orange,
        action: (controller) async {
          ref.read(transactionInProgressProvider.notifier).state = true;
          controller.loading();
          try {
            if (sendLn) {
              final btcAddress = ref.read(addressProvider).bitcoinAddress;
              ref.read(sendTxProvider.notifier).updateAddress(btcAddress);
              await ref.read(sendCoinosBitcoinProvider.future);
            } else {
              final addressFromCoinos = await ref.read(createInvoiceForSwapProvider('bitcoin').future);
              ref.read(sendTxProvider.notifier).updateAddress(addressFromCoinos);
              await ref.read(sendBitcoinTransactionProvider.future);
              final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
              final lnBalance = await ref.read(coinosBalanceProvider.future);
              balanceNotifier.updateLightningBalance(lnBalance);
            }
            ref.read(sendBlocksProvider.notifier).state = 1;
            controller.success();
            showFullscreenExchangeModal(
              amount: ref.read(sendTxProvider).amount,
              context: context,
              swapType: ref.read(swapTypeProvider)!,
            );
            ref.read(transactionInProgressProvider.notifier).state = false;
            ref.read(sendTxProvider.notifier).resetToDefault();
          } catch (e) {
            ref.read(transactionInProgressProvider.notifier).state = false;
            controller.failure();
            showMessageSnackBar(
              message: e.toString().i18n,
              error: true,
              context: context,
            );
            controller.reset();
          }
        },
        child:  Text(
          'Slide to Swap'.i18n,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

Widget slideToSend(WidgetRef ref, BuildContext context) {
  final swapType = ref.watch(swapTypeProvider);

  switch (swapType) {
    case SwapType.sideswapBtcToLbtc:
      return _bitcoinPegSlideToSend(ref,context);
    case SwapType.sideswapLbtcToBtc:
      return _liquidPegSlideToSend(ref, context);
    case SwapType.coinosLnToBTC:
      return _bitcoinLnSlideToSend(ref, context, true);
    case SwapType.coinosLnToLBTC:
      return _liquidLnSlideToSend(ref, context, true);
    case SwapType.coinosBtcToLn:
      return _bitcoinLnSlideToSend(ref, context, false);
    case SwapType.coinosLbtcToLn:
      return _liquidLnSlideToSend(ref, context, false);
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapDepixToUsdt:
    case SwapType.sideswapUsdtToEurox:
    case SwapType.sideswapUsdtToDepix:
    case SwapType.sideswapEuroxToUsdt:
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
      return _instantSwapSlideToSend(ref, context);
    default:
      return const SizedBox.shrink();
  }
}
