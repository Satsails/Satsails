import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:Satsails/screens/shared/boltz_transactions_details_screen.dart';
import 'package:boltz/boltz.dart' as boltz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:intl/intl.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

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
  String locale = I18n.locale.languageCode ?? 'en';
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
        color: const Color(0x00333333).withOpacity(0.4),
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


class TransactionList extends ConsumerStatefulWidget {
  final bool showAll;
  final List<BaseTransaction>? transactions;

  const TransactionList({
    super.key,
    required this.showAll,
    this.transactions,
  });

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends ConsumerState<TransactionList> {
  // Initialize the RefreshController
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  // Define the refresh action
  Future<void> _onRefresh() async {
    await ref.read(backgroundSyncNotifierProvider.notifier).performSync();
    await ref.read(updateCurrencyProvider.future);
    await ref.read(getFiatPurchasesProvider.future);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final transactionState = ref.watch(transactionNotifierProvider);
    final allTransactions = widget.transactions ?? transactionState.allTransactionsSorted;

    final filteredTransactions = widget.showAll
        ? allTransactions
        : allTransactions
        .where((tx) =>
    !(tx is SideShiftTransaction && (tx.details.status == 'waiting' || tx.details.status == 'expired')) &&
        !(tx is BoltzTransaction && !(tx.details.completed ?? false)) &&
        !(tx is EulenTransaction &&
            (tx.details.failed ||
                tx.details.status == 'expired' ||
                tx.details.status == 'pending')) &&
        !(tx is NoxTransaction &&
            (tx.details.status == 'quote' ||
                tx.details.status == 'failed')))
        .take(4)
        .toList();

    final buyButton = GestureDetector(
      onTap: () {
        ref.read(navigationProvider.notifier).state = 3;
      },
      child: Padding(
        padding: EdgeInsets.only(right: 8.sp),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x00333333).withOpacity(0.4),
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
        if (!widget.showAll)
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
        if (!widget.showAll) const SizedBox(height: 8),
        Expanded(
          child: Card(
            color: const Color(0x00333333).withOpacity(0.4),
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
                  filteredTransactions.isEmpty
                      ? Expanded(
                    child: Center(
                      child: buildNoTransactionsFound(screenHeight),
                    ),
                  )
                      : Expanded(
                    child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: false,
                      header: ClassicHeader(
                          refreshingText: 'Refreshing'.i18n,
                          releaseText: 'Release'.i18n,
                          idleText: 'Pull down to refresh'.i18n
                      ),
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) => _buildUnifiedTransactionItem(
                          filteredTransactions[index],
                          context,
                          ref,
                        ),
                      ),
                    ),
                  ),
                if (!widget.showAll && isBalanceVisible)
                  TextButton(
                    onPressed: () {
                      context.pushNamed('transactions');
                    },
                    child: Text(
                      'See all transactions'.i18n,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _refreshController.dispose(); // Clean up the controller
    super.dispose();
  }
}

Widget _buildUnifiedTransactionItem(dynamic transaction, BuildContext context, WidgetRef ref) {
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
  } else if (transaction is BoltzTransaction) {
    transactionItem = _buildBoltzTransactionItem(transaction, context, ref);
  } else if (transaction is SideShiftTransaction) {
    transactionItem = _buildSideshiftTransactionItem(transaction, context, ref);
  } else {
    transactionItem = const SizedBox.shrink();
  }
  return transactionItem;
}

Widget _buildBoltzTransactionItem(
    BoltzTransaction transaction,
    BuildContext context,
    WidgetRef ref,
    ) {
  final isCompleted = transaction.details.completed ?? false;
  final statusText = isCompleted ? "Completed".i18n : "Pending".i18n;
  final isPending = !isCompleted;

  final btcFormat = ref.read(settingsProvider).btcFormat;
  final currency = ref.read(settingsProvider).currency;

  final isReceiving = transaction.details.swap.kind == boltz.SwapType.reverse;
  final title = isReceiving ? "Lightning${"to".i18n}L-BTC" : "L-BTC ${"to".i18n} Lightning";

  final amountBtc = isCompleted
      ? btcInDenominationFormatted(transaction.details.swap.outAmount, btcFormat)
      : null;
  final amountText = amountBtc;

  // Calculate fiat value using boltzTransactionAmountInFiat (only if completed)
  String? fiatValue;
  if (isCompleted) {
    try {
      fiatValue = boltzTransactionAmountInFiat(transaction.details, ref);
    } catch (e) {
      fiatValue = null; // Omit if function fails
    }
  }

  // Format date based on locale
  String locale = I18n.locale.languageCode;
  final formattedDate = DateFormat('d, MMMM, HH:mm', locale).format(
    DateTime.fromMillisecondsSinceEpoch(transaction.details.timestamp),
  );

  // Build the widget
  return GestureDetector(
    onTap: () {
      ref.read(selectedBoltzTransactionProvider.notifier).state = transaction;
      context.pushNamed('boltzTransactionDetails');
    },
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with optional progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              sideshiftTransactionTypeIcon(),
              if (isPending)
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    backgroundColor: Colors.transparent,
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          // Transaction details and amount
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
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (amountText != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amountText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (fiatValue != null)
                        Text(
                          fiatValue,
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
    ),
  );
}


Widget _buildSideshiftTransactionItem(
    SideShiftTransaction transaction,
    BuildContext context,
    WidgetRef ref,
    ) {
  final details = transaction.details;

  // Determine if the transaction is confirmed or pending
  final isConfirmed = details.status == "settled" || details.status == "expired";
  final isPending = !isConfirmed && details.status != "failed" && details.status != "expired";

  // Map the status to a user-friendly text
  String statusText;
  switch (details.status) {
    case 'waiting':
      statusText = 'Waiting for deposit'.i18n;
      break;
    case 'pending':
      statusText = 'Detected'.i18n;
      break;
    case 'processing':
      statusText = 'Confirmed'.i18n;
      break;
    case 'review':
      statusText = 'Under human review'.i18n;
      break;
    case 'settling':
      statusText = 'Settlement in progress'.i18n;
      break;
    case 'settled':
      statusText = 'Settlement completed'.i18n;
      break;
    case 'refund':
      statusText = 'Queued for refund'.i18n;
      break;
    case 'refunding':
      statusText = 'Refund in progress'.i18n;
      break;
    case 'refunded':
      statusText = 'Refund completed'.i18n;
      break;
    case 'expired':
      statusText = 'Shift expired'.i18n;
      break;
    case 'multiple':
      statusText = 'Multiple deposits detected'.i18n;
      break;
    default:
      statusText = 'Unknown'.i18n;
      break;
  }

  // Transaction title showing the shift direction
  String title = '';
  if (['solana', 'bsc', 'ethereum'].contains(details.depositNetwork.toLowerCase())) {
    title = "${details.depositCoin} ${"to".i18n} ${details.settleNetwork.capitalize()} ${details.settleCoin}";
  } else {
    title = "${details.depositNetwork.capitalize()} ${details.depositCoin} ${"to".i18n} ${details.settleNetwork.capitalize()} ${details.settleCoin}";
  }
  String locale = I18n.locale.languageCode ?? 'en';
  // Format the transaction date
  final formattedDate = DateFormat('d, MMMM, HH:mm', locale).format(transaction.timestamp);

  return GestureDetector(
    onTap: () {
      context.pushNamed('sideshiftTransactionDetails', extra: transaction);
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
              // Transaction type icon with optional progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  sideshiftTransactionTypeIcon(),
                  if (isPending)
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
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
                        Text(
                          statusText,
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (isConfirmed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${double.parse(details.settleAmount).toStringAsFixed(2)} ${details.settleCoin}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

Widget _buildSideswapPegTransactionItem(
    SideswapPegTransaction transaction, BuildContext context, WidgetRef ref) {
  final sideswapPegDetails = transaction.sideswapPegDetails;

  final date = sideswapPegDetails.list?.isNotEmpty == true &&
      sideswapPegDetails.list!.first.createdAt != null
      ? DateTime.fromMillisecondsSinceEpoch(
      sideswapPegDetails.list!.first.createdAt!)
      : transaction.timestamp;

  String locale = I18n.locale.languageCode ?? 'en';
  final formattedDate = DateFormat('d MMMM, HH:mm', locale).format(date);

  // Transaction type
  final transactionType =
  sideswapPegDetails.pegIn == true ? 'BTC ${"to".i18n} L-BTC' : 'L-BTC ${"to".i18n} BTC';

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
  final isConfirmed = transaction.isConfirmed;
  final isPending = !isConfirmed && !transaction.details.failed && transaction.details.status != "expired";
  final statusText = transaction.details.failed
      ? "Failed".i18n
      : transaction.details.completed
      ? "Completed".i18n
      : "Pending".i18n;

  final type = transaction.details.transactionType.toString() == "BUY" ? "(Purchase)".i18n : "(Withdrawal)".i18n;
  final title = "${transaction.details.to_currency} $type";
  final amount = transaction.details.receivedAmount.toString();
  String locale = I18n.locale.languageCode ?? 'en';
  final formattedDate = DateFormat('d, MMMM, HH:mm', locale).format(transaction.timestamp);

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction type icon with optional progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  eulenTransactionTypeIcon(),
                  if (isPending)
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
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
                    if (isConfirmed)
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
  final isConfirmed = transaction.isConfirmed;
  final isPending = !isConfirmed && !transaction.details.failed && transaction.details.status != "expired";
  final statusText = transaction.details.failed
      ? "Failed".i18n
      : transaction.details.completed
      ? "Completed".i18n
      : "Pending".i18n;

  final type = transaction.details.transactionType.toString() == "BUY" ? "Purchase".i18n : "Withdrawal".i18n;
  final title = "${transaction.details.to_currency} $type";
  final amount = transaction.details.receivedAmount.toString();
  String locale = I18n.locale.languageCode ?? 'en';
  final formattedDate = DateFormat('d, MMMM, HH:mm', locale).format(transaction.timestamp);

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction type icon with optional progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  eulenTransactionTypeIcon(), // Note: Assuming Nox uses same icon as Eulen; adjust if different
                  if (isPending)
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
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
                    if (isConfirmed)
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
  final isPending = !isConfirmed;

  // Format the transaction date
  final timestamp = transaction.btcDetails.confirmationTime?.timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(
      transaction.btcDetails.confirmationTime!.timestamp.toInt() * 1000)
      : transaction.timestamp;
  String locale = I18n.locale.languageCode ?? 'en';
  final formattedDate = DateFormat('d, MMMM, HH:mm', locale).format(timestamp);

  return GestureDetector(
    onTap: () {
      context.pushNamed('transactionDetails', extra: transaction);
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
              // Transaction type icon with optional progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  transactionTypeIcon(transaction.btcDetails),
                  if (isPending)
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          transactionAmount(transaction.btcDetails, ref),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          transactionAmountInFiat(transaction.btcDetails, ref),
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

Widget _buildLiquidTransactionItem(
    LiquidTransaction transaction, BuildContext context, WidgetRef ref) {
  final isConfirmed = transaction.lwkDetails.timestamp != null;
  final isPending = !isConfirmed;

  // Format the transaction date
  final timestamp = transaction.lwkDetails.timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(transaction.lwkDetails.timestamp! * 1000)
      : transaction.timestamp;
  String locale = I18n.locale.languageCode ?? 'en';
  final formattedDate = DateFormat('d, MMMM, HH:mm', locale).format(timestamp);

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
    tickerDisplay = positiveStr.isNotEmpty ? '$negativeStr ${"to".i18n} $positiveStr' : negativeStr;
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction type icon with optional progress indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  transactionTypeLiquidIcon(transaction.lwkDetails.kind),
                  if (isPending)
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
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