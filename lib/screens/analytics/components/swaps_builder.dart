import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/models/sideswap_peg_model.dart';
import 'package:satsails/providers/sideswap_provider.dart';

class SwapsBuilder extends ConsumerWidget {
  const SwapsBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSwaps = ref.watch(sideswapAllPegsProvider);

    return allSwaps.when(
      data: (swaps) {
        return ListView.builder(
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return _buildTransactionItem(swap, context, ref);
          },
        );
      },
      loading: () => LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

Widget _buildTransactionItem(swap, BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _buildSwapTransactionItem(swap, context, ref),
    );
  }

Widget _buildSwapTransactionItem(SideswapPegStatus swap, BuildContext context, WidgetRef ref) {
  return Column(
    children: [
      Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.swap_calls_rounded, color: Colors.orange),
          title: Center(child: Text(_timestampToDateTime(swap.createdAt!), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              swap.pegIn! ? const Text("Bitcoin", style: TextStyle(fontSize: 16)) : const Text("Liquid Bitcoin", style: TextStyle(fontSize: 16)),
              const Icon(Icons.arrow_forward, color: Colors.orange),
              swap.pegIn! ? const Text("Liquid", style: TextStyle(fontSize: 16)) : const Text("Bitcoin", style: TextStyle(fontSize: 16)),
            ],
          ),
          trailing: _statusIcon(swap.list),
          onExpansionChanged: (isExpanded) {
            if (isExpanded) {
              ref.read(orderIdStatusProvider.notifier).state = swap.orderId!;
              ref.read(pegInStatusProvider.notifier).state = swap.pegIn!;
              ref.refresh(sideswapStatusDetailsItemProvider);
            }
          },
          children: <Widget>[
            Consumer(builder: (context, watch, child) {
              final updatedSwapStatus = ref.watch(sideswapStatusDetailsItemProvider);
              return updatedSwapStatus.when(
                data: (status) {
                  return Column(
                    children: [
                      ListTile(
                        title: const Text("Order ID"),
                        subtitle: Text(status.orderId ?? "Error"),
                      ),
                      ListTile(
                        title: const Text("Received at"),
                        subtitle: Text(status.addrRecv ?? "Error"),
                      ),
                      ...status.list?.map((SideswapPegStatusTransaction e) {
                        return Column(
                          children: [
                            ListTile(
                              title: const Text("Send Transaction"),
                              subtitle: Text(e.txHash ?? "Error"),
                            ),
                            ListTile(
                              title: const Text("Received Transaction"),
                              subtitle: Text(e.payoutTxid ?? "Error"),
                            ),
                            ListTile(
                              title: const Text("Amount sent"),
                              subtitle: Text(e.amount.toString()),
                            ),
                            ListTile(
                              title: const Text("Amount received"),
                              subtitle: Text(e.payout.toString()),
                            ),
                            ListTile(
                              title: const Text("Status"),
                              subtitle: Text(e.status ?? "Error"),
                            ),
                            _buildTxStatusTile(e),
                          ],
                        );
                      }).toList() ?? [const Text('No transactions found. Check back later.')],
                    ],
                  );
                },
                loading: () => LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange),
                error: (error, stackTrace) => Center(child: Text('Error: $error')),
              );
            }),
          ],
        ),
      ),
    ],
  );
}

ListTile _buildTxStatusTile(SideswapPegStatusTransaction status) {
  switch (status.txState) {
    case 'InsufficientAmount':
      return const ListTile(
        title: Text("Status"),
        subtitle: Text("Insufficient Amount"),
      );
    case 'Detected':
      return ListTile(
        title: const Text("Confirmations"),
        subtitle: Text("${status.detectedConfs} Detected"),
        trailing: Text("${status.totalConfs} Total needed"),
      );
    case 'Processing':
      return const ListTile(
        title: Text("Status"),
        subtitle: Text("Processing"),
      );
    case 'Done':
      return const ListTile(
        title: Text("Status"),
        subtitle: Text("Done"),
      );
    default:
      return const ListTile(
        title: Text("Status"),
        subtitle: Text("Unknown"),
      );
  }
}

String _timestampToDateTime(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${date.day}/${date.month}/${date.year}";
}

Icon _statusIcon(List<SideswapPegStatusTransaction>? transactions) {
  if (transactions == null || transactions.isEmpty) {
    return const Icon(Icons.help, color: Colors.grey);
  }
  var lastTransaction;
  switch (lastTransaction.txState) {
    case 'InsufficientAmount':
      return const Icon(Icons.error, color: Colors.red);
    case 'Detected':
      return const Icon(Icons.search, color: Colors.orange);
    case 'Processing':
      return const Icon(Icons.hourglass_empty, color: Colors.blue);
    case 'Done':
      return const Icon(Icons.check_circle, color: Colors.green);
    default:
      return const Icon(Icons.help, color: Colors.grey);
  }
}