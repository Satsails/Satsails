import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/exchange/components/LightningSwaps.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalAmountProvider = FutureProvider.autoDispose.family<double, bool>((ref, sendLiquid) async {
  final fees = await ref.watch(boltzSubmarineFeesProvider.future);
  final sendTxState = ref.watch(sendTxProvider);
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final sendAmount = sendTxState.btcBalanceInDenominationFormatted(btcFormat);
  double amountInSats = btcFormat == 'sats' ? sendAmount : (sendAmount * 100000000);

  if (sendLiquid) {
    double percentageFee = fees.lbtcFees.percentage / 100 * amountInSats;
    return amountInSats + percentageFee + fees.lbtcFees.minerFees;
  } else {
    double percentageFee = fees.btcFees.percentage / 100 * amountInSats;
    return amountInSats + percentageFee + fees.btcFees.minerFees;
  }
});

class DisplayFeesWidget extends ConsumerWidget {
  const DisplayFeesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final sendLiquid = ref.watch(sendLbtcProvider);
    final totalAmountAsyncValue = ref.watch(totalAmountProvider(sendLiquid));
    final fees = ref.watch(boltzSubmarineFeesProvider);

    return totalAmountAsyncValue.when(
      data: (totalAmountToSendValue) {
        final totalFeesValue = fees.when(
          data: (feeData) {
            double percentageFee = sendLiquid
                ? feeData.lbtcFees.percentage / 100 * totalAmountToSendValue
                : feeData.btcFees.percentage / 100 * totalAmountToSendValue;
            return btcInDenominationFormatted(
              percentageFee +
                  (sendLiquid ? feeData.lbtcFees.minerFees : feeData.btcFees.minerFees),
              btcFormat,
            );
          },
          loading: () => 'Loading...',
          error: (error, stack) => 'Error',
        );

        final minAmount = fees.when(
          data: (feeData) => btcInDenominationFormatted(
            double.parse(
              sendLiquid
                  ? feeData.lbtcLimits.minimal.toString()
                  : feeData.btcLimits.minimal.toString(),
            ),
            btcFormat,
          ),
          loading: () => 'Loading...',
          error: (error, stack) => 'Error',
        );

        String formattedTotalAmountToSend = btcInDenominationFormatted(totalAmountToSendValue, btcFormat);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              child: Text(
                'Total fees'.i18n(ref) + ' $totalFeesValue $btcFormat',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Total amount to send'.i18n(ref) + ' $formattedTotalAmountToSend $btcFormat',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Minimum amount'.i18n(ref) + ' $minAmount $btcFormat',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(color: Colors.grey),
      error: (error, stack) => Text(
        'Error: $error',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
