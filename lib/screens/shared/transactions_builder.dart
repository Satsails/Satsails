import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/screens/analytics/components/button_picker.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/conversion_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lwk_dart/lwk_dart.dart' as lwk;

class BuildTransactions extends ConsumerWidget {
  final bool showAllTransactions;

  const BuildTransactions({super.key, required this.showAllTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomButton(
      onPressed: () {
        // Show the TransactionListModalBottomSheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent, // Make background transparent
          builder: (context) {
            return TransactionListModalBottomSheet();
          },
        );
      },
      text: 'See Full History'.i18n(ref),
      primaryColor: Colors.transparent,
      secondaryColor: Colors.transparent,
      textColor: Colors.white,
    );
  }
}

class TransactionListModalBottomSheet extends ConsumerWidget {
  const TransactionListModalBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final liquidIsLoading = ref.watch(transactionNotifierProvider).liquidTransactions.isNotEmpty
        ? ref.watch(transactionNotifierProvider).liquidTransactions.first.balances.isEmpty
        : false;
    final bitcoinIsLoading = ref.watch(transactionNotifierProvider).bitcoinTransactions.isNotEmpty
        ? ref.watch(transactionNotifierProvider).bitcoinTransactions.first.txid == ''
        : false;
    final bitcoinTransactions = ref.watch(bitcoinTransactionsByDate);
    final liquidTransactions = ref.watch(liquidTransactionsByDate);
    final transactionType = ref.watch(transactionTypeShowProvider);
    final allTransactions = <dynamic>[
      ...bitcoinTransactions,
      ...liquidTransactions
    ];

