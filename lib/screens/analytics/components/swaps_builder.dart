import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:satsails/providers/sideswap_provider.dart';
import 'package:satsails/screens/analytics/components/peg_details.dart';

class SwapsBuilder extends ConsumerWidget {
  const SwapsBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSwaps = ref.watch(sideswapAllPegsProvider);
    // TODO once i fix sideswap
    final swapsToFiat = ref.watch(sideswapGetLiquidTxProvider);
    // Map these and create a list these swaps

    return allSwaps.when(
      data: (swaps) {
        if (swaps.isEmpty) {
          return const Center(child: Text('No swaps found', style: TextStyle(fontSize: 20, color: Colors.grey)));
        }
        return ListView.builder(
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return _buildTransactionItem(swap, context, ref);
          },
        );
      },
      loading: () => LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.white),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

Widget _buildTransactionItem(SideswapPegStatus swap, BuildContext context, WidgetRef ref) {
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
      ListTile(
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
        onTap: () {
          ref.read(orderIdStatusProvider.notifier).state = swap.orderId!;
          ref.read(pegInStatusProvider.notifier).state = swap.pegIn!;
          _showDetailsPage(context, swap);
        },
      ),
    ],
  );
}

void _showDetailsPage(BuildContext context, SideswapPegStatus swap) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PegDetails(swap: swap),
    ),
  );
}


String _timestampToDateTime(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}