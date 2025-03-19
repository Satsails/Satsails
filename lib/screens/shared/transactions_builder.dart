import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/coinos_ln_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/conversion_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BuildTransactions extends ConsumerWidget {
  final bool showAllTransactions;

  const BuildTransactions({super.key, required this.showAllTransactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent, // Make background transparent
          builder: (context) {
            return const TransactionList();
          },
        );
      },
      text: 'See Full History'.i18n,
      primaryColor: Colors.transparent,
      secondaryColor: Colors.transparent,
      textColor: Colors.white,
    );
  }
}

class TransactionList extends ConsumerWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final transactionState = ref.watch(transactionNotifierProvider);
    final allTransactions = transactionState.allTransactionsSorted;

    return Container(
      height: screenHeight * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: allTransactions.isEmpty
          ? _buildNoTransactionsFound(screenHeight)
          : _buildTransactionList(
        context,
        allTransactions.length,
            (index) => _buildUnifiedTransactionItem(allTransactions[index], context, ref),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, int itemCount, Widget Function(int) itemBuilder) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );
  }

  Widget _buildNoTransactionsFound(double screenHeight) {
    return Center(
      child: Text(
        'No transactions found',
        style: TextStyle(
          fontSize: screenHeight * 0.02,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Unified method to build transaction items based on type
  Widget _buildUnifiedTransactionItem(dynamic transaction, BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicMargin = screenHeight * 0.01;
    final dynamicRadius = screenWidth * 0.03;
    final dynamicFontSize = screenHeight * 0.015;

    Widget transactionItem;
    if (transaction is SideswapPegTransaction) {
      transactionItem = _buildSideswapPegTransactionItem(transaction, context, ref, dynamicFontSize);
    } else if (transaction is BitcoinTransaction) {
      transactionItem = _buildBitcoinTransactionItem(transaction, context, ref);
    } else if (transaction is LiquidTransaction) {
      transactionItem = _buildLiquidTransactionItem(transaction, context, ref);
    } else if (transaction is SideswapInstantSwapTransaction) {
      transactionItem = _buildSideswapInstantSwapTransactionItem(transaction, context, ref, dynamicFontSize);
    } else if (transaction is EulenTransaction) {
      transactionItem = _buildEulenTransactionItem(transaction, context, ref, dynamicFontSize);
    } else {
      transactionItem = const SizedBox();
    }
    return transactionItem;
  }


  /// Builds an ExpansionTile for Sideswap Peg transactions
  Widget _buildSideswapPegTransactionItem(
      SideswapPegTransaction transaction,
      BuildContext context,
      WidgetRef ref,
      double fontSize,
      ) {
    final pegDetails = transaction.sideswapPegDetails;
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final pegType = pegDetails.pegIn ?? true ? 'Peg-In' : 'Peg-Out';
    final totalAmount = pegDetails.list?.fold<int>(0, (sum, tx) => sum + (tx.amount ?? 0)) ?? 0;
    final amountInFiat = ref.watch(conversionToFiatProvider(totalAmount));
    final formattedFiat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(double.parse(amountInFiat));
    final formattedBtc = btcInDenominationFormatted(totalAmount, btcFormat);
    final status = pegDetails.list?.isNotEmpty == true ? pegDetails.list!.first.status : 'Pending';
    final timestamp = pegDetails.createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(pegDetails.createdAt! * 1000)
        : transaction.timestamp;

    return ExpansionTile(
      leading: Icon(
        pegDetails.pegIn ?? true ? Icons.arrow_downward : Icons.arrow_upward,
        color: pegDetails.pegIn ?? true ? Colors.green : Colors.orange,
      ),
      title: Text(
        '$pegType - $status',
        style: TextStyle(fontSize: fontSize, color: Colors.white),
      ),
      subtitle: Text(
        DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp),
        style: TextStyle(fontSize: fontSize, color: Colors.grey),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formattedFiat,
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
          Text(
            formattedBtc,
            style: TextStyle(fontSize: fontSize, color: Colors.grey),
          ),
        ],
      ),
      children: pegDetails.list?.map((tx) {
        return ListTile(
          title: Text(
            tx.status ?? 'Unknown',
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
          subtitle: Text(
            'Amount: ${btcInDenominationFormatted(tx.amount ?? 0, btcFormat)}',
            style: TextStyle(fontSize: fontSize, color: Colors.grey),
          ),
        );
      }).toList() ?? [],
    );
  }

  /// Builds a ListTile for Sideswap Instant Swap transactions
  Widget _buildSideswapInstantSwapTransactionItem(
      SideswapInstantSwapTransaction transaction,
      BuildContext context,
      WidgetRef ref,
      double fontSize,
      ) {
    final swapDetails = transaction.sideswapInstantSwapDetails;
    // Assuming SideswapCompletedSwap has fields like amountFrom, assetFrom, etc.
    // For simplicity, show basic info; enhance with actual data
    final status = transaction.sideswapInstantSwapDetails.txid.isNotEmpty ? 'Confirmed' : 'Pending';
    return ListTile(
      leading: const Icon(Icons.swap_horiz, color: Colors.purple),
      title: Text(
        'Instant Swap',
        style: TextStyle(fontSize: fontSize, color: Colors.white),
      ),
      subtitle: Text(
        DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.timestamp),
        style: TextStyle(fontSize: fontSize, color: Colors.grey),
      ),
      trailing: Text(
        status,
        style: TextStyle(fontSize: fontSize, color: Colors.grey),
      ),
    );
  }

  /// Builds a ListTile for Eulen (Pix Purchase) transactions (optional)
  Widget _buildEulenTransactionItem(
      EulenTransaction transaction,
      BuildContext context,
      WidgetRef ref,
      double fontSize,
      ) {
    final pixDetails = transaction.pixDetails;
    // Assuming EulenTransfer has fields like amount, currency
    final status = transaction.pixDetails.status!.isNotEmpty ? 'Confirmed' : 'Pending';
    return ListTile(
      leading: const Icon(Icons.payment, color: Colors.yellow),
      title: Text(
        'Pix Purchase',
        style: TextStyle(fontSize: fontSize, color: Colors.white),
      ),
      subtitle: Text(
        DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.timestamp),
        style: TextStyle(fontSize: fontSize, color: Colors.grey),
      ),
      trailing: Text(
        status,
        style: TextStyle(fontSize: fontSize, color: Colors.grey),
      ),
    );
  }
}

