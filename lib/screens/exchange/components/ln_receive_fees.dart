import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/exchange/components/lightningSwaps.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ReceiveFeesWidget extends ConsumerWidget {
  const ReceiveFeesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fees = ref.watch(boltzReverseFeesProvider);
    final sendTxState = ref.watch(sendTxProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final sendAmount = sendTxState.btcBalanceInDenominationFormatted(btcFormat);
    final currencyConverter = ref.read(currencyNotifierProvider);
    final currencyRate = ref.read(selectedCurrencyProvider(btcFormat));
    final sendLiquid = ref.watch(sendLbtcProvider);

    return fees.when(
      data: (data) {
        final inputAmountInSats = (btcFormat == 'sats' || btcFormat == 'BTC')
            ? calculateAmountInSatsToDisplay(sendAmount.toString(), btcFormat, currencyConverter)
            : calculateAmountToDisplayFromFiatInSats(sendAmount.toString(), btcFormat, currencyConverter);

        final formattedValueInBtc = btcInDenominationFormatted(
          sendLiquid ? data.lbtcLimits.minimal.toDouble() : data.btcLimits.minimal.toDouble(),
          'BTC',
        );
        final formattedFeesInBtc = btcInDenominationFormatted(
          (sendLiquid ? data.lbtcFees.percentage : data.btcFees.percentage) / 100 * double.parse(inputAmountInSats.toString()) +
              (sendLiquid ? data.lbtcFees.minerFees.claim + data.lbtcFees.minerFees.lockup : data.btcFees.minerFees.claim + data.btcFees.minerFees.lockup),
          'BTC',
        );

        final formattedFeesInSats = (sendLiquid ? data.lbtcFees.percentage : data.btcFees.percentage) / 100 *
            double.parse(sendAmount.toString()) +
            (sendLiquid ? data.lbtcFees.minerFees.claim + data.lbtcFees.minerFees.lockup : data.btcFees.minerFees.claim + data.btcFees.minerFees.lockup);

        final valueToDisplay = currencyRate * double.parse(formattedValueInBtc);
        final feesToDisplay = currencyRate * double.parse(formattedFeesInBtc);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Total fees'.i18n(ref) + ' ' +
                    (btcFormat == 'BTC'
                        ? formattedFeesInBtc
                        : btcFormat == 'sats'
                        ? formattedFeesInSats.toStringAsFixed(0)
                        : feesToDisplay.toStringAsFixed(2)),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Minimum amount:'.i18n(ref) + ' ' +
                    (btcFormat == 'BTC'
                        ? formattedValueInBtc
                        : btcFormat == 'sats'
                        ? (sendLiquid ? data.lbtcLimits.minimal : data.btcLimits.minimal).toString()
                        : valueToDisplay.toStringAsFixed(2)),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Center(
        child: LoadingAnimationWidget.threeRotatingDots(color: Colors.grey, size: 20),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Unable to get minimum amount'.i18n(ref),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
