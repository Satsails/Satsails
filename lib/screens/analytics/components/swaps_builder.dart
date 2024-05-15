import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/providers/conversion_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/screens/analytics/components/peg_details.dart';

class SwapsBuilder extends ConsumerWidget {
  const SwapsBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSwaps = ref.watch(sideswapAllPegsProvider);
    final swapsToFiat = ref.watch(sideswapGetSwapsProvider);

    return allSwaps.when(
      data: (swaps) {
        return swapsToFiat.when(
          data: (fiatSwaps) {
            final combinedSwaps = [...swaps, ...fiatSwaps];
            if (combinedSwaps.isEmpty) {
              return Center(child: Text('No swaps found'.i18n(ref), style: const TextStyle(fontSize: 20, color: Colors.grey)));
            }
            return ListView.builder(
              itemCount: combinedSwaps.length,
              itemBuilder: (context, index) {
                final swap = combinedSwaps[index];
                if (swap is SideswapPegStatus) {
                  return _buildTransactionItem(swap, context, ref);
                } else if (swap is SideswapCompletedSwap) {
                  return _buildFiatTransactionItem(swap, context, ref);
                } else {
                  throw Exception('Unknown swap type');
                }
              },
            );
          },
          loading: () => LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.white),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        );
      },
      loading: () => LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.white),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

Widget _buildFiatTransactionItem(SideswapCompletedSwap swap, BuildContext context, WidgetRef ref) {
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
      child: _buildFiatSwapTransactionItem(swap, context, ref),
    );
  }

  Widget _buildFiatSwapTransactionItem(SideswapCompletedSwap swap, BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.swap_calls_rounded, color: Colors.orange),
          title: Center(child: Text("Fiat Swap".i18n(ref), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(_assetNameFromTicker(AssetMapper.mapAsset(swap.sendAsset)), style: const TextStyle(fontSize: 16)),
                  Text(
                      _assetNameFromTicker(AssetMapper.mapAsset(swap.sendAsset)) == 'BTC'
                          ? ref.watch(conversionProvider(swap.sendAmount.toInt()))
                          : (swap.sendAmount / 100000000).toStringAsFixed(2),
                      style: const TextStyle(fontSize: 16)
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward, color: Colors.orange),
              Column(
                children: [
                  Text(_assetNameFromTicker(AssetMapper.mapAsset(swap.recvAsset)), style: const TextStyle(fontSize: 16)),
                  Text(
                      _assetNameFromTicker(AssetMapper.mapAsset(swap.recvAsset)) == 'BTC'
                          ? ref.watch(conversionProvider((swap.recvAmount).toInt()))
                          : (swap.recvAmount / 100000000).toStringAsFixed(2),
                      style: const TextStyle(fontSize: 16)
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            ref.read(transactionSearchProvider).isLiquid = true;
            ref.read(transactionSearchProvider).txid = swap.txid;
            Navigator.pushNamed(context, '/search_modal');
          },
        ),
      ],
    );
  }

  String _assetNameFromTicker(AssetId ticker) {
    switch (ticker) {
      case AssetId.USD:
        return 'USD';
      case AssetId.LBTC:
        return 'BTC';
      case AssetId.EUR:
        return 'EUR';
      case AssetId.BRL:
        return 'BRL';
      default:
        return 'UNKNOWN';
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
        leading: const Icon(Icons.swap_horizontal_circle, color: Colors.orange),
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