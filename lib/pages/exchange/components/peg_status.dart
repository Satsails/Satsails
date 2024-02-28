import 'package:flutter/material.dart';
import '../../../providers/transactions_provider.dart';

class PegStatusSheet extends StatelessWidget {
  final Stream<dynamic> pegStatus;

  PegStatusSheet({required this.pegStatus});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: pegStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          Map<String, dynamic> transactionData = snapshot.data!["result"];
          TransactionNotifier().saveTransactionData(transactionData);
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your transaction is being processed and it will be credited to your account. Check analytics below for more information."),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/analytics');
                          },
                          child: const Text("Analytics"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: const Text("Transaction Status"),
                        subtitle: Text(
                          "${transactionData["list"] != null && transactionData["list"].isNotEmpty ? transactionData["list"]['status'] : 'No data'}",
                        ),
                      ),
                      ListTile(
                        title: const Text("Amount to receive after fees"),
                        subtitle: Text(
                          "${transactionData["list"] != null && transactionData["list"].isNotEmpty ? transactionData["list"]['payout'] / 100000000 : 'No data'}",
                        ),
                      ),
                      ListTile(
                        title: const Text("txid"),
                        subtitle: Text(
                          "${transactionData["list"] != null && transactionData["list"].isNotEmpty ? transactionData["list"]['payout_txid'] : 'No data'}",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
