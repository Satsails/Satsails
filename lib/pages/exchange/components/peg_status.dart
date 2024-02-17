import 'package:flutter/material.dart';
import '../../../providers/transactions_provider.dart';

class PegStatusSheet extends StatelessWidget {
  final Stream<dynamic> pegStatus;

  PegStatusSheet({required this.pegStatus});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return StreamBuilder<dynamic>(
          stream: pegStatus,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              Map<String, dynamic> transactionData = snapshot.data!["result"];
              saveTransactionData(transactionData); // Save the transaction data
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Transaction Status: ${transactionData["list"]['status']}"),
                    Text("Amount to receive after fees: ${transactionData["list"]['payout']}"),
                    Text("txid: ${transactionData["list"]['payout_txid']}"),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}