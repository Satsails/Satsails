import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/providers/send_tx_provider.dart';

class ConfirmPayment extends ConsumerWidget {
  TextEditingController amountController = TextEditingController();

  Future<String> confirmAndSendPayment(double amount, String asset, String transactionType) async {
    return '';
  }

  void checkMaxAmount(String asset) async {
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You are sending a payment to: ',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Text(
              ref.watch(sendTxProvider).address,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Send:',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
