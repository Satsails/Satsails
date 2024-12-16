import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/screens/exchange/components/peg.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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


final List<String> assets = [
  'Bitcoin',
  'Lightning Bitcoin',
  'Liquid Bitcoin',
  'USDT',
  'Eurox',
  'Depix'
];
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
        break;

      case SwapType.sideswapEuroxToLbtc:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.EUR));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.EUR);
        ref.read(sendBitcoinProvider.notifier).state = false;
        break;

      case SwapType.sideswapDepixToLbtc:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.BRL));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.BRL);
        ref.read(sendBitcoinProvider.notifier).state = false;
        break;

      case SwapType.sideswapLbtcToUsdt:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = true;
        break;

      case SwapType.sideswapLbtcToEurox:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = true;
        break;

      case SwapType.sideswapLbtcToDepix:
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(AssetId.LBTC);
        ref.read(sendBitcoinProvider.notifier).state = true;
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
  final btcFormart = ref.watch(settingsProvider).btcFormat;

  switch (fromAsset) {
    case SwapType.sideswapBtcToLbtc:
    case SwapType.coinosBtcToLn:
      return btcInDenominationFormatted(balance.btcBalance, btcFormart);
    case SwapType.sideswapLbtcToBtc:
    case SwapType.coinosLbtcToLn:
    case SwapType.sideswapLbtcToDepix:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToUsdt:
      return btcInDenominationFormatted(balance.liquidBalance, btcFormart);
    case SwapType.coinosLnToBTC:
    case SwapType.coinosLnToLBTC:
      return btcInDenominationFormatted(balance.lightningBalance!.toInt(), btcFormart);
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


List<String> getAvailableSwaps(String asset) {
  switch (asset) {
    case 'Bitcoin':
      return ['Liquid Bitcoin', 'Lightning Bitcoin'];
    case 'Liquid Bitcoin':
      return ['USDT', 'Depix', 'Eurox', 'Lightning Bitcoin', 'Bitcoin'];
    case 'Lightning Bitcoin':
      return ['Bitcoin', 'Liquid Bitcoin'];
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

final transactionInProgressProvider = StateProvider<bool>((ref) => false);
final fromAssetProvider = StateProvider<String>((ref) => 'Bitcoin');
final toAssetProvider = StateProvider<String>((ref) => 'Lightning Bitcoin');



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
        "$fee sat/vB",
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize / 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}


Widget liquidFeeSlider(WidgetRef ref, double dynamicPadding, double titleFontSize) {
  return Column(
    children: [
      SizedBox(height: dynamicPadding / 2),
      Text("How many blocks would you like to wait".i18n(ref), style: TextStyle(fontSize: titleFontSize, color: Colors.white)),
      Slider(
        value: 16 - ref.watch(sendBlocksProvider).toDouble(),
        onChanged: (value) => ref.read(sendBlocksProvider.notifier).state = 16 - value,
        min: 1,
        max: 15,
        divisions: 14,
        label: ref.watch(sendBlocksProvider).toInt().toString(),
        activeColor: Colors.orange,
      )
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
                  onPressed: () {
                    handleMaxButtonPress(ref, swapType, controller, btcFormat);
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

void handleMaxButtonPress(
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
}

Future<void> handleLiquidBitcoinToLightning(WidgetRef ref, TextEditingController controller, String btcFormat) async {
  final address = await ref.read(createInvoiceForSwapProvider('liquid').future);
  ref.read(sendTxProvider.notifier).updateAddress(address);

  final pset = await ref.watch(liquidDrainWalletProvider.future);
  final sendingBalance = pset.balances[0].value + pset.absoluteFees;
  final controllerValue = sendingBalance.abs();
  controller.text = btcInDenominationFormatted(controllerValue, btcFormat);
}


Widget buildExchangeCard(String fromAsset, String toAsset, BuildContext context, WidgetRef ref, TextEditingController controller) {
  final swapType = ref.watch(swapTypeProvider)!;

  return Card(
    color: Colors.grey.shade900,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
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
                      items: assets
                          .where((asset) => asset != toAsset) // Exclude the currently selected toAsset
                          .map((asset) => DropdownMenuItem(
                        value: asset,
                        child: Row(
                          children: [
                            getAssetImage(asset, 28.0, 28.0),
                            SizedBox(width: 8),
                            Text(
                              asset,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.text = '';
                          ref.read(sendTxProvider.notifier).resetToDefault();
                          ref.read(fromAssetProvider.notifier).state = value;
                          final availableSwaps = getAvailableSwaps(value).where((swap) => swap != value).toList();
                          if (!availableSwaps.contains(toAsset)) {
                            ref.read(toAssetProvider.notifier).state = availableSwaps.first;
                          }
                          ref.read(swapTypeNotifierProvider.notifier).updateProviders(swapType);
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
              assetLogic(ref, 16, 20, controller, pegIn: false),
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
                  final temp = ref.read(fromAssetProvider);
                  ref.read(fromAssetProvider.notifier).state = ref.read(toAssetProvider);
                  ref.read(toAssetProvider.notifier).state = temp;
                  ref.read(swapTypeNotifierProvider.notifier).updateProviders(swapType);
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
                      items: getAvailableSwaps(fromAsset)
                          .where((asset) => asset != fromAsset) // Exclude the currently selected fromAsset
                          .map((asset) => DropdownMenuItem(
                        value: asset,
                        child: Row(
                          children: [
                            getAssetImage(asset, 28.0, 28.0),
                            SizedBox(width: 8),
                            Text(
                              asset,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(sendTxProvider.notifier).resetToDefault();
                          controller.text = '';
                          ref.read(toAssetProvider.notifier).state = value;

                          // Ensure the fromAsset is valid and not the same as toAsset
                          final availableSwaps = assets.where((swap) => swap != value).toList();
                          if (!availableSwaps.contains(fromAsset)) {
                            ref.read(fromAssetProvider.notifier).state = availableSwaps.first;
                          }
                          ref.read(swapTypeNotifierProvider.notifier).updateProviders(swapType);
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
              assetLogic(ref, 16, 20, controller, pegIn: true),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget assetLogic(WidgetRef ref, double dynamicPadding, double titleFontSize, TextEditingController controller, {bool pegIn = true}) {
  final swapType = ref.watch(swapTypeProvider)!;

  switch (swapType) {
    case SwapType.sideswapBtcToLbtc:
      return buildBitcoinPeg(ref, dynamicPadding, titleFontSize, pegIn, controller);
    case SwapType.sideswapLbtcToBtc:
      return buildLiquidPeg(ref, dynamicPadding, titleFontSize, pegIn, controller);
    case SwapType.coinosLnToBTC:
    case SwapType.coinosLnToLBTC:
    case SwapType.coinosBtcToLn:
    case SwapType.coinosLbtcToLn:
    case SwapType.sideswapUsdtToLbtc:
    case SwapType.sideswapEuroxToLbtc:
    case SwapType.sideswapDepixToLbtc:
    case SwapType.sideswapLbtcToUsdt:
    case SwapType.sideswapLbtcToEurox:
    case SwapType.sideswapLbtcToDepix:
    default:
      return Container();
  }
}


Widget buildLiquidPeg(WidgetRef ref, double dynamicPadding, double titleFontSize, bool pegIn, TextEditingController controller) {
  final sideSwapStatus = ref.watch(sideswapStatusProvider);
  final valueToReceive = ref.watch(sendTxProvider).amount * (1 - sideSwapStatus.serverFeePercentPegOut / 100);
  final btcFormart = ref.watch(settingsProvider).btcFormat;
  final currency = ref.read(settingsProvider).currency;
  final currencyRate = ref.read(selectedCurrencyProvider(currency));
  final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormart);
  final sideSwapPeg = ref.watch(sideswapPegProvider);
  final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
  final valueInCurrency = currencyFormat(double.parse(formattedValueInBtc) * currencyRate, currency);
  final valueToSendInCurrency = currencyFormat(ref.watch(sendTxProvider).amount / 100000000 * currencyRate, currency);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (pegIn)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (double.parse(formattedValueToReceive) <= 0)
              Text("0", style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.white), textAlign: TextAlign.center)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(valueInCurrency, style: TextStyle(fontSize: titleFontSize, color: Colors.grey), textAlign: TextAlign.center),
                  IntrinsicWidth(
                    child: Text(formattedValueToReceive, style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.white), textAlign: TextAlign.center),
                  ),
                  // Text(
                  //   '${'Minimum amount:'.i18n(ref)} ${btcInDenominationFormatted(pegIn ? status.minPegInAmount.toDouble() : status.minPegOutAmount.toDouble(), btcFormart)} $btcFormart',
                  //   style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                  //   textAlign: TextAlign.center,
                  // ),
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
                      String btcValue = btcFormart == 'sats'
                          ? calculateAmountToDisplayFromFiatInSats(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider))
                          : calculateAmountToDisplayFromFiat(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider));

                      controller.text = btcFormart == 'sats' ? btcInDenominationFormatted(double.parse(btcValue), btcFormart) : btcValue;
                    } else {
                      String fiatValue = calculateAmountInSelectedCurrency(ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                      ref.read(precisionFiatValueProvider.notifier).state = fiatValue;
                      controller.text = double.parse(fiatValue) < 0.01 ? '' : double.parse(fiatValue).toStringAsFixed(2);
                    }
                    ref.read(inputInFiatProvider.notifier).state = !currentIsFiat;
                  },
                  child: ref.watch(inputInFiatProvider)
                      ? Text(
                    '${btcInDenominationFormatted(ref.watch(sendTxProvider).amount.toDouble(), btcFormart)} $btcFormart',
                    style: TextStyle(fontSize: titleFontSize * 1.1, color: Colors.grey),
                    textAlign: TextAlign.center,
                  )
                      : Text(
                    valueToSendInCurrency,
                    style: TextStyle(fontSize: titleFontSize * 1.1, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!ref.watch(inputInFiatProvider))
                      IntrinsicWidth(
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: controller,
                          inputFormatters: [
                            CommaTextInputFormatter(),
                            btcFormart == 'sats'
                                ? DecimalTextInputFormatter(decimalRange: 0)
                                : DecimalTextInputFormatter(decimalRange: 8),
                          ],
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                            ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
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
                            DecimalTextInputFormatter(decimalRange: 2),
                          ],
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                            String send = btcFormart == 'sats'
                                ? calculateAmountToDisplayFromFiatInSats(controller.text, currency, ref.watch(currencyNotifierProvider))
                                : calculateAmountToDisplayFromFiat(controller.text, currency, ref.watch(currencyNotifierProvider));

                            ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormart);
                            ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                            ref.read(sendTxProvider.notifier).updateDrain(false);
                          },
                        ),
                      ),
                    SizedBox(width: 8),
                    if (ref.watch(inputInFiatProvider))
                      Text(
                        currency,
                        style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 1.2),
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
  final btcFormart = ref.watch(settingsProvider).btcFormat;
  final currency = ref.read(settingsProvider).currency;
  final currencyRate = ref.read(selectedCurrencyProvider(currency));
  final valueToReceive = ref.watch(sendTxProvider).amount * (1 - sideSwapStatus.serverFeePercentPegIn / 100) - ref.watch(pegOutBitcoinCostProvider);
  final formattedValueInBtc = btcInDenominationFormatted(valueToReceive, 'BTC');
  final valueInCurrency = currencyFormat(double.parse(formattedValueInBtc) * currencyRate, currency);
  final formattedValueToReceive = btcInDenominationFormatted(valueToReceive, btcFormart);
  final sideSwapPeg = ref.watch(sideswapPegProvider);
  final valueToSendInCurrency = currencyFormat(ref.watch(sendTxProvider).amount / 100000000 * currencyRate, currency);

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (pegIn)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (double.parse(formattedValueToReceive) <= 0)
              Text("0", style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.white), textAlign: TextAlign.center)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(valueInCurrency, style: TextStyle(fontSize: titleFontSize, color: Colors.grey), textAlign: TextAlign.center),
                  IntrinsicWidth(
                    child: Text(formattedValueToReceive, style: TextStyle(fontSize: titleFontSize * 1.2, color: Colors.white), textAlign: TextAlign.center),
                  ),
                  // Text(
                  //   '${'Minimum amount:'.i18n(ref)} ${btcInDenominationFormatted(pegIn ? status.minPegInAmount.toDouble() : status.minPegOutAmount.toDouble(), btcFormart)} $btcFormart',
                  //   style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                  //   textAlign: TextAlign.center,
                  // ),
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
                      String btcValue = btcFormart == 'sats'
                          ? calculateAmountToDisplayFromFiatInSats(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider))
                          : calculateAmountToDisplayFromFiat(ref.watch(precisionFiatValueProvider), currency, ref.watch(currencyNotifierProvider));

                      controller.text = btcFormart == 'sats' ? btcInDenominationFormatted(double.parse(btcValue), btcFormart) : btcValue;
                    } else {
                      String fiatValue = calculateAmountInSelectedCurrency(ref.watch(sendTxProvider).amount, currency, ref.watch(currencyNotifierProvider));
                      ref.read(precisionFiatValueProvider.notifier).state = fiatValue;
                      controller.text = double.parse(fiatValue) < 0.01 ? '' : double.parse(fiatValue).toStringAsFixed(2);
                    }
                    ref.read(inputInFiatProvider.notifier).state = !currentIsFiat;
                  },
                  child: ref.watch(inputInFiatProvider)
                      ? Text(
                    '${btcInDenominationFormatted(ref.watch(sendTxProvider).amount.toDouble(), btcFormart)} $btcFormart',
                    style: TextStyle(fontSize: titleFontSize * 1.1, color: Colors.grey),
                    textAlign: TextAlign.center,
                  )
                      : Text(
                    valueToSendInCurrency,
                    style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!ref.watch(inputInFiatProvider))
                      IntrinsicWidth(
                        child: TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          controller: controller,
                          inputFormatters: [
                            CommaTextInputFormatter(),
                            btcFormart == 'sats'
                                ? DecimalTextInputFormatter(decimalRange: 0)
                                : DecimalTextInputFormatter(decimalRange: 8),
                          ],
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                            ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
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
                            DecimalTextInputFormatter(decimalRange: 2),
                          ],
                          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize * 1.2),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                              ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                              ref.read(sendTxProvider.notifier).updateDrain(false);
                            }
                            String send = btcFormart == 'sats'
                                ? calculateAmountToDisplayFromFiatInSats(controller.text, currency, ref.watch(currencyNotifierProvider))
                                : calculateAmountToDisplayFromFiat(controller.text, currency, ref.watch(currencyNotifierProvider));

                            ref.read(sendTxProvider.notifier).updateAmountFromInput(send, btcFormart);
                            ref.read(sendTxProvider.notifier).updateAddress(peg.pegAddr ?? '');
                            ref.read(sendTxProvider.notifier).updateDrain(false);
                          },
                        ),
                      ),
                    SizedBox(width: 8),
                    if (ref.watch(inputInFiatProvider))
                      Text(
                        currency,
                        style: TextStyle(color: Colors.grey, fontSize: titleFontSize / 1.2),
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
  final sideswapStatus = ref.watch(sideswapStatusProvider);
  final selectedBlocks = ref.watch(sendBlocksProvider);
  final feeRateAsyncValue = ref.watch(bitcoinFeeRatePerBlockProvider);

  // Network Fee Calculation
  int pegOutVsize = sideswapStatus.pegOutBitcoinTxVsize;
  double selectedFeeRate = 0;

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
        title: Text(
          'Transaction fees',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: dynamicPadding / 2),
              feeRateAsyncValue.when(
                data: (feeRate) {
                  // Map block selection to the appropriate fee rate
                  switch (selectedBlocks) {
                    case 1:
                      selectedFeeRate = feeRate.fastestFee;
                      break;
                    case 2:
                      selectedFeeRate = feeRate.halfHourFee;
                      break;
                    case 3:
                      selectedFeeRate = feeRate.hourFee;
                      break;
                    case 4:
                      selectedFeeRate = feeRate.economyFee;
                      break;
                    default:
                      selectedFeeRate = feeRate.minimumFee;
                  }

                  double networkFee = selectedFeeRate * pegOutVsize;

                  return Column(
                    children: [
                      _feeRow("Provider fee", "${sideswapStatus.serverFeePercentPegOut}%"),
                      SizedBox(height: 8),
                      _feeRow("Network fee", "${networkFee.toStringAsFixed(2)} sats"),
                      SizedBox(height: 8),
                      _feeRow("Minimum Peg-In", "${sideswapStatus.minPegInAmount} sats"),
                      SizedBox(height: 8),
                      _feeRow("Minimum Peg-Out", "${sideswapStatus.minPegOutAmount} sats"),
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
                  'Error loading fees',
                  style: TextStyle(color: Colors.redAccent, fontSize: titleFontSize / 2),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _feeRow(String label, String value) {
  return Row(
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
          color: Colors.orangeAccent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

