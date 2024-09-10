import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/screens/settings/components/boltz_button_picker.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClaimBoltz extends ConsumerWidget {
  ClaimBoltz({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final button = ref.watch(selectedButtonProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Lightning transactions'.i18n(ref), style: const TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const BoltzButtonPicker(),
            if (button == 'Sending') const Expanded(child: RefundSending()),
            if (button == 'Receiving') const Expanded(child: ClaimReceiving()),
          ],
        ),
      ),
    );
  }
}

class ClaimReceiving extends ConsumerWidget {
  const ClaimReceiving({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsLiquid = ref.watch(receivedBoltzProvider);
    final transactionsBitcoin = ref.watch(receivedBitcoinBoltzProvider);

    return Container(
      child: transactionsLiquid.when(
        data: (List<LbtcBoltz> liquidTransactions) {
          return transactionsBitcoin.when(
            data: (List<BtcBoltz> bitcoinTransactions) {
              if (liquidTransactions.isEmpty && bitcoinTransactions.isEmpty) {
                return Center(child: Text('All lightning transactions were complete'.i18n(ref), style: const TextStyle(color: Colors.white)));
              }
              return ListView.builder(
                itemCount: liquidTransactions.length + bitcoinTransactions.length,
                itemBuilder: (context, index) {
                  if (index < liquidTransactions.length) {
                    final tx = liquidTransactions[index];
                    return buildBoltzItem(tx, null, context, ref, isBitcoin: false);
                  } else {
                    final tx = bitcoinTransactions[index - liquidTransactions.length];
                    return buildBoltzItem(null, tx, context, ref, isBitcoin: true);
                  }
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error'.i18n(ref), style: const TextStyle(color: Colors.white))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error'.i18n(ref), style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

class RefundSending extends ConsumerWidget {
  const RefundSending({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsLiquid = ref.watch(payedBoltzProvider);
    final transactionsBitcoin = ref.watch(payedBitcoinBoltzProvider);

    return Container(
      child: transactionsLiquid.when(
        data: (List<LbtcBoltz> liquidTransactions) {
          return transactionsBitcoin.when(
            data: (List<BtcBoltz> bitcoinTransactions) {
              if (liquidTransactions.isEmpty && bitcoinTransactions.isEmpty) {
                return Center(child: Text('All lightning transactions were complete'.i18n(ref), style: const TextStyle(color: Colors.white)));
              }
              return ListView.builder(
                itemCount: liquidTransactions.length + bitcoinTransactions.length,
                itemBuilder: (context, index) {
                  if (index < liquidTransactions.length) {
                    final tx = liquidTransactions[index];
                    return buildBoltzItem(tx, null, context, ref, isBitcoin: false);
                  } else {
                    final tx = bitcoinTransactions[index - liquidTransactions.length];
                    return buildBoltzItem(null, tx, context, ref, isBitcoin: true);
                  }
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error'.i18n(ref), style: const TextStyle(color: Colors.white))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error'.i18n(ref), style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

Widget buildBoltzItem(LbtcBoltz? liquidTx, BtcBoltz? bitcoinTx, BuildContext context, WidgetRef ref, {required bool isBitcoin}) {
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  final tx = isBitcoin ? bitcoinTx as BtcBoltz : liquidTx as LbtcBoltz;
  final amount = isBitcoin ? bitcoinTx!.swap.outAmount : liquidTx!.swap.outAmount;
  final invoice = isBitcoin ? bitcoinTx!.swap.invoice : liquidTx!.swap.invoice;
  final kind = isBitcoin ? bitcoinTx!.swap.kind.name : liquidTx!.swap.kind.name;
  final timestamp = isBitcoin ? bitcoinTx!.timestamp : liquidTx!.timestamp;  // Assuming the timestamp is present

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
    child: Card(
      color: const Color(0xFF2E2E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      elevation: 2.0, // Add a shadow
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_timestampToDateTime(timestamp), style: TextStyle(fontSize: MediaQuery.of(context).size.width < 400 ? 10 : 13, color: Colors.white)),
            Text("Amount".i18n(ref), style: const TextStyle(fontSize: 13, color: Colors.orange)),
            Text("${btcInDenominationFormatted(amount.toDouble(), btcFormat)} $btcFormat", style: const TextStyle(fontSize: 13, color: Colors.white)),
          ],
        ),
        onTap: () {
          showModalBottomSheet(
            backgroundColor: Colors.black,
            context: context,
            builder: (context) {
              return Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.money_off, color: Colors.orangeAccent),
                    title: kind == 'reverse' ? Text('Claim'.i18n(ref), style: const TextStyle(color: Colors.white)) : Text('Refund'.i18n(ref), style: const TextStyle(color: Colors.white)),
                    onTap: () async {
                      try {
                        if (isBitcoin) {
                          if (kind == 'reverse') {
                            await ref.read(claimSingleBitcoinBoltzTransactionProvider((tx as BtcBoltz).swap.id).future).then((value) => value);
                          } else {
                            await ref.read(refundSingleBitcoinBoltzTransactionProvider((tx as BtcBoltz).swap.id).future).then((value) => value);
                          }
                          ref.refresh(receivedBitcoinBoltzProvider);
                          ref.refresh(payedBitcoinBoltzProvider);
                        } else {
                          if (kind == 'reverse') {
                            await ref.read(claimSingleBoltzTransactionProvider((tx as LbtcBoltz).swap.id).future).then((value) => value);
                          } else {
                            await ref.read(refundSingleBoltzTransactionProvider((tx as LbtcBoltz).swap.id).future).then((value) => value);
                          }
                          ref.refresh(receivedBoltzProvider);
                          ref.refresh(payedBoltzProvider);
                        }
                        Fluttertoast.showToast(msg: "Claimed".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                      }
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'.i18n(ref), style: const TextStyle(color: Colors.white)),
                    onTap: () async {
                      try {
                        if (isBitcoin) {
                          await ref.read(deleteSingleBitcoinBoltzTransactionProvider((tx as BtcBoltz).swap.id).future);
                          ref.refresh(receivedBitcoinBoltzProvider);
                          ref.refresh(payedBitcoinBoltzProvider);
                        } else {
                          await ref.read(deleteSingleBoltzTransactionProvider((tx as LbtcBoltz).swap.id).future);
                          ref.refresh(receivedBoltzProvider);
                          ref.refresh(payedBoltzProvider);
                        }
                        Fluttertoast.showToast(msg: "Deleted".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Type: '.i18n(ref), style: const TextStyle(fontSize: 13, color: Colors.orange)),
                  Text(kind, style: const TextStyle(fontSize: 13, color: Colors.orange)),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text(isBitcoin ? 'Bitcoin' : 'Liquid', style: const TextStyle(fontSize: 13, color: Colors.white)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Invoice'.i18n(ref), style: const TextStyle(fontSize: 13, color: Colors.orange)),
                Text('...${invoice.substring(invoice.length - 7)}', style: const TextStyle(fontSize: 13, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

String _timestampToDateTime(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}

