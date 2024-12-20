import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/sideswap/sideswap_status_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
];

const List<String> fiatAssets = [
  'USDT',
  'Eurox',
  'Depix',
];


List<String> getAssets(WidgetRef ref) {
  final lightningAvailable = ref.watch(coinosLnProvider).token.isNotEmpty;

  return [
    'Bitcoin',
    if (lightningAvailable) 'Lightning Bitcoin',
    'Liquid Bitcoin',
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
    case 'Bitcoin-Liquid Bitcoin':
      return SwapType.sideswapBtcToLbtc;

    case 'Liquid Bitcoin-Bitcoin':
      return SwapType.sideswapLbtcToBtc;

    case 'Lightning Bitcoin-Bitcoin':
      return SwapType.coinosLnToBTC;

    case 'Lightning Bitcoin-Liquid Bitcoin':
      return SwapType.coinosLnToLBTC;

    case 'Bitcoin-Lightning Bitcoin':
      return SwapType.coinosBtcToLn;

    case 'Liquid Bitcoin-Lightning Bitcoin':
      return SwapType.coinosLbtcToLn;

    case 'USDT-Liquid Bitcoin':
      return SwapType.sideswapUsdtToLbtc;

    case 'Eurox-Liquid Bitcoin':
      return SwapType.sideswapEuroxToLbtc;

    case 'Depix-Liquid Bitcoin':
      return SwapType.sideswapDepixToLbtc;

    case 'Liquid Bitcoin-USDT':
      return SwapType.sideswapLbtcToUsdt;

    case 'Liquid Bitcoin-Eurox':
      return SwapType.sideswapLbtcToEurox;

    case 'Liquid Bitcoin-Depix':
      return SwapType.sideswapLbtcToDepix;

    default:
      return null;
  }
});

class SwapTypeNotifier extends StateNotifier<void> {
  SwapTypeNotifier(this.ref) : super(null);

  final Ref ref;

  void updateProviders(SwapType? swapType) {
    switch (swapType) {
      case SwapType.sideswapUsdtToLbtc:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.USD);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.sideswapEuroxToLbtc:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.EUR));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.EUR);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.sideswapDepixToLbtc:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.BRL));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.BRL);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.sideswapLbtcToUsdt:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.USD);
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        ref.read(inputInFiatProvider.notifier).state = false;
        break;

      case SwapType.sideswapLbtcToEurox:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.EUR);
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.sideswapLbtcToDepix:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.BRL);
        ref.read(sendBitcoinProvider.notifier).state = true;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.sideswapBtcToLbtc:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.sideswapLbtcToBtc:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.coinosLnToBTC:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.coinosLnToLBTC:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.coinosBtcToLn:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      case SwapType.coinosLbtcToLn:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = false;
        ref.read(inputInFiatProvider.notifier).state = false;
        ref.read(pegOutBlocksProvider.notifier).state = 2;
        break;

      default:
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
      return fiatInDenominationFormatted(balance.usdBalance);
    case SwapType.sideswapEuroxToLbtc:
      return fiatInDenominationFormatted(balance.eurBalance);
    case SwapType.sideswapDepixToLbtc:
      return fiatInDenominationFormatted(balance.brlBalance);
    default:
      return '0';
  }
});


List<String> getAvailableSwaps(String asset, WidgetRef ref) {
  final lightningAvailable = ref.watch(coinosLnProvider).token.isNotEmpty;

  switch (asset) {
    case 'Bitcoin':
      return ['Liquid Bitcoin', if (lightningAvailable) 'Lightning Bitcoin'];
    case 'Liquid Bitcoin':
      return ['USDT', 'Depix', 'Eurox', if (lightningAvailable) 'Lightning Bitcoin', 'Bitcoin'];
    case 'Lightning Bitcoin':
      return lightningAvailable ? ['Bitcoin', 'Liquid Bitcoin'] : [];
    case 'USDT':
    case 'Eurox':
    case 'Depix':
      return ['Liquid Bitcoin'];
    default:
      return [];
  }
}

Widget getAssetImage(String? asset, double width, double height) {
  if (asset == null) return Container();

  switch (asset) {
    case 'Bitcoin':
      return Image.asset('lib/assets/bitcoin-logo.png', width: width, height: height);
    case 'Liquid Bitcoin':
    case 'LBTC':
      return Image.asset('lib/assets/l-btc.png', width: width, height: height);
    case 'USDT':
      return Image.asset('lib/assets/tether.png', width: width, height: height);
    case 'Eurox':
    case 'EUROX':
    case 'EURx':
      return Image.asset('lib/assets/eurx.png', width: width, height: height);
    case 'Depix':
    case 'DEPIX':
      return Image.asset('lib/assets/depix.png', width: width, height: height);
    case 'Lightning Bitcoin':
    case 'Lightning':
      return Image.asset('lib/assets/Bitcoin_lightning_logo.png', width: width, height: height);
    default:
      return Image.asset('lib/assets/app_icon.png', width: width, height: height);
  }
}

final transactionInProgressProvider = StateProvider.autoDispose<bool>((ref) => false);
final fromAssetProvider = StateProvider.autoDispose<String>((ref) => 'Depix');
final toAssetProvider = StateProvider.autoDispose<String>((ref) => 'Liquid Bitcoin');
final inputInFiatProvider = StateProvider.autoDispose<bool>((ref) => false);
final bitcoinReceiveSpeedProvider = StateProvider.autoDispose<String>((ref) => 'Fastest');
final precisionFiatValueProvider = StateProvider.autoDispose<String>((ref) => "0.00");
final pegFee = StateProvider.autoDispose<String>((ref) => "0");
final networkFee = StateProvider.autoDispose<String>((ref) => "0");
final providerFee = StateProvider.autoDispose<String>((ref) => "0");

