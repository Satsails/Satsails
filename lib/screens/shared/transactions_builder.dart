import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/conversion_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      transactionItem = _buildBitcoinTransactionItem(transaction, context, ref, dynamicFontSize);
    } else if (transaction is LiquidTransaction) {
      transactionItem = _buildLiquidTransactionItem(transaction, context, ref, dynamicFontSize);
    } else if (transaction is SideswapInstantSwapTransaction) {
      transactionItem = _buildSideswapInstantSwapTransactionItem(transaction, context, ref, dynamicFontSize);
    } else if (transaction is EulenTransaction) {
      transactionItem = _buildEulenTransactionItem(transaction, context, ref, dynamicFontSize);
    } else {
      transactionItem = const SizedBox();
    }

    return Container(
      margin: EdgeInsets.all(dynamicMargin),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(dynamicRadius),
      ),
      child: transactionItem,
    );
  }

  /// Builds a ListTile for Bitcoin transactions
  Widget _buildBitcoinTransactionItem(
      BitcoinTransaction transaction,
      BuildContext context,
      WidgetRef ref,
      double fontSize,
      ) {
    final btcDetails = transaction.btcDetails;
    final net = btcDetails.received - btcDetails.sent;
    final isReceive = btcDetails.received.toInt() > 0 && btcDetails.sent == 0;
    final isSend = btcDetails.sent.toInt() > 0 && btcDetails.received == 0;
    final amount = isReceive ? btcDetails.received : (isSend ? btcDetails.sent : (btcDetails.received - btcDetails.sent));
    final formattedAmount = btcInDenominationFormatted(amount.toDouble(), ref.watch(settingsProvider).btcFormat);
    final status = btcDetails.confirmationTime != null ? 'Confirmed' : 'Pending';
    final direction = isReceive ? 'Receive' : (isSend ? 'Send' : 'Self-transfer');
    final icon = isReceive ? Icons.arrow_downward : (isSend ? Icons.arrow_upward : Icons.sync);
    final color = isReceive ? Colors.green : (isSend ? Colors.orange : Colors.grey);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        'Bitcoin $direction',
        style: TextStyle(fontSize: fontSize, color: Colors.white),
      ),
      subtitle: Text(
        DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.timestamp),
        style: TextStyle(fontSize: fontSize, color: Colors.grey),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${isReceive ? '+' : '-'} $formattedAmount',
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
          Text(
            status,
            style: TextStyle(fontSize: fontSize, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Builds a ListTile for Liquid transactions (simplified)
  Widget _buildLiquidTransactionItem(
      LiquidTransaction transaction,
      BuildContext context,
      WidgetRef ref,
      double fontSize,
      ) {
    // Note: lwk.Tx might have balances for multiple assets; this is a basic implementation
    final status = transaction.lwkDetails.timestamp != null ? 'Confirmed' : 'Pending';
    // For simplicity, assume we show a placeholder; enhance with actual asset data if available
    return ListTile(
      leading: const Icon(Icons.water_drop, color: Colors.blue),
      title: Text(
        'Liquid Transaction',
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