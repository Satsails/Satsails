import 'package:Satsails/providers/pix_transaction_details_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/error_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';

class PixHistory extends ConsumerStatefulWidget {
  const PixHistory({super.key});

  @override
  _PixHistoryState createState() => _PixHistoryState();
}

class _PixHistoryState extends ConsumerState<PixHistory> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  Duration _getRemainingTime(DateTime createdAt) {
    final timeSinceCreation = DateTime.now().difference(createdAt);
    return const Duration(minutes: 4) - timeSinceCreation;
  }

  @override
  Widget build(BuildContext context) {
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
            final remainingTime = _getRemainingTime(pix.createdAt);

            // Check if the transaction is "expired" for the user (4 minutes timeout)
            final isFrontendExpired = remainingTime.inSeconds <= 0;

            return Container(
              margin: const EdgeInsets.all(dynamicMargin),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 29, 29, 29),
                borderRadius: BorderRadius.circular(dynamicRadius),
              ),
              child: InkWell(
                onTap: () {
                  ref.read(singleTransactionDetailsProvider.notifier).setTransaction(pix);
                  context.push('/pix_transaction_details');
                },
                child: ListTile(
                  leading: Icon(
                    isFrontendExpired && !pix.completedTransfer && !pix.sentToHotWallet
                        ? Icons.error_rounded // Show error if frontend expired and not completed/sent to hot wallet
                        : pix.completedTransfer
                        ? Icons.check_circle_rounded
                        : Icons.arrow_downward_rounded,
                    color: isFrontendExpired && !pix.completedTransfer && !pix.sentToHotWallet
                        ? Colors.red
                        : pix.completedTransfer
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrontendExpired && !pix.completedTransfer && !pix.sentToHotWallet
                            ? "Transaction failed".i18n(ref)
                            : pix.sentToHotWallet
                            ? "Payment received".i18n(ref)
                            : pix.completedTransfer
                            ? "${"Received".i18n(ref)} ${pix.receivedAmount % 1 == 0 ? pix.receivedAmount.toInt() : pix.receivedAmount.toStringAsFixed(3)}"
                            : pix.processingStatus && !pix.sentToHotWallet
                            ? "Waiting payment".i18n(ref)
                            : "${"Received".i18n(ref)} ${pix.receivedAmount % 1 == 0 ? pix.receivedAmount.toInt() : pix.receivedAmount.toStringAsFixed(3)}",
                        style: TextStyle(
                          color: isFrontendExpired && !pix.completedTransfer && !pix.sentToHotWallet
                              ? Colors.red
                              : pix.completedTransfer
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      if (!pix.completedTransfer && !pix.sentToHotWallet && remainingTime.inSeconds > 0)
                        Text(
                          'Time left:'.i18n(ref) +
                              ' ${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.orange, fontSize: 16),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pix.sentToHotWallet && pix.processingStatus)
                        Text(
                          "Processing transfer".i18n(ref),
                          style: const TextStyle(color: Colors.orange),
                        ),
                      if (pix.completedTransfer && !pix.sentToHotWallet)
                        Text(
                          "Completed".i18n(ref),
                          style: const TextStyle(color: Colors.green),
                        ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Text(
                              "CPF: ${pix.cpf}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(pix.createdAt.toLocal()),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    children: [
                      Text("ID: ${pix.id}", style: const TextStyle(color: Colors.grey)),
                      SizedBox(height: 2),
                      const Icon(Icons.receipt_long, color: Colors.green, size: 30),
                    ],
                  ),
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
          child: ErrorDisplay(message: error.toString(), isCard: true),
        ),
      ),
    );
  }
}
