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
    final screenWidth = MediaQuery.of(context).size.width;
    final allSwaps = ref.watch(sideswapAllPegsProvider);
    final swapsToFiat = ref.watch(sideswapGetSwapsProvider);

    return allSwaps.when(
      data: (swaps) {
        return swapsToFiat.when(
          data: (fiatSwaps) {
            final combinedSwaps = [...swaps, ...fiatSwaps];
            if (combinedSwaps.isEmpty) {
              return Center(child: Text('No swaps found'.i18n(ref), style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white)));
            }
            return ListView.builder(
              itemCount: combinedSwaps.length,
              itemBuilder: (context, index) {
                final swap = combinedSwaps[index];
                if (swap is SideswapPegStatus) {
                  return _buildTransactionItem(swap, context, ref, screenWidth);
                } else if (swap is SideswapCompletedSwap) {
                  return _buildFiatTransactionItem(swap, context, ref, screenWidth);
                } else {
                  throw Exception('Unknown swap type');
                }
              },
            );
          },
          loading: () => LoadingAnimationWidget.threeArchedCircle(size: screenWidth * 0.5, color: Colors.white),
          error: (error, stackTrace) => Center(child: Text('Error: $error', style: TextStyle(fontSize: screenWidth * 0.05))),
        );
      },
      loading: () => LoadingAnimationWidget.threeArchedCircle(size: screenWidth * 0.5, color: Colors.white),
      error: (error, stackTrace) => Center(child: Text('Error: $error', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white))),
    );
  }

  Widget _buildFiatTransactionItem(SideswapCompletedSwap swap, BuildContext context, WidgetRef ref, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.circular(screenWidth * 0.0375),
      ),
      child: _buildFiatSwapTransactionItem(swap, context, ref, screenWidth),
    );
  }

  Widget _buildFiatSwapTransactionItem(SideswapCompletedSwap swap, BuildContext context, WidgetRef ref, double screenWidth) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.swap_calls_rounded, color: Colors.orange),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text("Fiat Swap".i18n(ref), style: TextStyle(fontSize: screenWidth * 0.0375, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(_assetNameFromTicker(AssetMapper.mapAsset(swap.sendAsset)), style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                      _assetNameFromTicker(AssetMapper.mapAsset(swap.sendAsset)) == 'BTC'
                          ? ref.watch(conversionProvider(swap.sendAmount.toInt()))
                          : (swap.sendAmount / 100000000).toStringAsFixed(2),
                      style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(width: screenWidth * 0.1),
              Column(
                children: [
                  const Icon(Icons.arrow_forward, color: Colors.orange, size: 30),
                  Text("More Details".i18n(ref), style: TextStyle(fontSize: screenWidth * 0.02, color: Colors.white)),
                ],
              ),
              Column(
                children: [
                  Text(_assetNameFromTicker(AssetMapper.mapAsset(swap.recvAsset)), style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                      _assetNameFromTicker(AssetMapper.mapAsset(swap.recvAsset)) == 'BTC'
                          ? ref.watch(conversionProvider((swap.recvAmount).toInt()))
                          : (swap.recvAmount / 100000000).toStringAsFixed(2),
                      style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
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

  Widget _buildTransactionItem(SideswapPegStatus swap, BuildContext context, WidgetRef ref, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.circular(screenWidth * 0.0375),
      ),
      child: _buildSwapTransactionItem(swap, context, ref, screenWidth),
    );
  }

  Widget _buildSwapTransactionItem(SideswapPegStatus swap, BuildContext context, WidgetRef ref, double screenWidth) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.swap_horizontal_circle_outlined, color: Colors.orange),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Text(
                    'Layer Swap'.i18n(ref),
                    style: TextStyle(
                      fontSize: screenWidth * 0.0375,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _timestampToDateTime(swap.createdAt!),
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                swap.pegIn! ? "Bitcoin" : "Liquid Bitcoin",
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
              ),
              SizedBox(width: screenWidth * 0.1),
              Column(
                children: [
                  const Icon(Icons.arrow_forward, color: Colors.orange, size: 30),
                  Text("More Details".i18n(ref), style: TextStyle(fontSize: screenWidth * 0.02, color: Colors.white)),
                ],
              ),
              Text(
                swap.pegIn! ? "Liquid Bitcoin" : "Bitcoin",
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
              ),
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
}