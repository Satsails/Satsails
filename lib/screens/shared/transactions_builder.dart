import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/helpers/string_extension.dart';
import 'package:satsails/models/adapters/transaction_adapters.dart';
import 'package:satsails/providers/background_sync_provider.dart';
import 'package:satsails/providers/conversion_provider.dart';
import 'package:satsails/providers/transaction_search_provider.dart';
import 'package:satsails/providers/transaction_type_show_provider.dart';
import 'package:satsails/providers/transactions_provider.dart';

class BuildTransactions extends ConsumerWidget {
  const BuildTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionNotifierProvider);
    final bitcoinTransactions = transactions.bitcoinTransactions;
    final liquidTransactions = transactions.liquidTransactions;
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
            ref.refresh(backgroundSyncNotifierProvider);
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
                  } else {
                    return const Center(child: Text('No transactions', style: TextStyle(fontSize: 20, color: Colors.grey)));
                  }
                case 'Liquid':
                  if (index < liquidTransactions.length) {
                    return _buildTransactionItem(liquidTransactions[index], context, ref);
                  } else {
                    return const Center(child: Text('No transactions', style: TextStyle(fontSize: 20, color: Colors.grey)));
                  }
                default:
                  if (index < allTx.length) {
                    return _buildTransactionItem(allTx[index], context, ref);
                  } else {
                    return const Center(child: Text('No transactions', style: TextStyle(fontSize: 20, color: Colors.grey)));
                  }
              }
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
              offset: Offset(0, 3),
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
              offset: Offset(0, 3),
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
            ref.read(transactionSearchProvider).transactionHash = transaction.txid;
            Navigator.pushNamed(context, '/search_modal');
          },
          child: ListTile(
            leading: _transactionTypeIcon(transaction),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_transactionTypeString(transaction), style: const TextStyle(fontSize: 16)),
                Text(_transactionAmount(transaction, ref),style: const TextStyle(fontSize: 14)),
              ],
            ),
            subtitle: Text("Fee: ${_transactionFee(transaction, ref)}",
                style: const TextStyle(fontSize: 14)),
            trailing: _confirmationStatus(transaction) == 'Confirmed'
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.access_alarm_outlined, color: Colors.red),
          ),
        )
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
                    Text(transaction.kind.capitalize(),
                        style: const TextStyle(fontSize: 16)),
                    transaction.balances.length == 1
                        ? Text(
                        _valueOfLiquidSubTransaction(AssetMapper.mapAsset(
                            transaction.balances[0].assetId), transaction.balances[0]
                            .value, ref), style: const TextStyle(fontSize: 14))
                        : Text('Multiple', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                subtitle: Text(
                    "Fee: ${_transactionValueLiquid(transaction.fee, ref)}",
                    style: const TextStyle(fontSize: 14)),
                trailing: transaction.outputs[0].height != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(
                    Icons.access_alarm_outlined, color: Colors.red),
                children: transaction.balances.map((balance) {
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(transactionSearchProvider)
                          .isLiquid = true;
                      ref
                          .read(transactionSearchProvider)
                          .transactionHash = transaction.txid;
                      Navigator.pushNamed(context, '/search_modal');
                    },
                    child: ListTile(
                      trailing: _subTransactionIcon(balance.value),
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
        return const Icon(Icons.device_unknown_outlined, color: Colors.grey);
    }
  }

  String _transactionTypeString(TransactionDetails transaction) {
    if (transaction.received == 0 && transaction.sent > 0) {
      return 'Sent';
    } else if (transaction.received > 0 && transaction.sent == 0) {
      return 'Received';
    } else {
      return 'Redeposit';
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

  String _confirmationStatus(TransactionDetails transaction) {
    if (transaction.confirmationTime == null || transaction.confirmationTime!.height == 0) {
      return 'Unconfirmed';
    } else if (transaction.confirmationTime != null) {
      return 'Confirmed';
    } else {
      return 'Unknown';
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

  String _transactionFee(TransactionDetails transaction, WidgetRef ref) {
    return ref.watch(conversionProvider(transaction.fee ?? 0));
  }

  String _transactionValueLiquid(int transaction, WidgetRef ref) {
    return ref.watch(conversionProvider(transaction));
  }

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