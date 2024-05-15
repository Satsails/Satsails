import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/screens/settings/components/boltz_button_picker.dart';
import 'package:Satsails/screens/shared/offline_transaction_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ClaimBoltz extends ConsumerWidget {
  ClaimBoltz({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(settingsProvider).online;
    final button = ref.watch(selectedButtonProvider);

    return  Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Exchange'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BoltzButtonPicker(),
            OfflineTransactionWarning(online: online),
            if(button == 'Refund Sending')  const Expanded(child: RefundSending()),
            if(button == 'Claim Receiving') const Expanded(child: ClaimReceiving()),
          ],
        ),
      ),
    );
  }
}

class ClaimReceiving extends ConsumerWidget {
  const ClaimReceiving({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(receivedBoltzProvider);

    return Container(
      child: transactions.when(
        data: (List<Boltz> boltz) {
          return ListView.builder(
            itemCount: boltz.length,
            itemBuilder: (context, index) {
              final tx = boltz[index];
              return buildBoltzItem(tx, context, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}


class RefundSending extends ConsumerWidget {
  const RefundSending({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(payedBoltzProvider);

    return Container(
      child: transactions.when(
        data: (List<Boltz> boltz) {
          return ListView.builder(
            itemCount: boltz.length,
            itemBuilder: (context, index) {
              final tx = boltz[index];
              return buildBoltzItem(tx, context, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

Widget buildBoltzItem(Boltz boltz, BuildContext context, WidgetRef ref) {
  final btcFormat = ref.watch(settingsProvider).btcFormat;
  return ListTile(
    leading: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Amount", style: TextStyle(fontSize: 13)),
        Text("${btcInDenominationFormatted(boltz.swap.outAmount.toDouble(), btcFormat)}$btcFormat", style: const TextStyle(fontSize: 13)),
      ],
    ),
    onTap: () {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.money_off, color: Colors.orangeAccent),
                title: const Text('Claim'),
                onTap: () async {
                  try {
                    await ref.read(claimSingleBoltzTransactionProvider(boltz.swap.id).future).then((value) => value);
                    ref.refresh(receivedBoltzProvider);
                    ref.refresh(payedBoltzProvider);
                    Fluttertoast.showToast(msg:"Claimed" , toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () async {
                  try {
                    await ref.read(deleteSingleBoltzTransactionProvider(boltz.swap.id).future);
                    await ref.read(deleteSingleBoltzTransactionProvider(boltz.swap.id).future);
                    ref.refresh(receivedBoltzProvider);
                    ref.refresh(payedBoltzProvider);
                    Fluttertoast.showToast(msg: "Deleted", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
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
        Column(
          children: [
            const Text('Type', style: TextStyle(fontSize: 13)),
            Text(boltz.swap.kind.name, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ],
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            const Text('Invoice', style: TextStyle(fontSize: 13)),
            Text('...${boltz.swap.invoice.substring(boltz.swap.invoice.length - 7)}', style: const TextStyle(fontSize: 13)),
          ],
        ),
      ],
    ),
  );
}