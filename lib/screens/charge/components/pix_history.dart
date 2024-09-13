import 'package:Satsails/providers/pix_transaction_details_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PixHistory extends ConsumerWidget {
  const PixHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixHistory = ref.watch(getUserTransactionsProvider);

    return pixHistory.when(
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Text(
              'No Pix transactions'.i18n(ref),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final pix = history[index];
            const double dynamicMargin = 10.0;
            const double dynamicRadius = 10.0;
            return Container(
              margin: const EdgeInsets.all(dynamicMargin),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 29, 29, 29),
                borderRadius: BorderRadius.circular(dynamicRadius),
              ),
              child: InkWell(
                onTap: ()  {
                  ref.read(singleTransactionDetailsProvider.notifier).setTransaction(pix);
                  Navigator.of(context).pushNamed('/pix_transaction_details');
                },
                child: ListTile(
                  leading: const Icon(Icons.arrow_downward_rounded, color: Colors.green),
                  title:Text(
                      pix.receivedAmount == 0.0
                          ? "Waiting".i18n(ref)
                          : "${"Received".i18n(ref)} ${pix.receivedAmount % 1 == 0 ? pix.receivedAmount.toInt() : pix.receivedAmount.toStringAsFixed(3)}",
                      style: const TextStyle(color: Colors.green)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pix.completedTransfer == false)
                        Text(
                          "Transaction still pending".i18n(ref),
                          style: const TextStyle(color: Colors.orange),
                        ),
                      // Displaying the createdAt date
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(pix.createdAt.toLocal()),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.receipt_long, color: Colors.green, size: 30),
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          size: MediaQuery.of(context).size.height * 0.1,
          color: Colors.orange,
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'An error has occurred. Please check your internet connection or contact support'.i18n(ref),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
