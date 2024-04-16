import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/address_model.dart';
import 'package:satsails/models/balance_model.dart';
import 'package:satsails/providers/send_tx_provider.dart';

import '../../../providers/balance_provider.dart';

class ConfirmPayment extends ConsumerWidget {
  TextEditingController amountController = TextEditingController();

  Future<String> confirmAndSendPayment(double amount, String asset,
      String transactionType) async {
    return '';
  }

  void checkMaxAmount(String asset) async {
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceProvider = ref.watch(balanceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'You are sending from ',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    // if liquid check pick asset to send from nice cards. If comes from qr have it pre selected
                    Text(
                      ref.watch(sendTxProvider).type.toString(),
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Divider(),
                    const SizedBox(height: 20.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(
                        //   'Your total balance is: ' + balanceProvider + ' BTC',
                        //   style: TextStyle(
                        //     fontSize: 18.0,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'You are sending a payment to: ',
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      ref
                          .watch(sendTxProvider)
                          .address,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Divider(),
                    const SizedBox(height: 20.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'select fee',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                      //   show nr of blocks and corresponding fee
                      ],
                    ),
                  ],
                ),
              ),
            ),
          // text input field for amount which should be pre selected with what is set in the qr code
          //   should show in what ever currency is selected in settings and in bitcoin.
          //   button to send transaction
          //   send button is disabled if offline
          ],
        ),
      ),
    );
  }
}

void checkAssetBalance(PaymentType paymentType, double amount, Balance balance) {
  if (paymentType == PaymentType.Bitcoin) {
    if (balance.btcBalance < amount) {
      throw Exception('Insufficient balance');
    }
  } else if (paymentType == PaymentType.Liquid) {
    if (balance.liquidBalance < amount) {
      throw Exception('Insufficient balance');
    }
  }
}
