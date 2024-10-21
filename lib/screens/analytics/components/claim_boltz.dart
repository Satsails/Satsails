import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

class ClaimBoltz extends ConsumerWidget {
  ClaimBoltz({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Expanded(child: AllTransactions()),
      ),
    );
  }
}

class AllTransactions extends ConsumerWidget {
  const AllTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(allTransactionsProvider);

    return allTransactions.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Center(
            child: Text(
              'No transactions'.i18n(ref),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final txData = transactions[index];
            final tx = txData['tx'];
            final isBitcoin = txData['isBitcoin'];
            final isSending = txData['isSending'];
            return buildBoltzItem(
              liquidTx: isBitcoin ? null : tx as LbtcBoltz,
              bitcoinTx: isBitcoin ? tx as BtcBoltz : null,
              context: context,
              ref: ref,
              isBitcoin: isBitcoin,
              isSending: isSending,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error: $error'.i18n(ref),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

Widget buildBoltzItem({
  required LbtcBoltz? liquidTx,
  required BtcBoltz? bitcoinTx,
  required BuildContext context,
  required WidgetRef ref,
  required bool isBitcoin,
  required bool isSending,
}) {
  // Safely cast the correct type
  final amount = isBitcoin ? bitcoinTx!.swap.outAmount : liquidTx!.swap.outAmount;
  final timestamp = isBitcoin ? bitcoinTx!.timestamp : liquidTx!.timestamp;
  final network = isBitcoin ? 'Bitcoin' : 'Liquid Bitcoin';

  return Container(
    margin: const EdgeInsets.all(8.0),
    decoration: BoxDecoration(
      color: const Color(0xFF2E2E2E),
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.swap_horizontal_circle_outlined, color: Colors.orange),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lightning swap'.i18n(ref),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _timestampToDateTime(timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          subtitle: Column(
            children: [
              Text(
                "${btcInDenominationFormatted(amount.toDouble(), ref.watch(settingsProvider).btcFormat)} ${ref.watch(settingsProvider).btcFormat}",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    isSending ? "Sending".i18n(ref) : "Receiving".i18n(ref),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      const Icon(Icons.arrow_forward, color: Colors.orange, size: 30),
                      Text("More Details".i18n(ref), style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ],
                  ),
                  Text(
                    network,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            context.push(
              '/boltz_transaction_details',
              extra: {
                'isBitcoin': isBitcoin,
                'transaction': isBitcoin ? bitcoinTx : liquidTx,
              },
            );
          },
        ),
      ],
    ),
  );
}

String _timestampToDateTime(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}