Widget bitcoinFeeSlider(WidgetRef ref, double dynamicPadding, double titleFontSize) {
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
              _simpleFeeText("Weeks", feeRate.minimumFee, titleFontSize, ref),
              _simpleFeeText("Days", feeRate.economyFee, titleFontSize, ref),
              _simpleFeeText("60 min", feeRate.hourFee, titleFontSize, ref),
              _simpleFeeText("30 min", feeRate.halfHourFee, titleFontSize, ref),
              _simpleFeeText("10 min", feeRate.fastestFee, titleFontSize, ref),
            ],
          );
        },
        loading: () => Center(
          child: LoadingAnimationWidget.progressiveDots(
            size: titleFontSize / 2,
            color: Colors.white,
          ),
        ),
        error: (e, _) => Text(
          'Error',
          style: TextStyle(color: Colors.white, fontSize: titleFontSize / 2),
        ),
      ),
    ],
  );
}

Widget _simpleFeeText(String label, double fee, double fontSize, WidgetRef ref) {
  final wholeFee = fee.toInt();

  return Column(
    children: [
      Text(
        label.i18n(ref),
        style: TextStyle(
          color: Colors.white70,
          fontSize: fontSize / 1.5,
          fontWeight: FontWeight.w400,
        ),
      ),
      SizedBox(height: 2),
      Text(
        "$wholeFee sat/vB",
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize / 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

Widget buildBalanceCardWithMaxButton(WidgetRef ref, double dynamicPadding, double titleFontSize, TextEditingController controller) {
  final balance = ref.watch(balanceFromAssetProvider);
  final swapType = ref.watch(swapTypeProvider)!;
  final btcFormat = ref.watch(settingsProvider).btcFormat;

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Balance'.i18n(ref),
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ),
      Container(
        width: double.infinity,
        child: Card(
          color: Colors.grey.shade900,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Balance Text
                Text(
                  balance,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Max Button
                TextButton(
                  onPressed: () async {
                    await handleMaxButtonPress(ref, swapType, controller, btcFormat);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Max',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
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
      balance = ref.read(balanceNotifierProvider).usdBalance;
      controller.text = fiatInDenominationFormatted(balance);
      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
      ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
      ref.read(sendTxProvider.notifier).updateDrain(true);
      break;

    case SwapType.sideswapEuroxToLbtc:
      balance = ref.read(balanceNotifierProvider).eurBalance;
      controller.text = fiatInDenominationFormatted(balance);
      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.EUR));
      ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
      ref.read(sendTxProvider.notifier).updateDrain(true);
      break;

    case SwapType.sideswapDepixToLbtc:
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

  final fee = await transaction.$1.feeAmount().then((value) => value);
  final amountToSet = (bitcoin - fee!);

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
  final balance = ref.read(balanceNotifierProvider).lightningBalance;
  int maxAmount = (balance! * 0.995).toInt();
  controller.text = btcInDenominationFormatted(maxAmount, btcFormat);
  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
}

Future<void> handleBitcoinToLightning(WidgetRef ref, TextEditingController controller, String btcFormat) async {
  final balance = ref.read(balanceNotifierProvider).btcBalance;
  final address = await ref.read(createInvoiceForSwapProvider('bitcoin').future);
  ref.read(sendTxProvider.notifier).updateAddress(address);

  final transactionBuilderParams =
  await ref.watch(bitcoinTransactionBuilderProvider(balance).future).then((value) => value);
  final transaction =
  await ref.watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilderParams).future).then((value) => value);

  final fee = await transaction.$1.feeAmount().then((value) => value);
  final amountToSet = (balance - fee!);
  controller.text = btcInDenominationFormatted(amountToSet, btcFormat);
  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
}

Future<void> handleLiquidBitcoinToLightning(WidgetRef ref, TextEditingController controller, String btcFormat) async {
  final address = await ref.read(createInvoiceForSwapProvider('liquid').future);
  ref.read(sendTxProvider.notifier).updateAddress(address);
  ref.read(sendTxProvider.notifier).updateDrain(true);

  final pset = await ref.watch(liquidDrainWalletProvider.future);
  final sendingBalance = pset.balances[0].value + pset.absoluteFees;
  final controllerValue = sendingBalance.abs();
  controller.text = btcInDenominationFormatted(controllerValue, btcFormat);
  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
}


Widget buildExchangeCard (BuildContext context, WidgetRef ref, TextEditingController controller) {
  final fromAsset = ref.watch(fromAssetProvider);
  final toAsset = ref.watch(toAssetProvider);

  return Card(
    color: Colors.grey.shade900,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(30.0),
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
                    'From Asset',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: fromAsset,
                      dropdownColor: Colors.black,
                      items: getAssets(ref)
                          .where((asset) => asset != toAsset) // Exclude the currently selected toAsset
                          .map((asset) => DropdownMenuItem(
                        value: asset,
                        child: Row(
                          children: [
                            getAssetImage(asset, 28.0, 28.0),
                            SizedBox(width: 8),
                            Text(
                              asset,
                              style: TextStyle(color: Colors.white, fontSize: 20),
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
                          final availableSwaps = getAvailableSwaps(value, ref).where((swap) => swap != value).toList();
                          if (!availableSwaps.contains(toAsset)) {
                            ref.read(toAssetProvider.notifier).state = availableSwaps.first;
                          }
                          ref.read(swapTypeNotifierProvider.notifier).updateProviders(ref.watch(swapTypeProvider));
                        }
                      },
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.arrow_drop_down, color: Colors.white),
                      ),
                      isDense: true, // Ensures tight alignment with text
                      style: TextStyle(color: Colors.white, fontSize: 18), // Dropdown text style
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: assetLogic(ref, 16, 20, context, controller, receiveAsset: false),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              SizedBox(width: 16),
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              SizedBox(width: 16),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To Asset',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: toAsset,
                      dropdownColor: Colors.black,
                      items: getAvailableSwaps(fromAsset, ref)
                          .where((asset) => asset != fromAsset)
                          .map((asset) => DropdownMenuItem(
                        value: asset,
                        child: Row(
                          children: [
                            getAssetImage(asset, 28.0, 28.0),
                            SizedBox(width: 8),
                            Text(
                              asset,
                              style: TextStyle(color: Colors.white, fontSize: 20),
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
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.arrow_drop_down, color: Colors.white),
                      ),
                      isDense: true, // Ensures tight alignment with text
                      style: TextStyle(color: Colors.white, fontSize: 18), // Dropdown text style
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: assetLogic(ref, 16, 20, context, controller, receiveAsset: true),
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
    double dynamicPadding,
    double titleFontSize,
    BuildContext context,
    TextEditingController controller, {
      bool receiveAsset = true,
    }) {
  final swapType = ref.watch(swapTypeProvider)!;

  // Define a consistent height for all widgets
  const double widgetHeight = 70.0; // Adjust height as per your design

  Widget child;
  switch (swapType) {
    case SwapType.sideswapBtcToLbtc:
      child = buildBitcoinPeg(ref, dynamicPadding, titleFontSize, receiveAsset, controller);
      break;
    case SwapType.sideswapLbtcToBtc:
      child = buildLiquidPeg(ref, dynamicPadding, titleFontSize, receiveAsset, controller);
      break;
    case SwapType.coinosLnToBTC:
    case SwapType.coinosLnToLBTC:
      child = buildCoinosSwap(ref, context, controller, titleFontSize, receiveAsset);
      break;
    case SwapType.coinosBtcToLn:
    case SwapType.coinosLbtcToLn:
      child = buildCoinosSwap(ref, context, controller, titleFontSize, receiveAsset);
      break;
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
      child = buildSideswapInstantSwap(ref, context, receiveAsset, titleFontSize, controller);
      break;
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
      child = buildSideswapInstantSwap(ref, context, receiveAsset, titleFontSize, controller);
      break;
    default:
      child = Container();
  }

  // Wrap the child in a SizedBox to enforce consistent height
  return SizedBox(
    height: widgetHeight,
    child: child,
  );
}


Widget buildCoinosSwap(
    WidgetRef ref,
    BuildContext context,
    TextEditingController controller,
    double titleFontSize,
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
  final valueToSendInCurrency =
  currencyFormat(ref.watch(sendTxProvider).amount / 100000000 * currencyRate, currency);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (receiveAsset)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (double.parse(formattedValueToReceive) <= 0)
              Text(
                "0",
                style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.grey),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    valueInCurrency,
                    style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                  ),
                  IntrinsicWidth(
                    child: Text(
                      formattedValueToReceive,
                      style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.white),
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
            GestureDetector(
              onTap: () {
                ref.read(inputInFiatProvider.notifier).state = !inputInFiat;

                if (inputInFiat) {
                  String btcValue = btcFormat == 'sats'
                      ? calculateAmountToDisplayFromFiatInSats(
                    controller.text,
                    currency,
                    ref.watch(currencyNotifierProvider),
                  )
                      : calculateAmountToDisplayFromFiat(
                    controller.text,
                    currency,
                    ref.watch(currencyNotifierProvider),
                  );
                  controller.text = btcFormat == 'sats'
                      ? btcInDenominationFormatted(double.parse(btcValue), btcFormat)
                      : btcValue;
                } else {
                  String fiatValue = calculateAmountInSelectedCurrency(
                    ref.watch(sendTxProvider).amount,
                    currency,
                    ref.watch(currencyNotifierProvider),
                  );
                  ref.read(precisionFiatValueProvider.notifier).state = fiatValue;
                  controller.text = double.parse(fiatValue) < 0.01
                      ? ''
                      : double.parse(fiatValue).toStringAsFixed(2);
                }
              },
              child: inputInFiat
                  ? Text(
                btcInDenominationFormatted(
                    ref.watch(sendTxProvider).amount.toDouble(), btcFormat),
                style: TextStyle(fontSize: titleFontSize * 1.1, color: Colors.grey),
              )
                  : Text(
                valueToSendInCurrency,
                style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
              ),
            ),
            SizedBox(height: 8),
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
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: titleFontSize * 1.2,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize * 1.2,
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


Widget buildSideswapInstantSwap(
    WidgetRef ref,
    BuildContext context,
    bool receiveAsset,
    double titleFontSize,
    TextEditingController controller,
    ) {
  final btcFormat = ref.read(settingsProvider).btcFormat;
  final sendBitcoin = ref.watch(sendBitcoinProvider);
  final currency = ref.read(settingsProvider).currency;
  final currencyRate = ref.read(selectedCurrencyProvider(currency));
  final inputInFiat = ref.watch(inputInFiatProvider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (receiveAsset)
        Consumer(
          builder: (context, watch, child) {
            final sideswapPriceStreamAsyncValue = ref.watch(sideswapPriceStreamProvider);
            return sideswapPriceStreamAsyncValue.when(
              data: (value) {
              if (value.errorMsg != null && (value.errorMsg!.contains('Max') || value.errorMsg!.contains('Min'))) {
                final parts = value.errorMsg!.split(' ');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      parts[0], // "Max" or "Min"
                      style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 1.5),
                    ),
                    Text(
                      parts.sublist(1).join(' '), // The rest of the message
                      style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 1.5),
                    ),
                  ],
                );
                } else {
                  final valueToReceive = value.recvAmount!;
                  final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
                  final valueInCurrency = receiveAsset
                      ? currencyFormat(double.parse(formattedValueInBtc) * currencyRate, currency)
                      : '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!fiatAssets.contains(ref.watch(toAssetProvider)))
                        Text(
                          valueInCurrency,
                          style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                        ),
                      IntrinsicWidth(
                        child: Text(
                          btcInDenominationFormatted(valueToReceive.toDouble(), btcFormat, !sendBitcoin),
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2),
                        ),
                      ),
                    ],
                  );
                }
              },
              loading: () => controller.text.isEmpty
                  ? Text(
                "0",
                style: TextStyle(color: Colors.grey, fontSize: titleFontSize * 1.2),
              )
                  : Center(
                child: LoadingAnimationWidget.progressiveDots(
                  size: titleFontSize * 1.2, // Match loading animation size
                  color: Colors.white,
                ),
              ),
              error: (error, stack) => Text(
                'Error: $error',
                style: TextStyle(color: Colors.white, fontSize: titleFontSize),
              ),
            );
          },
        )
      else
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (fiatDisplayAllowedSwapTypes.contains(ref.watch(swapTypeProvider)))
              GestureDetector(
                onTap: () {
                  ref.read(inputInFiatProvider.notifier).state = !inputInFiat;

                  if (inputInFiat) {
                    String btcValue = btcFormat == 'sats'
                        ? calculateAmountToDisplayFromFiatInSats(controller.text, currency, ref.watch(currencyNotifierProvider))
                        : calculateAmountToDisplayFromFiat(controller.text, currency, ref.watch(currencyNotifierProvider));
                    controller.text = btcFormat == 'sats'
                        ? btcInDenominationFormatted(double.parse(btcValue), btcFormat)
                        : btcValue;
                  } else {
                    // Switching to Fiat
                    String fiatValue = calculateAmountInSelectedCurrency(
                        ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                    ref.read(precisionFiatValueProvider.notifier).state = fiatValue;
                    controller.text = double.parse(fiatValue) < 0.01
                        ? ''
                        : double.parse(fiatValue).toStringAsFixed(2);
                  }
                },
                child: inputInFiat
                    ? Text(
                  '${btcInDenominationFormatted(ref.watch(sendTxProvider).amount.toDouble(), btcFormat)}',
                  style: TextStyle(fontSize: titleFontSize * 1.1, color: Colors.grey),
                )
                    : Text(
                  currencyFormat(ref.watch(sendTxProvider).amount / 100000000 * currencyRate, currency),
                  style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                ),
              ),
            SizedBox(height: 8),
            IntrinsicWidth(
              child: TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: controller,
                inputFormatters: inputInFiat
                    ? [
                  CommaTextInputFormatter(),
                  DecimalTextInputFormatter(decimalRange: 2, integerRange: 7),
                ]
                    : fiatAssets.contains(ref.watch(fromAssetProvider))
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
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: titleFontSize * 1.2,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize * 1.2,
                ),
                onChanged: (value) async {
                  if (inputInFiat) {
                    if (value.isEmpty) {
                      ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                      ref.read(sendTxProvider.notifier).updateDrain(false);
                    } else {
                      String send = btcFormat == 'sats'
                          ? calculateAmountToDisplayFromFiatInSats(value, currency, ref.watch(currencyNotifierProvider))
                          : calculateAmountToDisplayFromFiat(value, currency, ref.watch(currencyNotifierProvider));
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

Widget buildLiquidPeg(WidgetRef ref, double dynamicPadding, double titleFontSize, bool pegIn, TextEditingController controller) {
  final sideSwapStatus = ref.watch(sideswapStatusProvider);
  final valueToReceive = ref.watch(sendTxProvider).amount * (1 - sideSwapStatus.serverFeePercentPegOut / 100) -  ref.watch(pegOutBitcoinCostProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final currency = ref.read(settingsProvider).currency;
  final currencyRate = ref.read(selectedCurrencyProvider(currency));
  final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormat);
  final sideSwapPeg = ref.watch(sideswapPegProvider);
  final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
  final valueInCurrency = currencyFormat(double.parse(formattedValueInBtc) * currencyRate, currency);
  final valueToSendInCurrency = currencyFormat(ref.watch(sendTxProvider).amount / 100000000 * currencyRate, currency);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (pegIn)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (double.parse(formattedValueToReceive) <= 0)
              Text("0", style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.grey))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(valueInCurrency, style: TextStyle(fontSize: titleFontSize, color: Colors.grey)),
                  IntrinsicWidth(
                    child: Text(formattedValueToReceive, style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.white)),
                  ),
                ],
              ),
          ],
        )
      else
        sideSwapPeg.when(
          data: (peg) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    bool currentIsFiat = ref.read(inputInFiatProvider);
                    if (currentIsFiat) {
                      String btcValue = btcFormat == 'sats'
                          ? calculateAmountToDisplayFromFiatInSats(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider))
                          : calculateAmountToDisplayFromFiat(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider));

                      controller.text = btcFormat == 'sats' ? btcInDenominationFormatted(double.parse(btcValue), btcFormat) : btcValue;
                    } else {
                      String fiatValue = calculateAmountInSelectedCurrency(ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                      ref.read(precisionFiatValueProvider.notifier).state = fiatValue;
                      controller.text = double.parse(fiatValue) < 0.01 ? '' : double.parse(fiatValue).toStringAsFixed(2);
                    }
                    ref.read(inputInFiatProvider.notifier).state = !currentIsFiat;
                  },
                  child: ref.watch(inputInFiatProvider)
                      ? Text(
                    '${btcInDenominationFormatted(ref.watch(sendTxProvider).amount.toDouble(), btcFormat)}',
                    style: TextStyle(fontSize: titleFontSize * 1.1, color: Colors.grey),
                  )
                      : Text(
                    valueToSendInCurrency,
                    style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!ref.watch(inputInFiatProvider))
                      IntrinsicWidth(
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: controller,
                          inputFormatters: [
                            CommaTextInputFormatter(),
                            btcFormat == 'sats'
                                ? DecimalTextInputFormatter(decimalRange: 0)
                                : DecimalTextInputFormatter(decimalRange: 8, integerRange: 3),
                          ],
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: titleFontSize * 1.2),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                            ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                            ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                            ref.read(sendTxProvider.notifier).updateDrain(false);
                          },
                        ),
                      ),
                    if (ref.watch(inputInFiatProvider))
                      IntrinsicWidth(
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: controller,
                          inputFormatters: [
                            CommaTextInputFormatter(),
                            DecimalTextInputFormatter(decimalRange: 2, integerRange: 7),
                          ],
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: titleFontSize * 1.2),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                            String send = btcFormat == 'sats'
                                ? calculateAmountToDisplayFromFiatInSats(controller.text, currency, ref.watch(currencyNotifierProvider))
                                : calculateAmountToDisplayFromFiat(controller.text, currency, ref.watch(currencyNotifierProvider));

                            ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormat);
                            ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                            ref.read(sendTxProvider.notifier).updateDrain(false);
                          },
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
          loading: () => Center(child: LoadingAnimationWidget.progressiveDots(size: titleFontSize * 1.2, color: Colors.white)),
          error: (error, stack) => Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize: titleFontSize / 1.2)),
        ),
    ],
  );
}

