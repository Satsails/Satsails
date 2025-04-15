import 'package:Satsails/providers/eulen_transfer_provider.dart';
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
    final pixHistory = ref.watch(transactionNotifierProvider).eulenTransactions;

    pixHistory.sort((a, b) => b.details.createdAt.compareTo(a.details.createdAt));

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
              ref.read(selectedEulenTransferIdProvider.notifier).state = pix.details.id;
              context.push('/pix_transaction_details');
            },
            child: ListTile(
              leading: Icon(
                pix.details.failed
                    ? Icons.error_rounded
                    : pix.details.completed
                    ? Icons.check_circle_rounded
                    : Icons.arrow_downward_rounded,
                color: pix.details.failed
                    ? Colors.red
                    : pix.details.completed
                    ? Colors.green
                    : Colors.orange,
              ),
              title: Text(
                pix.details.failed
                    ? "Transaction failed".i18n
                    : pix.details.completed
                    ? "${"Received".i18n} ${pix.details.receivedAmount % 1 == 0 ? pix.details.receivedAmount.toInt() : pix.details.receivedAmount.toStringAsFixed(3)}"
                    : "Pending payment".i18n,
                style: TextStyle(
                  color: pix.details.failed
                      ? Colors.red
                      : pix.details.completed
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pix.details.completed)
                      Text(
                        "Completed".i18n,
                        style: const TextStyle(color: Colors.green),
                      ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(pix.details.createdAt.toLocal()),
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
