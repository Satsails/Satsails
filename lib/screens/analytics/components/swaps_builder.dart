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
      GestureDetector(
        onTap: () {
          OrderStatusParams orderStatusParams = OrderStatusParams(
            orderId: swap.orderId!,
            pegIn: swap.pegIn!,
          );
          ref.read(sideswapStatusDetailsItemProvider(orderStatusParams));
          // Navigator.pushReplacementNamed(context, '/search_modal');
        },
        child: ListTile(
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
        ),
      )
    ],
  );
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