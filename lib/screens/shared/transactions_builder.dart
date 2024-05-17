import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/conversion_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/providers/transaction_type_show_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';

class BuildTransactions extends ConsumerWidget {
  final bool showAllTransactions;

  const BuildTransactions({super.key, required this.showAllTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List bitcoinTransactions;
    final List liquidTransactions;
    bitcoinTransactions = ref.watch(bitcoinTransactionsByDate);
    liquidTransactions = ref.watch(liquidTransactionsByDate);
    final transationType = ref.watch(transactionTypeShowProvider);
    final allTx = <dynamic>[];
    allTx.addAll(bitcoinTransactions);
    allTx.addAll(liquidTransactions);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height - kToolbarHeight,
        child: LiquidPullToRefresh(
          onRefresh: () async {
            ref.read(backgroundSyncNotifierProvider).performSync();
          },
          color: Colors.orangeAccent,
          showChildOpacityTransition: false,
          child: ListView.builder(
            itemCount: txLength(bitcoinTransactions, liquidTransactions, ref),
            itemBuilder: (BuildContext context, int index) {
              switch (transationType) {
                case 'Bitcoin':
                  if (index < bitcoinTransactions.length) {
                    return _buildTransactionItem(bitcoinTransactions[index], context, ref);
                  } else if (bitcoinTransactions.isEmpty) {
                    return Center(child: Text('Pull up to refresh'.i18n(ref), style: const TextStyle(fontSize: 14, color: Colors.grey)));
                  }
                case 'Liquid':
                  if (index < liquidTransactions.length) {
                    return _buildTransactionItem(liquidTransactions[index], context, ref);
                  } else if (liquidTransactions.isEmpty) {
                    return Center(child: Text('Pull up to refresh'.i18n(ref).i18n(ref), style: const TextStyle(fontSize: 14, color: Colors.grey)));
                  }
                default:
                  if (index < allTx.length) {
                    return _buildTransactionItem(allTx[index], context, ref);
                  } else {
                    return Center(child: Text('Pull up to refresh'.i18n(ref), style: const TextStyle(fontSize: 14, color: Colors.grey)));
                  }
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  int txLength(List<dynamic> bitcoinTransactions, List<dynamic> liquidTransactions, ref) {
    final transationType = ref.watch(transactionTypeShowProvider);
    switch (transationType) {
      case 'Bitcoin':
        if (bitcoinTransactions.isEmpty) {
          return 1;
        }
        return bitcoinTransactions.length;
      case 'Liquid':
        if (liquidTransactions.isEmpty) {
          return 1;
        }
        return liquidTransactions.length;
      default:
        if (bitcoinTransactions.isEmpty && liquidTransactions.isEmpty) {
          return 1;
        }
        return bitcoinTransactions.length + liquidTransactions.length;
    }
  }

  Widget _buildTransactionItem(transaction, BuildContext context, WidgetRef ref) {
    if (transaction is TransactionDetails) {
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
        child: _buildBitcoinTransactionItem(transaction, context, ref),
      );
    } else if (transaction is Tx) {
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
        child: _buildLiquidTransactionItem(transaction, context, ref),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildBitcoinTransactionItem(TransactionDetails transaction, BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.read(transactionSearchProvider).isLiquid = false;
            ref.read(transactionSearchProvider).txid = transaction.txid;
            Navigator.pushNamed(context, '/search_modal');
          },
          child: ListTile(
            leading: Column(
              children: [
                _transactionTypeIcon(transaction),
                Text(_transactionAmountInFiat(transaction, ref),style: const TextStyle(fontSize: 14)),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_transactionTypeString(transaction, ref), style: const TextStyle(fontSize: 16)),
                Text(_transactionAmount(transaction, ref),style: const TextStyle(fontSize: 14)),
              ],
            ),
            // subtitle: Text("Fee: ${_transactionFee(transaction, ref)}", style: const TextStyle(fontSize: 14)),
            subtitle: Text(timestampToDateTime(transaction.confirmationTime?.timestamp), style: const TextStyle(fontSize: 14)),
            trailing: _confirmationStatus(transaction, ref) == 'Confirmed'.i18n(ref)
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.access_alarm_outlined, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidTransactionItem(Tx transaction, BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Theme(
              data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: _transactionTypeLiquidIcon(transaction.kind),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(liquidTransactionType(transaction, ref), style: const TextStyle(fontSize: 16)),
                    transaction.balances.length == 1 ? Text(_valueOfLiquidSubTransaction(AssetMapper.mapAsset(transaction.balances[0].assetId), transaction.balances[0].value, ref), style: const TextStyle(fontSize: 14)) : Text('Multiple'.i18n(ref), style: const TextStyle(fontSize: 14)),
                  ],
                ),
                // subtitle: Text("Fee: ${_transactionValueLiquid(transaction.fee, ref)}",style: const TextStyle(fontSize: 14)),
                subtitle: Text(timestampToDateTime(transaction.timestamp),style: const TextStyle(fontSize: 14)),
                trailing: transaction.outputs[0].height != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(
                    Icons.access_alarm_outlined, color: Colors.red),
                children: transaction.balances.map((balance) {
                  return GestureDetector(
                    onTap: () {
                      setTransactionSearchProvider(transaction, ref);

                      Navigator.pushNamed(context, '/search_modal');
                    },
                    child: ListTile(
                      trailing: Column(
                        children: [
                          _subTransactionIcon(balance.value),
                          Text(_liquidTransactionAmountInFiat(balance, ref), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      title: Text(AssetMapper.mapAsset(balance.assetId).name),
                      subtitle: Text(_valueOfLiquidSubTransaction(
                          AssetMapper.mapAsset(balance.assetId), balance.value, ref)),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  String liquidTransactionType(Tx transaction, WidgetRef ref) {
    switch (transaction.kind) {
      case 'incoming':
        return 'Received'.i18n(ref);
      case 'outgoing':
        return 'Sent'.i18n(ref);
      case 'burn':
        return 'Burn'.i18n(ref);
      case 'redeposit':
        return 'Redeposit'.i18n(ref);
      case 'issuance':
        return 'Issuance'.i18n(ref);
      case 'reissuance':
        return 'Reissuance'.i18n(ref);
      default:
        return 'Swap'.i18n(ref);
    }
  }

  String timestampToDateTime(int? timestamp) {
    if (timestamp == 0 || timestamp == null) {
      return 'Unconfirmed';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.day}/${date.month}/${date.year}";
  }

  void setTransactionSearchProvider(Tx transaction, WidgetRef ref) {
    ref.read(transactionSearchProvider).isLiquid = true;
    ref.read(transactionSearchProvider).txid = transaction.txid;

    if (transaction.kind == 'incoming') {
      final outputs = transaction.outputs[0];
      final output = outputs.unblinded;
      ref.read(transactionSearchProvider).amountBlinder = output.valueBf;
      ref.read(transactionSearchProvider).assetBlinder = output.assetBf;
      ref.read(transactionSearchProvider).amount = output.value;
      ref.read(transactionSearchProvider).assetId = output.asset;
    } else {
      final inputs = transaction.inputs[0];
      final input = inputs.unblinded;
      ref.read(transactionSearchProvider).amountBlinder = input.valueBf;
      ref.read(transactionSearchProvider).assetBlinder = input.assetBf;
      ref.read(transactionSearchProvider).amount = input.value;
      ref.read(transactionSearchProvider).assetId = input.asset;
    }
  }

  Icon _subTransactionIcon(int value) {
    if (value > 0) {
      return const Icon(Icons.arrow_downward, color: Colors.green);
    } else if (value < 0) {
      return const Icon(Icons.arrow_upward, color: Colors.red);
    } else {
      return const Icon(Icons.device_unknown_outlined, color: Colors.grey);
    }
  }

  Icon _transactionTypeLiquidIcon(String kind) {
    switch (kind) {
      case 'incoming':
        return const Icon(Icons.arrow_downward, color: Colors.green);
      case 'outgoing':
        return const Icon(Icons.arrow_upward, color: Colors.red);
      case 'burn':
        return const Icon(Icons.local_fire_department, color: Colors.redAccent);
      case 'redeposit':
        return const Icon(Icons.subdirectory_arrow_left, color: Colors.green);
      case 'issuance':
        return const Icon(Icons.add_circle, color: Colors.greenAccent);
      case 'reissuance':
        return const Icon(Icons.add_circle, color: Colors.green);
      default:
        return const Icon(Icons.swap_calls, color: Colors.orange);
    }
  }

  String _transactionTypeString(TransactionDetails transaction, WidgetRef ref) {
    if (transaction.received == 0 && transaction.sent > 0) {
      return 'Sent'.i18n(ref);
    } else if (transaction.received > 0 && transaction.sent == 0) {
      return 'Received'.i18n(ref);
    } else {
      return 'Multiple'.i18n(ref);
    }
  }

  Icon _transactionTypeIcon(TransactionDetails transaction) {
    if (transaction.received == 0 && transaction.sent > 0) {
      return const Icon(Icons.arrow_upward, color: Colors.red);
    } else if (transaction.received > 0 && transaction.sent == 0) {
      return const Icon(Icons.arrow_downward, color: Colors.green);
    } else {
      return const Icon(Icons.arrow_forward_sharp, color: Colors.orangeAccent);
    }
  }

  String _confirmationStatus(TransactionDetails transaction, WidgetRef ref) {
    if (transaction.confirmationTime == null || transaction.confirmationTime!.height == 0) {
      return 'Unconfirmed'.i18n(ref);
    } else if (transaction.confirmationTime != null) {
      return 'Confirmed'.i18n(ref);
    } else {
      return 'Unknown'.i18n(ref);
    }
  }

  String _transactionAmount(TransactionDetails transaction, WidgetRef ref) {
    if (transaction.received == 0 && transaction.sent > 0) {
      return ref.watch(conversionProvider(transaction.sent));
    } else if (transaction.received > 0 && transaction.sent == 0) {
      return ref.watch(conversionProvider(transaction.received));
    } else {
      int total = (transaction.received - transaction.sent).abs();
      return ref.watch(conversionProvider(total));
    }
  }

  String _transactionAmountInFiat(TransactionDetails transaction, WidgetRef ref) {
    final sent = ref.watch(conversionToFiatProvider(transaction.sent));
    final received = ref.watch(conversionToFiatProvider(transaction.received));
    final currency = ref.watch(settingsProvider).currency;

    if (transaction.received == 0 && transaction.sent > 0) {
      return '${(double.parse(sent) / 100000000).toStringAsFixed(2)} $currency';
    } else if (transaction.received > 0 && transaction.sent == 0) {
      return '${(double.parse(received) / 100000000).toStringAsFixed(2)} $currency';
    } else {
      double total = (double.parse(received) - double.parse(sent)).abs() / 100000000;
      return '${total.toStringAsFixed(2)} $currency';
    }
  }

  String _liquidTransactionAmountInFiat(transaction, WidgetRef ref) {
    if (AssetMapper.mapAsset(transaction.assetId) == AssetId.LBTC) {
      final currency = ref.watch(settingsProvider).currency;
      final value = ref.watch(conversionToFiatProvider(transaction.value));

      if (transaction.value < 0) {
        return '${(double.parse(value) / 100000000).toStringAsFixed(2)} $currency';
      } else {
        return '${(double.parse(value) / 100000000).toStringAsFixed(2)} $currency';
      }
    } else {
      return '';
    }
  }

  // String _transactionFee(TransactionDetails transaction, WidgetRef ref) {
  //   return ref.watch(conversionProvider(transaction.fee ?? 0));
  // }
  //
  // String _transactionValueLiquid(int transaction, WidgetRef ref) {
  //   return ref.watch(conversionProvider(transaction));
  // }

  String _valueOfLiquidSubTransaction(AssetId asset, int value, WidgetRef ref) {
    switch (asset) {
      case AssetId.USD:
        return (value / 100000000).toStringAsFixed(2);
      case AssetId.LBTC:
        return ref.watch(conversionProvider(value));
      case AssetId.EUR:
        return (value / 100000000).toStringAsFixed(2);
      case AssetId.BRL:
        return (value / 100000000).toStringAsFixed(2);
      default:
        return (value / 100000000).toStringAsFixed(2);
    }
  }
}