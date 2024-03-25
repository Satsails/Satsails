import 'package:flutter/material.dart';
import 'package:satsails_wallet/providers/transactions_provider.dart';
import 'package:satsails_wallet/helpers/exchange.dart';

class ExchangeStatus extends StatelessWidget {
  final Stream<dynamic> exchangeStatus;
  ExchangeStatus({required this.exchangeStatus});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: exchangeStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildLoadingWidget();
        } else if (snapshot.hasError) {
          return buildErrorWidget(snapshot.error!);
        } else {
          Map<String, dynamic> transactionData = snapshot.data;
          TransactionNotifier().saveExchangeData(transactionData);
          if (isTransactionCompleted(transactionData)) {
            return buildCompletedTransactionWidget(transactionData, context);
          } else {
            WalletStrategy walletStrategy = WalletStrategy();
            walletStrategy.uploadAndSignInputs(transactionData);
            return buildProcessingTransactionWidget(transactionData, context);
          }
        }
      },
    );
  }



  Widget buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.blue,
      ),
    );
  }

  Widget buildErrorWidget(Object error) {
    return Text("Error: $error");
  }

  bool isTransactionCompleted(Map<String, dynamic> transactionData) {
    return transactionData.containsKey("method") && transactionData["method"] == "swap_done";
  }

  Widget buildCompletedTransactionWidget(Map<String, dynamic> transactionData, BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transactionData["params"]["status"] == "Success") ...[
                const Text("Your transaction is completed"),
                const SizedBox(height: 10),
                buildAnalyticsButton(context),
                const SizedBox(height: 10),
                buildTransactionDetailsWidget(transactionData),
              ] else ...[
                const Text("Transaction failed, please try again.", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Text("Error: ${transactionData["params"]["status"]}"),
                const SizedBox(height: 10),
                Text("No funds were deducted from your account."),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }



  Widget buildProcessingTransactionWidget(Map<String, dynamic> transactionData, context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "Your transaction is being processed and it will be credited to your account."),
                const SizedBox(height: 10),
                buildLoadingWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAnalyticsButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/analytics');
        },
        child: const Text("Analytics"),
      ),
    );
  }

  Widget buildTransactionDetailsWidget(Map<String, dynamic> transactionData) {
    return Column(
      children: [
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
    );
  }
}
