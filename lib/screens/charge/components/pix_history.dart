import 'package:Satsails/providers/pix_transaction_details_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PixHistory extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixHistory = ref.watch(getUserTransactionsProvider);

    return pixHistory.when(
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Text('No Pix transactions'.i18n(ref), style: TextStyle(color: Colors.white)),
          );
        }
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final pix = history[index];
            final double dynamicMargin = 10.0;
            final double dynamicRadius = 10.0;
            return Container(
              margin: EdgeInsets.all(dynamicMargin),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 29, 29, 29),
                borderRadius: BorderRadius.circular(dynamicRadius),
              ),
              child: InkWell(
                onTap: ()  {
                  ref.read(singleTransactionDetailsProvider.notifier).setTransaction(pix);
                  Navigator.of(context).pushNamed('/pix_transaction_details');
                },
                child: ListTile(
                  leading: const Icon(Icons.arrow_downward_rounded, color: Colors.green),
                  title: Text(pix.name, style: TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${"Received".i18n(ref)} ${pix.receivedAmount.toStringAsFixed(2)}", style: TextStyle(color: Colors.green)),
                      if (pix.sentTxid == null)
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(dynamicRadius),
                          ),
                          child: Text(
                            "Transaction still pending".i18n(ref),
                            style: TextStyle(color: Colors.black),
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
          child: Text('An error has occurred. Please check your internet connection or contact support'.i18n(ref), style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