Widget buildBitcoinPeg(WidgetRef ref, double dynamicPadding, double titleFontSize, bool pegIn, TextEditingController controller) {
  final sideSwapStatus = ref.watch(sideswapStatusProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final currency = ref.read(settingsProvider).currency;
  final currencyRate = ref.read(selectedCurrencyProvider(currency));
  final valueToReceive = ref.watch(sendTxProvider).amount * (1 - sideSwapStatus.serverFeePercentPegIn / 100) - ref.watch(pegOutBitcoinCostProvider);
  final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
  final valueInCurrency = currencyFormat(double.parse(formattedValueInBtc) * currencyRate, currency);
  final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormat);
  final sideSwapPeg = ref.watch(sideswapPegProvider);
  final valueToSendInCurrency = currencyFormat(ref.watch(sendTxProvider).amount / 100000000 * currencyRate, currency);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if (pegIn)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (double.parse(formattedValueToReceive) <= 0)
              Text("0", style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.grey))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(valueInCurrency, style: TextStyle(fontSize: titleFontSize, color: Colors.grey)),
                  IntrinsicWidth(
                    child: Text(formattedValueToReceive, style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.white)),
                  ),
                ],
              ),
          ],
        )
      else
        sideSwapPeg.when(
          data: (peg) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    bool currentIsFiat = ref.read(inputInFiatProvider);
                    if (currentIsFiat) {
                      String btcValue = btcFormat == 'sats'
                          ? calculateAmountToDisplayFromFiatInSats(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider))
                          : calculateAmountToDisplayFromFiat(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider));

                      controller.text = btcFormat == 'sats' ? btcInDenominationFormatted(double.parse(btcValue), btcFormat) : btcValue;
                    } else {
                      String fiatValue = calculateAmountInSelectedCurrency(ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                      ref.read(precisionFiatValueProvider.notifier).state = fiatValue;
                      controller.text = double.parse(fiatValue) < 0.01 ? '' : double.parse(fiatValue).toStringAsFixed(2);
                    }
                    ref.read(inputInFiatProvider.notifier).state = !currentIsFiat;
                  },
                  child: ref.watch(inputInFiatProvider)
                      ? Text(
                    '${btcInDenominationFormatted(ref.watch(sendTxProvider).amount.toDouble(), btcFormat)}',
                    style: TextStyle(fontSize: titleFontSize * 1.1, color: Colors.grey),
                  )
                      : Text(
                    valueToSendInCurrency,
                    style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!ref.watch(inputInFiatProvider))
                      IntrinsicWidth(
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: controller,
                          inputFormatters: [
                            CommaTextInputFormatter(),
                            btcFormat == 'sats'
                                ? DecimalTextInputFormatter(decimalRange: 0)
                                : DecimalTextInputFormatter(decimalRange: 8, integerRange: 3),
                          ],
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: titleFontSize * 1.2),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                            ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                            ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                            ref.read(sendTxProvider.notifier).updateDrain(false);
                          },
                        ),
                      ),
                    if (ref.watch(inputInFiatProvider))
                      IntrinsicWidth(
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: controller,
                          inputFormatters: [
                            CommaTextInputFormatter(),
                            DecimalTextInputFormatter(decimalRange: 2, integerRange: 7),
                          ],
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: titleFontSize * 1.2),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                            String send = btcFormat == 'sats'
                                ? calculateAmountToDisplayFromFiatInSats(controller.text, currency, ref.watch(currencyNotifierProvider))
                                : calculateAmountToDisplayFromFiat(controller.text, currency, ref.watch(currencyNotifierProvider));

                            ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormat);
                            ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                            ref.read(sendTxProvider.notifier).updateDrain(false);
                          },
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
          loading: () => Center(child: LoadingAnimationWidget.progressiveDots(size: titleFontSize * 1.2, color: Colors.white)),
          error: (error, stack) => Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize: titleFontSize / 1.2)),
        ),
    ],
  );
}

