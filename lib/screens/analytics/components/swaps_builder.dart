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
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: _buildSwapTransactionItem(swap, context, ref),
    );
  }

Widget _buildSwapTransactionItem(SideswapPegStatus swap, BuildContext context, WidgetRef ref) {
  return Column(
    children: [
      // GestureDetector(
      //   onTap: () {
      //     OrderStatusParams orderStatusParams = OrderStatusParams(
      //       orderId: swap.orderId!,
      //       pegIn: swap.pegIn!,
      //     );
      //     ref.read(sideswapStatusDetailsItemProvider(orderStatusParams));
      //     // Navigator.pushReplacementNamed(context, '/search_modal');
      //   },
      //   child: ListTile(
      //     leading: const Icon(Icons.switch_access_shortcut_outlined, color: Colors.orange),
      //     title: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Text(_transactionTypeString(transaction), style: const TextStyle(fontSize: 16)),
      //         Text(_transactionAmount(transaction, ref),style: const TextStyle(fontSize: 14)),
      //       ],
      //     ),
      //     // subtitle: Text("Fee: ${_transactionFee(transaction, ref)}", style: const TextStyle(fontSize: 14)),
      //     subtitle: Text(timestampToDateTime(transaction.confirmationTime?.timestamp), style: const TextStyle(fontSize: 14)),
      //     trailing: _confirmationStatus(transaction) == 'Confirmed'
      //         ? const Icon(Icons.check_circle, color: Colors.green)
      //         : const Icon(Icons.access_alarm_outlined, color: Colors.red),
      //   ),
      // )
    ],
  );
}