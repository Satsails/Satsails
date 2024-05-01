import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            return ListTile(
              title: Text(swap.orderId!),
              // subtitle: Text(swap.),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center
        (child: Text('Error: $error')),
    );
  }
}