Widget buildAdvancedOptionsCard(WidgetRef ref, double dynamicPadding, double titleFontSize) {
  return Card(
    color: Colors.grey.shade900,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(bottom: 16),
        maintainState: true,
        shape: Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        collapsedShape: Border(
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
        title: Text(
          'Transaction fees',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize / 1.2,
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
      return bitcoinFee.when(data: (value) {
        return [
          _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegIn}%'),
          _feeRow('Network fee', '$value'),
          _feeRow('Min amount', '${btcInDenominationFormatted(sideswapStatus.minPegInAmount, btcFormat)} $btcFormat'),
        ];
      }, loading: () {
        return [
          _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%'),
          _feeRow('Network fee', 'Loading...'),
          _feeRow('Min amount', '${btcInDenominationFormatted(sideswapStatus.minPegInAmount, btcFormat)} $btcFormat'),
        ];
      }, error: (error, stack) {
        return [
          _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%'),
          _feeRow('Network fee', '0'),
          _feeRow('Min amount', '${btcInDenominationFormatted(sideswapStatus.minPegInAmount, btcFormat)} $btcFormat'),
        ];
      });
    case SwapType.sideswapLbtcToBtc:
      final pegOutCost = ref.watch(pegOutBitcoinCostProvider);
      final sideswapStatus = ref.watch(sideswapStatusProvider);
      final liquidFee = ref.watch(liquidFeeProvider);
      return liquidFee.when(data: (value) {
        return [
          _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%'),
          _feeRow('Peg out fee', '${btcInDenominationFormatted(pegOutCost, btcFormat)} $btcFormat'),
          _feeRow('Network fee', '$value'),
          _feeRow('Min amount', '${btcInDenominationFormatted(sideswapStatus.minPegOutAmount, btcFormat)} $btcFormat'),
        ];
      }, loading: () {
        return [
          _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%'),
          _feeRow('Peg out fee', '${btcInDenominationFormatted(pegOutCost, btcFormat)} $btcFormat'),
          _feeRow('Network fee', 'Loading...'),
          _feeRow('Min amount', '${btcInDenominationFormatted(sideswapStatus.minPegOutAmount, btcFormat)} $btcFormat'),
        ];
      }, error: (error, stack) {
        return [
          _feeRow('Provider fee', '${sideswapStatus.serverFeePercentPegOut}%'),
          _feeRow('Peg out fee', '${btcInDenominationFormatted(pegOutCost, btcFormat)} $btcFormat'),
          _feeRow('Network fee', '0'),
          _feeRow('Min amount', '${btcInDenominationFormatted(sideswapStatus.minPegOutAmount, btcFormat)} $btcFormat'),
        ];
      });

    case SwapType.coinosLnToBTC:
      final pegOutCost = ref.watch(pegOutBitcoinCostProvider);
      return [
        _feeRow('Peg out fee', '${btcInDenominationFormatted(pegOutCost, btcFormat)} $btcFormat'),
        _feeRow('Provider fee', '0.1%'),
      ];
    case SwapType.coinosLnToLBTC:
      return [
        _feeRow('Provider fee', '0.1%'),
      ];
    case SwapType.coinosBtcToLn:
      final bitcoinFee = ref.watch(feeProvider);
      return bitcoinFee.when(data: (value) {
        return [
          _feeRow('Network fee', '$value'),
        ];
      }, loading: () {
        return [
          _feeRow('Network fee', '0'),
        ];
      }, error: (error, stack) {
        return [
          _feeRow('Network fee', '0'),
        ];
      });
    case SwapType.coinosLbtcToLn:
      final liquidFee = ref.watch(liquidFeeProvider);
      return liquidFee.when(data: (value) {
        return [
          _feeRow('Network fee', '$value'),
        ];
      }, loading: () {
        return [
          _feeRow('Provider fee', '0.1%'),
          _feeRow('Network fee', '0'),
        ];
      }, error: (error, stack) {
        return [
          _feeRow('Network fee', '0'),
        ];
      });
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
    final sideswapPriceStreamAsyncValue = ref.watch(sideswapPriceStreamProvider);
    return sideswapPriceStreamAsyncValue.when(
      data: (value) {
        if (value.errorMsg != null) {
          return [
            Text(
              value.errorMsg!,
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            )
          ];
        } else {
          final fixedFee = value.fixedFee ?? 0;

          return [
            _feeRow('Asset price', '${value.price?.toStringAsFixed(0) ?? "N/A"}'),
            _feeRow(
                'Fixed Fee',
                btcInDenominationFormatted(fixedFee.toDouble(), btcFormat, true)
            ),
          ];
        }
      },
      loading: () {
        return [
          _feeRow('Price', '0'),
          _feeRow('Fixed Fee', '0'),
        ];
      },
      error: (error, stack) {
        return [
          _feeRow('Price', '0'),
          _feeRow('Fixed Fee', '0'),
        ];
      },
    );
    default:
      return [
        _feeRow('Fee rate', '0%'),
      ];
  }
}

Widget _feeRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

Widget pickBitcoinFeeSuggestionsPegOut(WidgetRef ref, double dynamicPadding, double titleFontSize) {
  final status = ref.watch(sideswapStatusProvider).bitcoinFeeRates ?? [];
  final selectedBlocks = ref.watch(pegOutBlocksProvider);

  // Reverse the status list
  final reversedStatus = status.reversed.toList();

  // If empty, show a placeholder message or return an empty widget
  if (reversedStatus.isEmpty) {
    return Center(
      child: Text(
        'No fee data available',
        style: TextStyle(fontSize: titleFontSize),
      ),
    );
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
            titleFontSize,
            ref,
          );
        }),
      ),
    ],
  );
}




