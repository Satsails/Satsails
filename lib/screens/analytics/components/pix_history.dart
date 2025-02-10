import 'package:Satsails/providers/purchase_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PixHistory extends ConsumerWidget {
  const PixHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixHistory = ref.watch(transactionNotifierProvider).pixPurchaseTransactions;

    pixHistory.sort((a, b) => b.pixDetails.createdAt.compareTo(a.pixDetails.createdAt));

    return ListView.builder(
      itemCount: pixHistory.length,
      itemBuilder: (context, index) {
        final pix = pixHistory[index];

        return Container(
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 29, 29, 29),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: () {
              ref.read(selectedPurchaseIdProvider.notifier).state = pix.pixDetails.id;
              context.push('/pix_transaction_details');
            },
            child: ListTile(
              leading: Icon(
                pix.pixDetails.failed
                    ? Icons.error_rounded
                    : pix.pixDetails.completedTransfer
                    ? Icons.check_circle_rounded
                    : Icons.arrow_downward_rounded,
                color: pix.pixDetails.failed
                    ? Colors.red
                    : pix.pixDetails.completedTransfer
                    ? Colors.green
                    : Colors.orange,
              ),
              title: Text(
                pix.pixDetails.failed
                    ? "Transaction failed".i18n
                    : pix.pixDetails.completedTransfer
                    ? "${"Received".i18n} ${pix.pixDetails.receivedAmount % 1 == 0 ? pix.pixDetails.receivedAmount.toInt() : pix.pixDetails.receivedAmount.toStringAsFixed(3)}"
                    : "Pending payment".i18n,
                style: TextStyle(
                  color: pix.pixDetails.failed
                      ? Colors.red
                      : pix.pixDetails.completedTransfer
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pix.pixDetails.completedTransfer)
                      Text(
                        "Completed".i18n,
                        style: const TextStyle(color: Colors.green),
                      ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(pix.pixDetails.createdAt.toLocal()),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("ID: ${pix.id}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Icon(Icons.receipt_long, color: Colors.green, size: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
