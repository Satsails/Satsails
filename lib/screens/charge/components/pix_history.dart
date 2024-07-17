import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PixHistory extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixHistory = ref.watch(getUserTransactionsProvider);

    return pixHistory.when(
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Text('No Pix transactions'.i18n(ref)),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(dynamicRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  if (pix.receipt != null) {
                    if (await canLaunch(pix.receipt!)) {
                      await launch(pix.receipt!);
                    } else {
                      throw 'Could not launch ${pix.receipt}';
                    }
                  }
                },
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.orange),
                  title: Text(pix.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Received: ${pix.sentAmount} BRL"),
                      const Text("Tap to view receipt"),
                      if (pix.sentTxid == null)
                        Container(
                          margin: EdgeInsets.only(top: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(dynamicRadius),
                          ),
                          child: Text(
                            "Transaction still pending, or maximum value of 5000 per CPF has been reached and depix will be transferred on next available day",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.receipt_long, color: Colors.green),
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
        child: const Center(
          child: Text('An error has occurred. Please check your internet connection or contact support'),
        ),
      ),
    );
  }
}