Widget feeSelection(WidgetRef ref, double dynamicPadding, double titleFontSize) {
  final swapType = ref.watch(swapTypeProvider);

  switch (swapType) {
    case SwapType.sideswapBtcToLbtc:
      return bitcoinFeeSlider(ref, dynamicPadding, titleFontSize);
    case SwapType.sideswapLbtcToBtc:
      return pickBitcoinFeeSuggestionsPegOut(ref, dynamicPadding, titleFontSize);
    case SwapType.coinosLnToBTC:
    case SwapType.coinosLnToLBTC:
      return SizedBox.shrink();
    case SwapType.coinosBtcToLn:
      return bitcoinFeeSlider(ref, dynamicPadding, titleFontSize);
    case SwapType.coinosLbtcToLn:
      return SizedBox.shrink();
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
      return SizedBox.shrink();
    default:
      return SizedBox.shrink();
  }
}



Widget _liquidPegSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
  final status = ref.watch(sideswapStatusProvider);
  final pegStatus = ref.watch(sideswapPegStatusProvider);

  return pegStatus.when(
    data: (peg) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: ActionSlider.standard(
            sliderBehavior: SliderBehavior.stretch,
            width: double.infinity,
            backgroundColor: Colors.black,
            toggleColor: Colors.orange,
            action: (controller) async {
              ref.read(transactionInProgressProvider.notifier).state = true;
              controller.loading();
              try {
                if (ref.watch(sendTxProvider).amount < status.minPegOutAmount) {
                  ref.read(transactionInProgressProvider.notifier).state = false;
                  throw 'Amount is below minimum peg out amount'.i18n(ref);
                }
                await ref.watch(sendLiquidTransactionProvider.future);
                await ref.read(sideswapHiveStorageProvider(peg.orderId!).future);
                await ref.read(liquidSyncNotifierProvider.notifier).performSync();
                ref.read(sendTxProvider.notifier).updateAddress('');
                ref.read(sendTxProvider.notifier).updateAmount(0);
                ref.read(sendBlocksProvider.notifier).state = 1;
                showMessageSnackBar(
                  message: 'Swap done!',
                  error: false,
                  context: context,
                );
                Future.microtask(() {
                  ref.read(selectedExpenseTypeProvider.notifier).state = "Swaps";
                  ref.read(navigationProvider.notifier).state = 1;
                });
                controller.success();
                ref.read(transactionInProgressProvider.notifier).state = false;
                context.go('/home');
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
            child:Text('Slide to Swap'.i18n(ref), style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)
        ),
      );
    },
    loading: () => Center(child: LoadingAnimationWidget.progressiveDots(size:  titleFontSize * 2, color: Colors.white)),
    error: (error, stack) => Text(ref.watch(sendTxProvider).amount == 0 ? '' : error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize)),
  );
}