Widget _buildBitcoinTransactionItem(BitcoinTransaction transaction, BuildContext context, WidgetRef ref) {
  final screenHeight = MediaQuery.of(context).size.height;
  final dynamicFontSize = screenHeight * 0.015;

  // Determine if the transaction is confirmed
  final isConfirmed = transaction.btcDetails.confirmationTime != null;

  // Format the transaction date
  final timestamp = transaction.btcDetails.confirmationTime?.timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(transaction.btcDetails.confirmationTime!.timestamp.toInt() * 1000)
      : transaction.timestamp;
  final formattedDate = DateFormat('d, MMMM, HH:mm').format(timestamp);

  return GestureDetector(
    onTap: () {
      context.pushNamed('transactionDetails', extra: transaction);
    },
    behavior: HitTestBehavior.opaque, // Makes the entire area tappable
    child: Card(
      color: Colors.black, // Dark background for contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      elevation: 4, // Subtle shadow for depth
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator for unconfirmed transactions
            if (!isConfirmed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  minHeight: 4,
                ),
              ),
            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction type icon (outside Expanded)
                transactionTypeIcon(transaction.btcDetails),
                const SizedBox(width: 12), // Consistent spacing after icon
                // Remaining content takes up available space
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bitcoin logo and transaction amount
                      Row(
                        children: [
                          Image.asset(
                            'lib/assets/bitcoin-logo.png',
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(width: 10), // Consistent spacing
                          Text(
                            transactionAmount(transaction.btcDetails, ref),
                            style: TextStyle(
                              fontSize: dynamicFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // Date and fiat value on the right
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: dynamicFontSize - 2, // Smaller for date
                              color: Colors.grey[400], // Lighter color
                            ),
                          ),
                          Text(
                            transactionAmountInFiat(transaction.btcDetails, ref),
                            style: TextStyle(
                              fontSize: dynamicFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300], // Brighter than date
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildLiquidTransactionItem(LiquidTransaction transaction, BuildContext context, WidgetRef ref) {
  final screenHeight = MediaQuery.of(context).size.height;
  final dynamicFontSize = screenHeight * 0.015;

  // Define the asset icon mapping
  final assetIcons = {
    'EURx': 'lib/assets/eurx.png',
    'Depix': 'lib/assets/depix.png',
    'USDT': 'lib/assets/tether.png',
    'LBTC': 'lib/assets/l-btc.png',
  };

  // Determine if the transaction is confirmed
  final isConfirmed = transaction.lwkDetails.outputs.isNotEmpty && transaction.lwkDetails.outputs[0].height != null ||
      transaction.lwkDetails.inputs.isNotEmpty && transaction.lwkDetails.inputs[0].height != null;

  // Format the transaction date
  final timestamp = transaction.lwkDetails.timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(transaction.lwkDetails.timestamp! * 1000)
      : transaction.timestamp;
  final formattedDate = DateFormat('d, MMMM, HH:mm').format(timestamp);

  return GestureDetector(
    onTap: () {
      context.pushNamed('liquidTransactionDetails', extra: transaction);
    },
    child: Card(
      color: Colors.black, // Dark background for contrast
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      elevation: 4, // Subtle shadow for depth
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator for unconfirmed transactions
            if (!isConfirmed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  minHeight: 4,
                ),
              ),
            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                transactionTypeLiquidIcon(transaction.lwkDetails.kind),
                const SizedBox(width: 12), // Increased spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: transaction.lwkDetails.balances.map((balance) {
                      final asset = AssetMapper.mapAsset(balance.assetId);
                      final ticker = asset.name;
                      final value = valueOfLiquidSubTransaction(asset, balance.value, ref);
                      final fiatValue = asset == AssetId.LBTC ? liquidTransactionAmountInFiat(balance, ref) : '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Asset icon and value
                            Row(
                              children: [
                                Image.asset(
                                  assetIcons[ticker] ?? 'lib/assets/default.png',
                                  width: 30, // Slightly larger icon
                                  height: 30,
                                ),
                                const SizedBox(width: 10), // Adjusted spacing
                                Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: dynamicFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            // Date and fiat value on the right
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (fiatValue.isNotEmpty)
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: dynamicFontSize - 2, // Smaller for date
                                    color: Colors.grey[400], // Lighter color
                                  ),
                                ),
                                if (fiatValue.isNotEmpty)
                                  Text(
                                    fiatValue,
                                    style: TextStyle(
                                      fontSize: dynamicFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[300], // Brighter than date
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

