import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/providers/conversion_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/analytics/components/coinos_swaps.dart';
import 'package:Satsails/screens/charge/components/pix_history.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/screens/analytics/components/peg_details.dart';


class SwapsBuilder extends ConsumerStatefulWidget {
  const SwapsBuilder({super.key});

  @override
  _SwapsBuilderState createState() => _SwapsBuilderState();
}

class _SwapsBuilderState extends ConsumerState<SwapsBuilder> {
  String selectedSwapType = 'Fiat Swaps';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final allSwaps = ref.watch(sideswapAllPegsProvider);
    final swapsToFiat = ref.watch(sideswapGetSwapsProvider);
    final paymentId = ref.watch(userProvider).paymentId;

    return Column(
      children: [
        _buildSwapTypeFilter(context, paymentId),
        Expanded(
          child: selectedSwapType == 'Pix History' && paymentId.isNotEmpty
              ? Builder(builder: (context) => const PixHistory())
              : selectedSwapType == 'Lightning Swaps'
              ? CoinosPaymentsList()
              : allSwaps.when(
            data: (swaps) {
              return swapsToFiat.when(
                data: (fiatSwaps) {
                  final combinedSwaps = _filterAndSortSwaps([...swaps, ...fiatSwaps]);
                  if (combinedSwaps.isEmpty) {
                    return Center(
                      child: Text(
                        'No swaps found'.i18n(ref),
                        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
                      ),
                    );
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
                loading: () => LoadingAnimationWidget.threeArchedCircle(
                  size: screenWidth * 0.2,
                  color: Colors.orange,
                ),
                error: (error, stackTrace) => Center(
                  child: Text('Error: $error', style: TextStyle(fontSize: screenWidth * 0.05)),
                ),
              );
            },
            loading: () => LoadingAnimationWidget.threeArchedCircle(size: screenWidth * 0.5, color: Colors.black),
            error: (error, stackTrace) => Center(
              child: Text('Error: $error', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSwapTypeFilter(BuildContext context, String paymentId) {
    final List<String> swapTypes = [
      'Fiat Swaps',
      'Layer Swaps',
      'Lightning Swaps', // Add Lightning Swaps to the dropdown
      if (paymentId.isNotEmpty) 'Pix History',
    ];

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedSwapType,
        dropdownColor: const Color(0xFF2B2B2B),
        items: swapTypes.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value.i18n(ref),
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, color: Colors.orange),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedSwapType = newValue!;
          });
        },
      ),
    );
  }

  List<dynamic> _filterAndSortSwaps(List<dynamic> swaps) {
    List<dynamic> filteredSwaps = swaps.where((swap) {
      if (selectedSwapType == 'Fiat Swaps' && swap is SideswapCompletedSwap) {
        return true;
      }
      if (selectedSwapType == 'Layer Swaps' && swap is SideswapPegStatus) {
        return true;
      }
      return false;
    }).toList();

    filteredSwaps.sort((a, b) {
      return _getTimestamp(b).compareTo(_getTimestamp(a));
    });

    return filteredSwaps;
  }

  int _getTimestamp(dynamic swap) {
    if (swap is SideswapPegStatus) {
      return swap.createdAt ?? 0;
    } else if (swap is SideswapCompletedSwap) {
      return swap.timestamp;
    } else {
      return 0;
    }
  }

  Widget _buildFiatTransactionItem(SideswapCompletedSwap swap, BuildContext context, WidgetRef ref, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.circular(screenWidth * 0.0375),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.swap_calls_rounded, color: Colors.orange),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Text("Fiat Swap".i18n(ref), style: TextStyle(fontSize: screenWidth * 0.0375, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(_timestampToDateTime(swap.timestamp), style: TextStyle(fontSize: screenWidth * 0.025, color: Colors.white)),
                  ],
                ),
              ),
            ),
            subtitle: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(_assetNameFromTicker(AssetMapper.mapAsset(swap.sendAsset)), style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(
                          _assetNameFromTicker(AssetMapper.mapAsset(swap.sendAsset)) == 'LBTC'
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
                          _assetNameFromTicker(AssetMapper.mapAsset(swap.recvAsset)) == 'LBTC'
                              ? ref.watch(conversionProvider((swap.recvAmount).toInt()))
                              : (swap.recvAmount / 100000000).toStringAsFixed(2),
                          style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              ref.read(transactionSearchProvider).isLiquid = true;
              ref.read(transactionSearchProvider).txid = swap.txid;
              context.push('/search_modal');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(SideswapPegStatus swap, BuildContext context, WidgetRef ref, double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 29, 29, 29),
        borderRadius: BorderRadius.circular(screenWidth * 0.0375),
      ),
      child: Column(
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
      ),
    );
  }

  String _assetNameFromTicker(AssetId ticker) {
    switch (ticker) {
      case AssetId.USD:
        return 'USDt';
      case AssetId.LBTC:
        return 'LBTC';
      case AssetId.EUR:
        return 'EURx';
      case AssetId.BRL:
        return 'Depix';
      default:
        return 'UNKNOWN';
    }
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