Widget _bitcoinPegSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
  final pegStatus = ref.watch(sideswapPegStatusProvider);

  return pegStatus.when(
    data: (peg) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: ActionSlider.standard(
            sliderBehavior: SliderBehavior.stretch,
            width: double.infinity,
            backgroundColor: Colors.black,
            toggleColor: Colors.orange,
            action: (controller) async {
              ref.read(transactionInProgressProvider.notifier).state = true;
              controller.loading();
              try {
                if (ref.watch(sendTxProvider).amount < ref.watch(sideswapStatusProvider).minPegInAmount) {
                  ref.read(transactionInProgressProvider.notifier).state = false;
                  throw 'Amount is below minimum peg in amount'.i18n(ref);
                }
                await ref.watch(sendBitcoinTransactionProvider.future);
                await ref.read(sideswapHiveStorageProvider(peg.orderId!).future);
                await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
                ref.read(sendTxProvider.notifier).updateAddress('');
                ref.read(sendTxProvider.notifier).updateAmount(0);
                ref.read(sendBlocksProvider.notifier).state = 1;
                showMessageSnackBar(
                  message: 'Swap done!',
                  error: false,
                  context: context,
                );
                Future.microtask(() {
                  ref.read(selectedExpenseTypeProvider.notifier).state = "Swaps";
                  ref.read(navigationProvider.notifier).state = 1;
                });
                controller.success();
                ref.read(transactionInProgressProvider.notifier).state = false;
                context.go('/home');
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
            child: Text('Slide to Swap'.i18n(ref), style: const TextStyle(color: Colors.white), textAlign: TextAlign.center)
        ),
      );
    },
    loading: () => Padding(
      padding: EdgeInsets.all(dynamicPadding / 2),
      child: Center(child: LoadingAnimationWidget.progressiveDots(size:  titleFontSize * 2, color: Colors.white)),
    ),
    error: (error, stack) => Padding(
        padding: EdgeInsets.all(dynamicPadding / 2),
        child: Text(error.toString().i18n(ref), style: TextStyle(color: Colors.white, fontSize:  titleFontSize / 2))
    ),
  );
}


