import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:intl/intl.dart';
import 'package:Satsails/providers/settings_provider.dart';

Widget buildNoTransactionsFound(double screenHeight) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'No transactions found'.i18n,
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.grey,
        ),
      ),
    ],
  );
}

class TransactionListByWeek extends ConsumerWidget {
  final List<BaseTransaction> transactions; // Required parameter

  const TransactionListByWeek({
    super.key,
    required this.transactions, // Marked as required
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group transactions by month
    final Map<DateTime, List<BaseTransaction>> groupedTransactions = {};
    for (var tx in transactions) {
      // Normalize to the first day of the month for grouping
      final monthKey = DateTime(tx.timestamp.year, tx.timestamp.month, 1);
      groupedTransactions.putIfAbsent(monthKey, () => []).add(tx);
    }

    // Convert to a sorted list of months (descending order: most recent first)
    final sortedMonths = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Check if there are no transactions
    if (sortedMonths.isEmpty) {
      return Center(
        child: buildNoTransactionsFound(MediaQuery.of(context).size.height),
      );
    }

    // If there are transactions, build the list
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final transactionsInMonth = groupedTransactions[month]!;
        return _buildMonthCard(context, ref, month, transactionsInMonth);
      },
    );
  }
}

Widget _buildMonthCard(
    BuildContext context,
    WidgetRef ref,
    DateTime month,
    List<BaseTransaction> transactions) {
  String locale = I18n.locale?.languageCode ?? 'en';
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text(
          DateFormat('MMMM yyyy', locale).format(month),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      Card(
        color: const Color(0x333333).withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // List of transactions for this month
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, txIndex) {
                final tx = transactions[txIndex];
                return _buildUnifiedTransactionItem(tx, context, ref);
              },
            ),
          ],
        ),
      ),
    ],
  );
}

class TransactionList extends ConsumerWidget {
  final bool showAll;
  final dynamic transactions; // New parameter for custom transactions

