import 'package:Satsails/providers/purchase_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    final userPurchasesState = ref.watch(getUserPurchasesProvider);

    return userPurchasesState.when(
      data: (_) {
        final pixHistory = ref.watch(transactionNotifierProvider).pixPurchaseTransactions;

        if (pixHistory.isEmpty) {
          return Center(
            child: Text(
              'No Pix transactions'.i18n(ref),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        pixHistory.sort((a, b) => b.pixDetails.createdAt.compareTo(a.pixDetails.createdAt));

        return ListView.builder(
          itemCount: pixHistory.length,
          itemBuilder: (context, index) {
            final pix = pixHistory[index];
            const double dynamicMargin = 10.0;
            const double dynamicRadius = 10.0;
            final remainingTime = _getRemainingTime(pix.pixDetails.createdAt);

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
                  ref.read(selectedPurchaseIdProvider.notifier).state = pix.pixDetails.id;
                  context.push('/pix_transaction_details');
                },
                child: ListTile(
                  leading: Icon(
                    isFrontendExpired && !pix.pixDetails.completedTransfer && !pix.pixDetails.sentToHotWallet
                        ? Icons.error_rounded
                        : pix.pixDetails.completedTransfer
                        ? Icons.check_circle_rounded
                        : Icons.arrow_downward_rounded,
                    color: isFrontendExpired && !pix.pixDetails.completedTransfer && !pix.pixDetails.sentToHotWallet
                        ? Colors.red
                        : pix.pixDetails.completedTransfer
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFrontendExpired && !pix.pixDetails.completedTransfer && !pix.pixDetails.sentToHotWallet
                            ? "Transaction failed".i18n(ref)
                            : pix.pixDetails.sentToHotWallet
                            ? "Payment received".i18n(ref)
                            : pix.pixDetails.completedTransfer
                            ? "${"Received".i18n(ref)} ${pix.pixDetails.receivedAmount % 1 == 0 ? pix.pixDetails.receivedAmount.toInt() : pix.pixDetails.receivedAmount.toStringAsFixed(3)}"
                            : pix.pixDetails.processingStatus && !pix.pixDetails.sentToHotWallet
                            ? "Waiting payment".i18n(ref)
                            : "${"Received".i18n(ref)} ${pix.pixDetails.receivedAmount % 1 == 0 ? pix.pixDetails.receivedAmount.toInt() : pix.pixDetails.receivedAmount.toStringAsFixed(3)}",
                        style: TextStyle(
                          color: isFrontendExpired && !pix.pixDetails.completedTransfer && !pix.pixDetails.sentToHotWallet
                              ? Colors.red
                              : pix.pixDetails.completedTransfer
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      if (!pix.pixDetails.completedTransfer && !pix.pixDetails.sentToHotWallet && remainingTime.inSeconds > 0)
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
                      if (pix.pixDetails.sentToHotWallet && pix.pixDetails.processingStatus)
                        Text(
                          "Processing transfer".i18n(ref),
                          style: const TextStyle(color: Colors.orange),
                        ),
                      if (pix.pixDetails.completedTransfer && !pix.pixDetails.sentToHotWallet)
                        Text(
                          "Completed".i18n(ref),
                          style: const TextStyle(color: Colors.green),
                        ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(pix.pixDetails.createdAt.toLocal()),
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
                      const SizedBox(height: 2),
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
          child: MessageDisplay(message: error.toString()),
        ),
      ),
    );
  }
}