Widget _instantSwapSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(bottom: dynamicPadding / 2),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: ActionSlider.standard(
        sliderBehavior: SliderBehavior.stretch,
        width: double.infinity,
        backgroundColor: Colors.black,
        toggleColor: Colors.orange,
        action: (controller) async {
          ref.read(transactionInProgressProvider.notifier).state = true;
          controller.loading();
          try {
            await ref.read(sideswapUploadAndSignInputsProvider.future).then((value) => value);
            await ref.read(liquidSyncNotifierProvider.notifier).performSync();
            ref.read(sendTxProvider.notifier).updateAddress('');
            ref.read(sendTxProvider.notifier).updateAmount(0);
            ref.read(sendBlocksProvider.notifier).state = 1;
            Future.microtask(() {
              ref.read(selectedExpenseTypeProvider.notifier).state = "Swaps";
              ref.read(navigationProvider.notifier).state = 1;
            });
            controller.success();
            ref.read(transactionInProgressProvider.notifier).state = false;
            context.go('/home');
            ref.read(sendTxProvider.notifier).resetToDefault();
            showMessageSnackBar(
              message: 'Swap done!'.i18n(ref),
              error: false,
              context: context,
            );
          } catch (e) {
            ref.read(transactionInProgressProvider.notifier).state = false;
            controller.failure();
            showMessageSnackBar(
              message: e.toString().i18n(ref),
              error: true,
              context: context,
            );
            controller.reset();
          }
        },
        child: Text('Slide to Swap'.i18n(ref), style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white)),
      ),
    ),
  );
}


