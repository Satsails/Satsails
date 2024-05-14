import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LightningWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ref.watch(boltzReceiveProvider).when(
          data: (data) {
            return Column(
              children: [
                buildQrCode(data.swap!.invoice, context),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildAddressText(data.swap!.invoice, context),
                ),
              ],
            );
          },
          loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: MediaQuery.of(context).size.width * 0.6, color: Colors.orange)),
          error: (error, stack) => Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              alignment: Alignment.center,
              child: Text(
                '$error',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const AmountInput(),
        ref.watch(claimBoltzTransactionStreamProvider).when(
          data: (data) {
            return FutureBuilder(
              future: () async {
                if (data) {
                  await Fluttertoast.showToast(msg: "Transaction Received", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                  ref.read(inputAmountProvider.notifier).state = '0.0';
                  ref.read(inputCurrencyProvider.notifier).state = 'BTC';
                  return Container(); // return a Widget here
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Waiting for transaction...', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                }
              }(),
              builder: (context, snapshot) {
                return snapshot.data ?? Text('Waiting for transaction...', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold));
              },
            );
          },
          loading: () => const Center(child:Text('Waiting for transaction...', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold))),
          error: (error, stack) => Text('Error: $error'),
        ),
      ],
    );
  }
}