import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/screens/analytics/components/button_picker.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/liquid_transaction_details_screen.dart';
import 'package:Satsails/screens/shared/transactions_details_screen.dart';
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
import 'package:Satsails/providers/transactions_provider.dart';

class BuildTransactions extends ConsumerWidget {
  final bool showAllTransactions;

  const BuildTransactions({super.key, required this.showAllTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.2),
      child: CustomButton(
        onPressed: () => _showTransactionModal(context, ref),
        text: 'See Full History'.i18n(ref),
        primaryColor: Colors.transparent,
        secondaryColor: Colors.transparent,
        textColor: Colors.white,
      ),
    );
  }

  void _showTransactionModal(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List bitcoinTransactions;
    final List liquidTransactions;
    bitcoinTransactions = ref.watch(bitcoinTransactionsByDate);
    liquidTransactions = ref.watch(liquidTransactionsByDate);
    final transationType = ref.watch(transactionTypeShowProvider);
    final allTx = <dynamic>[];
    allTx.addAll(bitcoinTransactions);
    allTx.addAll(liquidTransactions);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes the modal sheet full screen if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            color: Color.fromARGB(255, 29, 29, 29),
          ),
          child: SizedBox(
            width: screenWidth,
            height: screenHeight * 0.75, // Use 75% of screen height for the modal sheet
            child: LiquidPullToRefresh(
              onRefresh: () async {
                ref.read(backgroundSyncNotifierProvider).performSync();
              },
              color: Colors.orange,
              showChildOpacityTransition: false,
              child: ListView.builder(
                itemCount: txLength(bitcoinTransactions, liquidTransactions, ref),
                itemBuilder: (BuildContext context, int index) {
                  switch (transationType) {
                    case 'Bitcoin':
                      if (index < bitcoinTransactions.length) {
                        return _buildTransactionItem(bitcoinTransactions[index], context, ref);
                      } else if (bitcoinTransactions.isEmpty) {
                        return Center(
                            child: Text('Pull up to refresh'.i18n(ref),
                                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.grey)));
                      }
                    case 'Liquid':
                      if (index < liquidTransactions.length) {
                        return _buildTransactionItem(liquidTransactions[index], context, ref);
                      } else if (liquidTransactions.isEmpty) {
                        return Center(
                            child: Text('Pull up to refresh'.i18n(ref),
                                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.grey)));
                      }
                    default:
                      if (index < allTx.length) {
                        return _buildTransactionItem(allTx[index], context, ref);
                      } else {
                        return Center(
                            child: Text('Pull up to refresh'.i18n(ref),
                                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.grey)));
                      }
                  }
                  return null;
                },
              ),
            ),
          ),
        );
      },
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final dynamicMargin = screenHeight * 0.01; // 1% of screen height
    final dynamicRadius = screenWidth * 0.03; // 3% of screen width

    if (transaction is TransactionDetails) {
      return Container(
        margin: EdgeInsets.all(dynamicMargin),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(dynamicRadius),
        ),
        child: _buildBitcoinTransactionItem(transaction, context, ref),
      );
    } else if (transaction is Tx) {
      return Container(
        margin: EdgeInsets.all(dynamicMargin),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(dynamicRadius),
        ),
        child: _buildLiquidTransactionItem(transaction, context, ref),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildBitcoinTransactionItem(TransactionDetails transaction, BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;

    final dynamicFontSize = screenHeight * 0.015;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailsScreen(transaction: transaction),
              ),
            );
          },
          child: ListTile(
            leading: Column(
              children: [
                transactionTypeIcon(transaction),
                Text(transactionAmountInFiat(transaction, ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.white)),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(transactionTypeString(transaction, ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.white)),
                Text(transactionAmount(transaction, ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey)),
              ],
            ),
            subtitle: Text(timestampToDateTime(transaction.confirmationTime?.timestamp).i18n(ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey)),
            trailing: confirmationStatus(transaction, ref) == 'Confirmed'.i18n(ref)
                ? const Icon(Icons.check_circle_outlined, color: Colors.green)
                : const Icon(Icons.access_alarm_outlined, color: Colors.red),
          ),
        ),
      ],
    );
  }


  Widget _buildLiquidTransactionItem(Tx transaction, BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;

    final dynamicFontSize = screenHeight * 0.015;

    return Column(
      children: [
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Theme(
              data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: transactionTypeLiquidIcon(transaction.kind),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(liquidTransactionType(transaction, ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.white)),
                    transaction.balances.length == 1 ? Text(_valueOfLiquidSubTransaction(AssetMapper.mapAsset(transaction.balances[0].assetId), transaction.balances[0].value, ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.white)) : Text('Multiple'.i18n(ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.white)),
                  ],
                ),
                subtitle: Text(timestampToDateTime(transaction.timestamp).i18n(ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey)),
                trailing: confirmationStatusIcon(transaction),
                children: transaction.balances.map((balance) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiquidTransactionDetailsScreen(transaction: transaction),
                        ),
                      );
                    },
                    child: ListTile(
                      trailing: Column(
                        children: [
                          subTransactionIcon(balance.value),
                          Text(_liquidTransactionAmountInFiat(balance, ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.white)),
                        ],
                      ),
                      title: Text(AssetMapper.mapAsset(balance.assetId).name, style: TextStyle(fontSize: dynamicFontSize, color: Colors.white)),
                      subtitle: Text(_valueOfLiquidSubTransaction(AssetMapper.mapAsset(balance.assetId), balance.value, ref), style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey)),
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