Widget _liquidLnSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context, bool sendLn) {
  return Padding(
    padding: EdgeInsets.only(bottom: dynamicPadding / 2),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: ActionSlider.standard(
        sliderBehavior: SliderBehavior.stretch,
        width: double.infinity,
        backgroundColor: Colors.black,
        toggleColor: Colors.orange,
        action: (controller) async {
          ref.read(transactionInProgressProvider.notifier).state = true;
          controller.loading();
          try {
            if (sendLn) {
              final liquidAddress = await ref.read(liquidAddressProvider.future);
              ref.read(sendTxProvider.notifier).updateAddress(liquidAddress.confidential);
              await ref.read(sendCoinosLiquidProvider.future);
              await ref.read(liquidSyncNotifierProvider.notifier).performSync();
            } else {
              final addressFromCoinos = await ref.read(createInvoiceForSwapProvider('liquid').future);
              ref.read(sendTxProvider.notifier).updateAddress(addressFromCoinos);
              await ref.read(sendLiquidTransactionProvider.future);
              final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
              final lnBalance = await ref.read(coinosBalanceProvider.future);
              balanceNotifier.updateLightningBalance(lnBalance);
              await ref.read(liquidSyncNotifierProvider.notifier).performSync();
            }
            showMessageSnackBar(
              message: 'Swap done!'.i18n(ref),
              error: false,
              context: context,
            );
            controller.success();
            ref.read(transactionInProgressProvider.notifier).state = false;
            context.go('/home');
            ref.read(sendTxProvider.notifier).resetToDefault();
          } catch (e) {
            ref.read(transactionInProgressProvider.notifier).state = false;
            controller.failure();
            showMessageSnackBar(
              message: e.toString().i18n(ref),
              error: true,
              context: context,
            );
            controller.reset();
          }
        },
        child: Text(
          'Slide to Swap'.i18n(ref),
          style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white),
        ),
      ),
    ),
  );
}

Widget _bitcoinLnSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context, bool sendLn) {
  return Padding(
    padding: EdgeInsets.only(bottom: dynamicPadding / 2),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: ActionSlider.standard(
        sliderBehavior: SliderBehavior.stretch,
        width: double.infinity,
        backgroundColor: Colors.black,
        toggleColor: Colors.orange,
        action: (controller) async {
          ref.read(transactionInProgressProvider.notifier).state = true;
          controller.loading();
          try {
            if (sendLn) {
              final btcAddress = await ref.read(bitcoinAddressProvider.future);
              ref.read(sendTxProvider.notifier).updateAddress(btcAddress);
              await ref.read(sendCoinosBitcoinProvider.future);
              await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
            } else {
              final addressFromCoinos = await ref.read(createInvoiceForSwapProvider('bitcoin').future);
              ref.read(sendTxProvider.notifier).updateAddress(addressFromCoinos);
              await ref.read(sendBitcoinTransactionProvider.future);
              final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
              final lnBalance = await ref.read(coinosBalanceProvider.future);
              balanceNotifier.updateLightningBalance(lnBalance);
              await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
            }
            showMessageSnackBar(
              message: 'Swap done!'.i18n(ref),
              error: false,
              context: context,
            );
            controller.success();
            ref.read(transactionInProgressProvider.notifier).state = false;
            context.go('/home');
            ref.read(sendTxProvider.notifier).resetToDefault();
          } catch (e) {
            ref.read(transactionInProgressProvider.notifier).state = false;
            controller.failure();
            showMessageSnackBar(
              message: e.toString().i18n(ref),
              error: true,
              context: context,
            );
            controller.reset();
          }
        },
        child: Text(
          'Slide to Swap'.i18n(ref),
          style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white),
        ),
      ),
    ),
  );
}

Widget slideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
  final swapType = ref.watch(swapTypeProvider);

  switch (swapType) {
    case SwapType.sideswapBtcToLbtc:
      return _bitcoinPegSlideToSend(ref, dynamicPadding, titleFontSize, context);
    case SwapType.sideswapLbtcToBtc:
      return _liquidPegSlideToSend(ref, dynamicPadding, titleFontSize, context);
    case SwapType.coinosLnToBTC:
      return _bitcoinLnSlideToSend(ref, dynamicPadding, titleFontSize, context, true);
    case SwapType.coinosLnToLBTC:
      return _liquidLnSlideToSend(ref, dynamicPadding, titleFontSize, context, true);
    case SwapType.coinosBtcToLn:
      return _bitcoinLnSlideToSend(ref, dynamicPadding, titleFontSize, context, false);
    case SwapType.coinosLbtcToLn:
      return _liquidLnSlideToSend(ref, dynamicPadding, titleFontSize, context, false);
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
      return _instantSwapSlideToSend(ref, dynamicPadding, titleFontSize, context);
    default:
      return SizedBox.shrink();
  }
}