    // Check if transactions are loading
    if (liquidIsLoading && bitcoinIsLoading) {
      return Container(
        height: screenHeight * 0.9, // Adjust the height as needed
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.orange, size: screenHeight * 0.1),
        ),
      );
    }

    // Determine the total number of transactions
    final totalTransactions = txLength(bitcoinTransactions, liquidTransactions, ref);

    // If no transactions, display message
    if (totalTransactions == 0) {
      return Container(
        height: screenHeight * 0.9, // Adjust the height as needed
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Text(
            'No transactions found. Check back later.'.i18n(ref),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Container(
      height: screenHeight * 0.9, // Adjust the height as needed
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LiquidPullToRefresh(
          onRefresh: () async {
            await ref
                .read(backgroundSyncNotifierProvider.notifier)
                .performSync();
          },
          color: Colors.orange,
          showChildOpacityTransition: false,
          child: ListView.builder(
            itemCount: totalTransactions,
            itemBuilder: (BuildContext context, int index) {
              switch (transactionType) {
                case 'Bitcoin':
                  if (index < bitcoinTransactions.length) {
                    return _buildTransactionItem(
                        bitcoinTransactions[index], context, ref);
                  }
                  break;
                case 'Liquid':
                  if (index < liquidTransactions.length) {
                    return _buildTransactionItem(
                        liquidTransactions[index], context, ref);
                  }
                  break;
                default:
                  if (index < allTransactions.length) {
                    return _buildTransactionItem(
                        allTransactions[index], context, ref);
                  }
              }
              return SizedBox();
            },
          ),
        ),
      ),
    );
  }

  int txLength(List<dynamic> bitcoinTransactions,
      List<dynamic> liquidTransactions, WidgetRef ref) {
    final transactionType = ref.watch(transactionTypeShowProvider);
    switch (transactionType) {
      case 'Bitcoin':
        return bitcoinTransactions.length;
      case 'Liquid':
        return liquidTransactions.length;
      default:
        return bitcoinTransactions.length + liquidTransactions.length;
    }
  }

  Widget _buildTransactionItem(
      dynamic transaction, BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final dynamicMargin = screenHeight * 0.01; // 1% of screen height
    final dynamicRadius = screenWidth * 0.03; // 3% of screen width

    if (transaction is bdk.TransactionDetails) {
      return Container(
        margin: EdgeInsets.all(dynamicMargin),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(dynamicRadius),
        ),
        child: _buildBitcoinTransactionItem(transaction, context, ref),
      );
    } else if (transaction is lwk.Tx) {
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

  Widget _buildBitcoinTransactionItem(
      bdk.TransactionDetails transaction, BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;

    final dynamicFontSize = screenHeight * 0.015;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            context.pushNamed(
              'transactionDetails',
              extra: transaction,
            );
          },
          child: ListTile(
            leading: Column(
              children: [
                transactionTypeIcon(transaction),
                Text(transactionAmountInFiat(transaction, ref),
                    style: TextStyle(
                        fontSize: dynamicFontSize, color: Colors.white)),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(transactionTypeString(transaction, ref),
                    style: TextStyle(
                        fontSize: dynamicFontSize, color: Colors.white)),
                Text(transactionAmount(transaction, ref),
                    style: TextStyle(
                        fontSize: dynamicFontSize, color: Colors.grey)),
              ],
            ),
            subtitle: Text(
                timestampToDateTime(
                    transaction.confirmationTime?.timestamp)
                    .i18n(ref),
                style: TextStyle(
                    fontSize: dynamicFontSize, color: Colors.grey)),
            trailing:
            confirmationStatus(transaction, ref) == 'Confirmed'.i18n(ref)
                ? const Icon(Icons.check_circle_outlined,
                color: Colors.green)
                : const Icon(Icons.access_alarm_outlined,
                color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidTransactionItem(
      lwk.Tx transaction, BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;

    final dynamicFontSize = screenHeight * 0.015;

    return Column(
      children: [
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: transactionTypeLiquidIcon(transaction.kind),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(liquidTransactionType(transaction, ref),
                        style: TextStyle(
                            fontSize: dynamicFontSize, color: Colors.white)),
                    transaction.balances.length == 1
                        ? Text(
                        _valueOfLiquidSubTransaction(
                            AssetMapper.mapAsset(
                                transaction.balances[0].assetId),
                            transaction.balances[0].value,
                            ref),
                        style: TextStyle(
                            fontSize: dynamicFontSize,
                            color: Colors.white))
                        : Text('Multiple'.i18n(ref),
                        style: TextStyle(
                            fontSize: dynamicFontSize,
                            color: Colors.white)),
                  ],
                ),
                subtitle: Text(
                    timestampToDateTime(transaction.timestamp).i18n(ref),
                    style: TextStyle(
                        fontSize: dynamicFontSize, color: Colors.grey)),
                trailing: confirmationStatusIcon(transaction),
                children: transaction.balances.map((balance) {
                  return GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        'liquidTransactionDetails',
                        extra: transaction,
                      );
                    },
                    child: ListTile(
                      trailing: Column(
                        children: [
                          subTransactionIcon(balance.value),
                          Text(_liquidTransactionAmountInFiat(balance, ref),
                              style: TextStyle(
                                  fontSize: dynamicFontSize,
                                  color: Colors.white)),
                        ],
                      ),
                      title: Text(
                          AssetMapper.mapAsset(balance.assetId).name,
                          style: TextStyle(
                              fontSize: dynamicFontSize, color: Colors.white)),
                      subtitle: Text(
                          _valueOfLiquidSubTransaction(
                              AssetMapper.mapAsset(balance.assetId),
                              balance.value,
                              ref),
                          style: TextStyle(
                              fontSize: dynamicFontSize, color: Colors.grey)),
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

  String _liquidTransactionAmountInFiat(
      dynamic transaction, WidgetRef ref) {
    if (AssetMapper.mapAsset(transaction.assetId) == AssetId.LBTC) {
      final currency = ref.watch(settingsProvider).currency;
      final value =
      ref.watch(conversionToFiatProvider(transaction.value));

      return '${(double.parse(value) / 100000000).toStringAsFixed(2)} $currency';
    } else {
      return '';
    }
  }

  String _valueOfLiquidSubTransaction(
      AssetId asset, int value, WidgetRef ref) {
    switch (asset) {
      case AssetId.USD:
      case AssetId.EUR:
      case AssetId.BRL:
        return (value / 100000000).toStringAsFixed(2);
      case AssetId.LBTC:
        return ref.watch(conversionProvider(value));
      default:
        return (value / 100000000).toStringAsFixed(2);
    }
  }
}