  const TransactionList({
    super.key,
    this.showAll = false,
    this.transactions, // Optional parameter, defaults to null
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final transactionState = ref.watch(transactionNotifierProvider);
    final List<BaseTransaction> transactionList = transactions != null
        ? (transactions as List<BaseTransaction>)
        : transactionState.allTransactionsSorted;

    final buyButton = GestureDetector(
      onTap: () {
        ref.read(navigationProvider.notifier).state = 3;
      },
      child: Padding(
        padding: EdgeInsets.only(right: 8.sp),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0x333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          child: Text(
            'Buy'.i18n,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;

    return Column(
      children: [
        if (!showAll)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: BackupWarning(),
              ),
              buyButton,
            ],
          ),
        if (!showAll) const SizedBox(height: 8),
        Expanded(
          child: Card(
            color: const Color(0x333333).withOpacity(0.4),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isBalanceVisible)
                  Expanded(
                    child: Center(
                      child: Text(
                        'Transactions hidden'.i18n,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  transactionList.isEmpty
                      ? Expanded(
                    child: Center(
                      child: buildNoTransactionsFound(screenHeight),
                    ),
                  )
                      : _buildTransactionList(
                    context,
                    transactionList.length,
                        (index) => _buildUnifiedTransactionItem(
                        transactionList[index], context, ref),
                    showAll,
                  ),
                if (!showAll && isBalanceVisible)
                  TextButton(
                    onPressed: () {
                      context.pushNamed('transactions');
                    },
                    child: Text(
                      'See all transactions'.i18n,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
      BuildContext context,
      int itemCount,
      Widget Function(int) itemBuilder,
      bool showAll,
      ) {
    if (showAll) {
      return Expanded(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) => itemBuilder(index),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: itemCount < 4 ? itemCount : 4,
          itemBuilder: (context, index) => itemBuilder(index),
        ),
      );
    }
  }
}

Widget _buildUnifiedTransactionItem(
    dynamic transaction, BuildContext context, WidgetRef ref) {
  Widget transactionItem;
  if (transaction is SideswapPegTransaction) {
    transactionItem = _buildSideswapPegTransactionItem(transaction, context, ref);
  } else if (transaction is BitcoinTransaction) {
    transactionItem = _buildBitcoinTransactionItem(transaction, context, ref);
  } else if (transaction is LiquidTransaction) {
    transactionItem = _buildLiquidTransactionItem(transaction, context, ref);
  } else if (transaction is EulenTransaction) {
    transactionItem = _buildEulenTransactionItem(transaction, context, ref);
  } else if (transaction is NoxTransaction) {
    transactionItem = _buildNoxTransactionItem(transaction, context, ref);
  } else {
    transactionItem = const SizedBox();
  }
  return transactionItem;
}

Widget _buildSideswapPegTransactionItem(
    SideswapPegTransaction transaction, BuildContext context, WidgetRef ref) {
  final sideswapPegDetails = transaction.sideswapPegDetails;

  final date = sideswapPegDetails.list?.isNotEmpty == true &&
      sideswapPegDetails.list!.first.createdAt != null
      ? DateTime.fromMillisecondsSinceEpoch(
      sideswapPegDetails.list!.first.createdAt!)
      : transaction.timestamp;
  final formattedDate = DateFormat('d MMMM, HH:mm').format(date);

  // Transaction type
  final transactionType =
  sideswapPegDetails.pegIn == true ? 'BTC - L-BTC' : 'L-BTC - BTC';

  return GestureDetector(
    onTap: () {
      // Update providers and navigate
      ref.read(orderIdStatusProvider.notifier).state =
          sideswapPegDetails.orderId ?? '';
      ref.read(pegInStatusProvider.notifier).state =
          sideswapPegDetails.pegIn ?? false;
      context.pushNamed('pegDetails', extra: transaction.sideswapPegDetails);
    },
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pegTransactionTypeIcon(),
              SizedBox(width: 12.w), // Responsive spacing
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Transaction type and date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transactionType,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    // Amount and fiat value
                    Text(
                      "See status".i18n,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildEulenTransactionItem(
    EulenTransaction transaction,
    BuildContext context,
    WidgetRef ref,
    ) {
  final isConfirmed = transaction.isConfirmed || transaction.details.status == "expired";
  final statusText = transaction.details.failed
      ? "Failed".i18n
      : transaction.details.completed
      ? "Completed".i18n
      : "Pending".i18n;
  final status = transaction.details.status;

  final type = transaction.details.transactionType.toString() == "BUY" ? "Purchase".i18n : "Withdrawal".i18n;
  final title = "${transaction.details.to_currency} $type";
  final amount = transaction.details.receivedAmount.toString();
  final formattedDate = DateFormat('d, MMMM, HH:mm').format(transaction.timestamp);

  // Check if the transaction is failed or expired
  final isFailedOrExpired = status == "failed" || status == "expired";

  return GestureDetector(
    onTap: () {
      ref.read(selectedEulenTransferIdProvider.notifier).state = transaction.details.id;
      context.pushNamed('eulen_transaction_details');
    },
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show progress indicator only if transaction is pending (not failed or expired)
          if (!isConfirmed && !isFailedOrExpired)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 4,
              ),
            ),
          // Main content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction type icon
              eulenTransactionTypeIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp, // Consistent with Bitcoin item
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          statusText.toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (transaction.isConfirmed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$amount ${transaction.details.from_currency}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${transaction.details.price} USD',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[400],
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
  );
}

Widget _buildNoxTransactionItem(
    NoxTransaction transaction,
    BuildContext context,
    WidgetRef ref,
    ) {
  final isConfirmed = transaction.isConfirmed || transaction.details.status == "expired";
  final statusText = transaction.details.failed
      ? "Failed".i18n
      : transaction.details.completed
      ? "Completed".i18n
      : "Pending".i18n;
  final status = transaction.details.status;

  final type = transaction.details.transactionType.toString() == "BUY" ? "Purchase".i18n : "Withdrawal".i18n;
  final title = "${transaction.details.to_currency} $type";
  final amount = transaction.details.receivedAmount.toString();
  final formattedDate = DateFormat('d, MMMM, HH:mm').format(transaction.timestamp);

  // Check if the transaction is failed or expired
  final isFailedOrExpired = status == "failed" || status == "expired";

  return GestureDetector(
    onTap: () {
      ref.read(selectedNoxTransferIdProvider.notifier).state = transaction.details.id;
      context.pushNamed('nox_transaction_details');
    },
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show progress indicator only if transaction is pending (not failed or expired)
          if (!isConfirmed && !isFailedOrExpired)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 4,
              ),
            ),
          // Main content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction type icon
              eulenTransactionTypeIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp, // Consistent with Bitcoin item
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          statusText.toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (transaction.isConfirmed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$amount ${transaction.details.from_currency}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${transaction.details.price} USD',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[400],
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
  );
}

Widget _buildBitcoinTransactionItem(
    BitcoinTransaction transaction, BuildContext context, WidgetRef ref) {
  // Determine if the transaction is confirmed
  final isConfirmed = transaction.btcDetails.confirmationTime != null;

  // Format the transaction date
  final timestamp = transaction.btcDetails.confirmationTime?.timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(
      transaction.btcDetails.confirmationTime!.timestamp.toInt() * 1000)
      : transaction.timestamp;
  final formattedDate = DateFormat('d, MMMM, HH:mm').format(timestamp);

  return GestureDetector(
    onTap: () {
      context.pushNamed('transactionDetails', extra: transaction);
    },
    behavior: HitTestBehavior.opaque, // Makes the entire area tappable
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
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 4,
              ),
            ),
          // Main content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction type icon
              transactionTypeIcon(transaction.btcDetails),
              const SizedBox(width: 12), // Consistent spacing after icon
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bitcoin",
                          style: TextStyle(
                            fontSize: 16.sp, // Matches tickerDisplay
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14.sp, // Matches date
                            color: Colors.grey[400], // Lighter color
                          ),
                        ),
                      ],
                    ),
                    // Transaction amount and fiat value on the right
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transactionAmount(transaction.btcDetails, ref),
                          style: TextStyle(
                            fontSize: 14.sp, // Matches balance values
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          transactionAmountInFiat(transaction.btcDetails, ref),
                          style: TextStyle(
                            fontSize: 12.sp, // Matches fiat value
                            color: Colors.grey[400],
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
  );
}

Widget _buildLiquidTransactionItem(
    LiquidTransaction transaction, BuildContext context, WidgetRef ref) {
  final isConfirmed = transaction.lwkDetails.timestamp != null;

  // Format the transaction date
  final timestamp = transaction.lwkDetails.timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(transaction.lwkDetails.timestamp! * 1000)
      : transaction.timestamp;
  final formattedDate = DateFormat('d, MMMM, HH:mm').format(timestamp);

  // Filter balances: exclude small LBTC balances when there are multiple balances
  final balancesToShow = transaction.lwkDetails.balances.where((balance) {
    if (transaction.lwkDetails.balances.length > 1 &&
        balance.assetId == AssetMapper.reverseMapTicker(AssetId.LBTC)) {
      final satoshiValue = balance.value.abs();
      if (satoshiValue < 100) {
        return false; // Exclude small LBTC balance
      }
    }
    return true; // Include all other balances
  }).toList();

  // Separate balances into negative and positive
  final negativeBalances = balancesToShow.where((b) => b.value < 0).toList();
  final positiveBalances = balancesToShow.where((b) => b.value > 0).toList();

  // Get unique tickers for negative and positive balances
  final negativeTickers =
  negativeBalances.map((b) => AssetMapper.mapAsset(b.assetId).name).toSet().toList();
  final positiveTickers =
  positiveBalances.map((b) => AssetMapper.mapAsset(b.assetId).name).toSet().toList();

  // Construct tickerDisplay based on balances
  String tickerDisplay;
  if (negativeTickers.isNotEmpty) {
    final negativeStr = negativeTickers.join(' + ');
    final positiveStr = positiveTickers.join(' + ');
    tickerDisplay = positiveStr.isNotEmpty ? '$negativeStr -> $positiveStr' : negativeStr;
  } else {
    tickerDisplay = positiveTickers.join(' + ');
  }

  return GestureDetector(
    onTap: () {
      context.pushNamed('liquidTransactionDetails', extra: transaction);
    },
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show progress indicator for unconfirmed transactions
          if (!isConfirmed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 4,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              transactionTypeLiquidIcon(transaction.lwkDetails.kind),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tickerDisplay == 'L-BTC' ? "Liquid Bitcoin" : tickerDisplay,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              // Display filtered balances
              if (balancesToShow.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: balancesToShow.map((balance) {
                    final asset = AssetMapper.mapAsset(balance.assetId);
                    final value = valueOfLiquidSubTransaction(asset, balance.value, ref);
                    final fiatValue = asset == AssetId.LBTC
                        ? liquidTransactionAmountInFiat(balance, ref)
                        : '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$value${asset.name == 'L-BTC' ? '' : " ${asset.name}"}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (fiatValue.isNotEmpty)
                            Text(
                              fiatValue,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}