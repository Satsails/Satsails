import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/coinos_ln_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
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
import 'package:intl/intl.dart';

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
            return const TransactionListModalBottomSheet();
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
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final liquidIsLoading = ref
        .watch(transactionNotifierProvider)
        .liquidTransactions
        .isNotEmpty
        ? ref
        .watch(transactionNotifierProvider)
        .liquidTransactions
        .first
        .lwkDetails
        .balances
        .isEmpty
        : false;
    final bitcoinIsLoading = ref
        .watch(transactionNotifierProvider)
        .bitcoinTransactions
        .isNotEmpty
        ? ref
        .watch(transactionNotifierProvider)
        .bitcoinTransactions
        .first
        .btcDetails
        .txid == ''
        : false;
    final bitcoinTransactions = ref.watch(bitcoinTransactionsByDate);
    final liquidTransactions = ref.watch(liquidTransactionsByDate);
    final transactionType = ref.watch(selectedExpenseTypeProvider);

    // Include all transactions for 'All' type
    final allTransactions = <dynamic>[
      ...bitcoinTransactions,
      ...liquidTransactions,
    ];

    // Check if transactions are loading
    if (liquidIsLoading && bitcoinIsLoading) {
      return Container(
        height: screenHeight * 0.9, // Adjust the height as needed
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.orange, size: screenHeight * 0.1),
        ),
      );
    }

    if (transactionType == 'Lightning') {
      // Watch the getTransactionsProvider
      final coinosTransactionsAsync = ref.watch(getTransactionsProvider);

      return coinosTransactionsAsync.when(
        data: (lightningTransactions) {
          if (lightningTransactions == null || lightningTransactions.isEmpty) {
            return _buildNoTransactionsFound(screenHeight, ref);
          }

          return _buildTransactionList(
            context,
            ref,
            lightningTransactions.length,
                (index) =>
                _buildLightningTransactionItem(
                    lightningTransactions.reversed.toList()[index], context, ref)
          );
        },
        loading: () => _buildLoadingIndicator(screenHeight),
        error: (error, stack) => _buildErrorIndicator(screenHeight, error),
      );
    }

    // Existing code for Bitcoin and Liquid transactions
    // Determine the total number of transactions
    final totalTransactions = txLength(
        bitcoinTransactions, liquidTransactions, ref);

    // If no transactions, display message
    if (totalTransactions == 0) {
      return _buildNoTransactionsFound(screenHeight, ref);
    }

    return _buildTransactionList(
      context,
      ref,
      totalTransactions,
          (index) {
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
        return const SizedBox();
      },
    );
  }

  Widget _buildTransactionList(BuildContext context, WidgetRef ref,
      int itemCount,
      Widget Function(int) itemBuilder) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Container(
      height: screenHeight * 0.9, // Adjust the height as needed
      decoration: const BoxDecoration(
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
            itemCount: itemCount,
            itemBuilder: (BuildContext context, int index) {
              return itemBuilder(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoTransactionsFound(double screenHeight, WidgetRef ref) {
    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Text(
          'No transactions found. Check back later.'.i18n(ref),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(double screenHeight) {
    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.orange, size: screenHeight * 0.1),
      ),
    );
  }

  Widget _buildErrorIndicator(double screenHeight, Object error) {
    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Text(
          'Error loading transactions: $error',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  int txLength(List<dynamic> bitcoinTransactions,
      List<dynamic> liquidTransactions, WidgetRef ref) {
    final transactionType = ref.watch(selectedExpenseTypeProvider);
    switch (transactionType) {
      case 'Bitcoin':
        return bitcoinTransactions.length;
      case 'Liquid':
        return liquidTransactions.length;
      default:
        return bitcoinTransactions.length + liquidTransactions.length;
    }
  }

  Widget _buildTransactionItem(dynamic transaction, BuildContext context,
      WidgetRef ref) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    final dynamicMargin = screenHeight * 0.01; // 1% of screen height
    final dynamicRadius = screenWidth * 0.03; // 3% of screen width

    if (transaction is BitcoinTransaction) {
      return Container(
        margin: EdgeInsets.all(dynamicMargin),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(dynamicRadius),
        ),
        child: _buildBitcoinTransactionItem(transaction, context, ref),
      );
    } else if (transaction is LiquidTransaction) {
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

  Widget _buildBitcoinTransactionItem(BitcoinTransaction transaction,
      BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
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
                transactionTypeIcon(transaction.btcDetails),
                Text(transactionAmountInFiat(transaction.btcDetails, ref),
                    style: TextStyle(
                        fontSize: dynamicFontSize, color: Colors.white)),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(transactionTypeString(transaction.btcDetails, ref),
                    style: TextStyle(
                        fontSize: dynamicFontSize, color: Colors.white)),
                Text(transactionAmount(transaction.btcDetails, ref),
                    style: TextStyle(
                        fontSize: dynamicFontSize, color: Colors.grey)),
              ],
            ),
            subtitle: Text(
                timestampToDateTime(
                    transaction.btcDetails.confirmationTime?.timestamp.toInt())
                    .i18n(ref),
                style: TextStyle(
                    fontSize: dynamicFontSize, color: Colors.grey)),
            trailing:
            confirmationStatus(transaction.btcDetails, ref) == 'Confirmed'.i18n(ref)
                ? const Icon(Icons.check_circle_outlined,
                color: Colors.green)
                : const Icon(Icons.access_alarm_outlined,
                color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidTransactionItem(LiquidTransaction transaction, BuildContext context,
      WidgetRef ref) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final dynamicFontSize = screenHeight * 0.015;

    return Column(
      children: [
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: transactionTypeLiquidIcon(transaction.lwkDetails.kind),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(liquidTransactionType(transaction.lwkDetails, ref),
                        style: TextStyle(
                            fontSize: dynamicFontSize, color: Colors.white)),
                    transaction.lwkDetails.balances.length == 1
                        ? Text(
                        _valueOfLiquidSubTransaction(
                            AssetMapper.mapAsset(
                                transaction.lwkDetails.balances[0].assetId),
                            transaction.lwkDetails.balances[0].value,
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
                    timestampToDateTime(transaction.lwkDetails.timestamp).i18n(ref),
                    style: TextStyle(
                        fontSize: dynamicFontSize, color: Colors.grey)),
                trailing: confirmationStatusIcon(transaction.lwkDetails),
                children: transaction.lwkDetails.balances.map((balance) {
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
                          AssetMapper
                              .mapAsset(balance.assetId)
                              .name,
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



  Widget _buildLightningTransactionItem(CoinosPayment transaction,
      BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final dynamicFontSize = screenHeight * 0.015;

    int amount = transaction.amount ?? 0;
    bool isReceived = amount > 0;

    final btcFormat = ref
        .watch(settingsProvider)
        .btcFormat;
    final formattedAmount = btcInDenominationFormatted(amount, btcFormat);

    return Container(
        margin: EdgeInsets.all(screenHeight * 0.01), // 1% of screen height
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(
              screenWidth * 0.03), // 3% of screen width
        ),
        child: ListTile(
          leading: Column(
            children: [
              Icon(
                isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                color: isReceived ? Colors.green : Colors.red,
              ),
            ],
          ),
          title: Text(
            formattedAmount,
            style: TextStyle(
              fontSize: dynamicFontSize,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            transaction.created != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.created!)
                : '',
            style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey),
          ),
          trailing: transaction.confirmed == true
              ? const Icon(Icons.check_circle_outlined, color: Colors.green)
              : const Icon(Icons.access_alarm_outlined, color: Colors.red),
        ));
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


