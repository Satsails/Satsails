import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/screens/settings/components/boltz_button_picker.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Complete lightning transactions'.i18n(ref), style: const TextStyle(color: Colors.black, fontSize: 15)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const BoltzButtonPicker(),
            if (button == 'Complete Sending') const Expanded(child: RefundSending()),
            if (button == 'Complete Receiving') const Expanded(child: ClaimReceiving()),
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
                return Center(child: Text('All lightning transactions were complete'.i18n(ref)));
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
            error: (error, stackTrace) => Center(child: Text('Error: $error'.i18n(ref))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error'.i18n(ref))),
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
                return Center(child: Text('All lightning transactions were complete'.i18n(ref)));
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
            error: (error, stackTrace) => Center(child: Text('Error: $error'.i18n(ref))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error'.i18n(ref))),
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

  return ListTile(
    leading: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Amount".i18n(ref), style: const TextStyle(fontSize: 13)),
        Text("${btcInDenominationFormatted(amount.toDouble(), btcFormat)} $btcFormat", style: const TextStyle(fontSize: 13)),
      ],
    ),
    onTap: () {
      showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              Column(
                children: [
                  Text('Pay to complete'.i18n(ref), style: const TextStyle(fontSize: 20)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: buildQrCode(invoice, context)),
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.money_off, color: Colors.orangeAccent),
                title: kind == 'reverse' ? Text('Claim'.i18n(ref)) : Text('Refund'.i18n(ref)),
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
                title: Text('Delete'.i18n(ref)),
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
            children: [
              Text('Type'.i18n(ref), style: TextStyle(fontSize: 13)),
              Text(kind, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    ),
    subtitle: Center(child: Text('${isBitcoin ? 'Bitcoin' : 'Liquid'}', style: const TextStyle(fontSize: 13))),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text('Invoice'.i18n(ref), style: TextStyle(fontSize: 13)),
            Text('...${invoice.substring(invoice.length - 7)}', style: const TextStyle(fontSize: 13)),
          ],
        ),
      ],
    ),
  );
}
