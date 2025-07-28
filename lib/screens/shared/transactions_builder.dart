import 'dart:async';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:Satsails/screens/shared/lightning_conversion_transaction_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;
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
  final List<BaseTransaction> transactions;

  const TransactionListByWeek({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<DateTime, List<BaseTransaction>> groupedTransactions = {};
    for (var tx in transactions) {
      final monthKey = DateTime(tx.timestamp.year, tx.timestamp.month, 1);
      groupedTransactions.putIfAbsent(monthKey, () => []).add(tx);
    }

    final sortedMonths = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedMonths.isEmpty) {
      return Center(
        child: buildNoTransactionsFound(MediaQuery.of(context).size.height),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final transactionsInMonth = groupedTransactions[month]!;
        return _buildMonthGroup(context, ref, month, transactionsInMonth, index);
      },
    );
  }
}

Widget _buildMonthGroup(
    BuildContext context,
    WidgetRef ref,
    DateTime month,
    List<BaseTransaction> transactions,
    int index) {
  String locale = I18n.locale.languageCode ?? 'en';
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(16.w, index == 0 ? 0 : 24.h, 16.w, 8.h),
        child: Text(
          DateFormat('MMMM yyyy', locale).format(month),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0x00333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, txIndex) {
            final tx = transactions[txIndex];
            return _buildUnifiedTransactionItem(tx, context, ref);
          },
          separatorBuilder: (context, index) => Divider(
            color: Colors.white.withOpacity(0.1),
            height: 1.h,
            indent: 60.w,
          ),
        ),
      ),
    ],
  );
}

class TransactionList extends ConsumerStatefulWidget {
  const TransactionList({
    super.key,
  });

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends ConsumerState<TransactionList> {
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  Future<void> _onRefresh() async {
    await ref.read(backgroundSyncNotifierProvider.notifier).performFullUpdate();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;
    final transactionState = ref.watch(transactionNotifierProvider);

    // Fetch the lists from the provider's state using your getters
    final settledTransactions = transactionState.value?.settledTransactions ?? [];
    final allTransactions = transactionState.value?.allTransactionsSorted ?? [];

    final buyButton = GestureDetector(
      onTap: () => ref.read(navigationProvider.notifier).state = 3,
      child: Padding(
        padding: EdgeInsets.only(right: 8.sp),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          child: Text(
            'Buy'.i18n,
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    return Column(
      children: [
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
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x00333333).withOpacity(0.4),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Column(
              children: [
                Expanded(
                  child: !isBalanceVisible
                      ? Center(
                      child: Text('Transactions hidden'.i18n,
                          style: TextStyle(
                              fontSize: 16.sp, color: Colors.grey)))
                      : settledTransactions.isEmpty
                      ? Center(
                      child: buildNoTransactionsFound(screenHeight))
                      : SmartRefresher(
                    enablePullDown: true,
                    header: ClassicHeader(
                        refreshingText: 'Refreshing'.i18n,
                        releaseText: 'Release'.i18n,
                        idleText: 'Pull down to refresh'.i18n),
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: settledTransactions.length,
                      itemBuilder: (context, index) =>
                          _buildUnifiedTransactionItem(
                            settledTransactions[index],
                            context,
                            ref,
                          ),
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.1),
                        height: 1.h,
                        indent: 60.w,
                      ),
                    ),
                  ),
                ),
                if (isBalanceVisible && allTransactions.isNotEmpty)
                  TextButton(
                    onPressed: () => context.pushNamed('transactions'),
                    child: Text(
                      'See all transactions'.i18n,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildUnifiedTransactionItem(BaseTransaction transaction, BuildContext context, WidgetRef ref) {
  if (transaction is SideswapPegTransaction) {
    return _buildSideswapPegTransactionItem(transaction, context, ref);
  }
  if (transaction is BitcoinTransaction) {
    return _buildBitcoinTransactionItem(transaction, context, ref);
  }
  if (transaction is LiquidTransaction) {
    return _buildLiquidTransactionItem(transaction, context, ref);
  }
  if (transaction is EulenTransaction) {
    return _buildEulenTransactionItem(transaction, context, ref);
  }
  if (transaction is NoxTransaction) {
    return _buildNoxTransactionItem(transaction, context, ref);
  }
  if (transaction is LightningConversionTransaction) {
    return _buildLightningConversionTransactionItem(transaction, context, ref);
  }
  if (transaction is SideShiftTransaction) {
    return _buildSideshiftTransactionItem(transaction, context, ref);
  }
  return const SizedBox.shrink();
}

Widget _buildTransactionItemLayout({
  required BuildContext context,
  required WidgetRef ref,
  required Widget icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  bool isPending = false,
  Widget? amountContent,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: icon,
              ),
              if (isPending)
                SizedBox(
                  width: 42.w,
                  height: 42.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          if (amountContent != null)
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: amountContent,
            ),
        ],
      ),
    ),
  );
}

Widget _buildLightningConversionTransactionItem(LightningConversionTransaction transaction, BuildContext context, WidgetRef ref) {
  final details = transaction.details;
  final isCompleted = transaction.isConfirmed;
  final isReceiving = details.paymentType == breez.PaymentType.receive;
  final title = isReceiving ? "Lightning → Liquid Bitcoin".i18n : "Liquid Bitcoin → Lightning".i18n;

  final locale = I18n.locale.languageCode;
  final formattedDate = DateFormat('d MMM, HH:mm', locale).format(transaction.timestamp);
  final statusText = isCompleted ? formattedDate : "Pending".i18n;
  final subtitle = statusText;
  final denomination = ref.read(settingsProvider).btcFormat;
  final amountSat = details.amountSat.toInt();
  final amountString = btcInDenominationFormatted(amountSat, denomination);
  final fiatValue = lightningConversionTransactionAmountInFiat(transaction, ref);

  return _buildTransactionItemLayout(
    context: context,
    ref: ref,
    onTap: () {
      ref.read(selectedLightningTransactionProvider.notifier).state = transaction;
      context.pushNamed('lightningConversionTransactionDetails');
    },
    icon: lightningTransactionTypeIcon(),
    isPending: !isCompleted,
    title: title,
    subtitle: subtitle,
    amountContent: isCompleted
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amountString,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          fiatValue,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
        ),
      ],
    )
        : null,
  );
}

Widget _buildSideshiftTransactionItem(SideShiftTransaction transaction, BuildContext context, WidgetRef ref) {
  final details = transaction.details;
  final isPending = !['settled', 'expired', 'failed', 'refunded'].contains(details.status);
  final title = "${details.depositNetwork.capitalize()} ${details.depositCoin.toUpperCase()} → ${details.settleNetwork.capitalize()} ${details.settleCoin.toUpperCase()}";
  final locale = I18n.locale.languageCode;
  final formattedDate = DateFormat('d MMM, HH:mm', locale).format(transaction.timestamp);
  final statusText = isPending ? (details.status ?? '').capitalize() : formattedDate;

  return _buildTransactionItemLayout(
    context: context,
    ref: ref,
    onTap: () => context.pushNamed('sideshiftTransactionDetails', extra: transaction),
    icon: sideshiftTransactionTypeIcon(),
    isPending: isPending,
    title: title,
    subtitle: statusText,
    amountContent: details.status == 'settled'
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if(details.depositAmount != null)
          Text(
            "- ${details.depositAmount} ${details.depositCoin.toUpperCase()}",
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.7)),
          ),
        SizedBox(height: 2.h),
        if(details.settleAmount != null)
          Text(
            "${double.parse(details.settleAmount!).toStringAsFixed(2)} ${details.settleCoin.toUpperCase()}",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
      ],
    )
        : null,
  );
}

Widget _buildSideswapPegTransactionItem(SideswapPegTransaction transaction, BuildContext context, WidgetRef ref) {
  final details = transaction.sideswapPegDetails;
  final title = details.pegIn == true ? 'BTC → L-BTC' : 'L-BTC → BTC';
  final date = details.list?.firstOrNull?.createdAt != null
      ? DateTime.fromMillisecondsSinceEpoch(details.list!.first.createdAt!)
      : transaction.timestamp;
  final locale = I18n.locale.languageCode;
  final formattedDate = DateFormat('d MMM, HH:mm', locale).format(date);

  return _buildTransactionItemLayout(
    context: context,
    ref: ref,
    onTap: () {
      ref.read(orderIdStatusProvider.notifier).state = details.orderId ?? '';
      ref.read(pegInStatusProvider.notifier).state = details.pegIn ?? false;
      context.pushNamed('pegDetails', extra: transaction.sideswapPegDetails);
    },
    icon: pegTransactionTypeIcon(),
    title: title,
    subtitle: formattedDate,
    amountContent: Text(
      "See status".i18n,
      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white70),
    ),
  );
}

Widget _buildEulenTransactionItem(EulenTransaction transaction, BuildContext context, WidgetRef ref) {
  final details = transaction.details;
  final isPending = !details.completed && !details.failed && details.status != "expired";
  final type = details.transactionType.toString() == "BUY" ? "Purchase".i18n : "Withdrawal".i18n;
  final title = "${details.to_currency} ($type)";
  final locale = I18n.locale.languageCode;
  final formattedDate = DateFormat('d MMM, HH:mm', locale).format(transaction.timestamp);
  final statusText = isPending ? (details.status ?? '').capitalize() : formattedDate;
  final isBuy = details.transactionType.toString() == "BUY";

  return _buildTransactionItemLayout(
    context: context,
    ref: ref,
    onTap: () {
      ref.read(selectedEulenTransferIdProvider.notifier).state = details.id;
      context.pushNamed('eulen_transaction_details');
    },
    icon: eulenTransactionTypeIcon(),
    isPending: isPending,
    title: title,
    subtitle: statusText,
    amountContent: details.completed
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${isBuy ? '-' : ''}${details.price} USD",
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.7)),
        ),
        SizedBox(height: 2.h),
        Text(
          "${isBuy ? '' : '-'}${details.receivedAmount} ${details.from_currency}",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    )
        : null,
  );
}

Widget _buildNoxTransactionItem(NoxTransaction transaction, BuildContext context, WidgetRef ref) {
  final details = transaction.details;
  final isPending = !details.completed && !details.failed && details.status != "expired";
  final type = details.transactionType.toString() == "BUY" ? "Purchase".i18n : "Withdrawal".i18n;
  final title = "${details.to_currency} ($type)";
  final locale = I18n.locale.languageCode;
  final formattedDate = DateFormat('d MMM, HH:mm', locale).format(transaction.timestamp);
  final statusText = isPending ? (details.status ?? '').capitalize() : formattedDate;
  final isBuy = details.transactionType.toString() == "BUY";

  return _buildTransactionItemLayout(
    context: context,
    ref: ref,
    onTap: () {
      ref.read(selectedNoxTransferIdProvider.notifier).state = transaction.details.id;
      context.pushNamed('nox_transaction_details');
    },
    icon: eulenTransactionTypeIcon(),
    isPending: isPending,
    title: title,
    subtitle: statusText,
    amountContent: details.completed
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${isBuy ? '-' : ''}${details.price} USD",
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.7)),
        ),
        SizedBox(height: 2.h),
        Text(
          "${isBuy ? '' : '-'}${details.receivedAmount} ${details.from_currency}",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    )
        : null,
  );
}

Widget _buildBitcoinTransactionItem(BitcoinTransaction transaction, BuildContext context, WidgetRef ref) {
  final details = transaction.btcDetails;
  final isPending = details.confirmationTime == null;
  final title = "Bitcoin";
  final timestamp = isPending
      ? transaction.timestamp
      : DateTime.fromMillisecondsSinceEpoch(details.confirmationTime!.timestamp.toInt() * 1000);
  final locale = I18n.locale.languageCode;
  final formattedDate = DateFormat('d MMM, HH:mm', locale).format(timestamp);
  final statusText = isPending ? "Pending".i18n : formattedDate;

  return _buildTransactionItemLayout(
    context: context,
    ref: ref,
    onTap: () => context.pushNamed('transactionDetails', extra: transaction),
    icon: transactionTypeIcon(details),
    isPending: isPending,
    title: title,
    subtitle: statusText,
    amountContent: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          transactionAmount(details, ref).replaceFirst('+', ''),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          transactionAmountInFiat(details, ref),
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
        ),
      ],
    ),
  );
}

Widget _buildLiquidTransactionItem(LiquidTransaction transaction, BuildContext context, WidgetRef ref) {
  final details = transaction.lwkDetails;
  final isPending = details.timestamp == null;
  final balancesToShow = details.balances.where((b) {
    if (details.balances.length > 1 && b.assetId == AssetMapper.reverseMapTicker(AssetId.LBTC) && b.value.abs() < 100) {
      return false;
    }
    return true;
  }).toList();

  final positiveTickers = balancesToShow.where((b) => b.value > 0).map((b) => AssetMapper.mapAsset(b.assetId).name).toSet().toList();
  final negativeTickers = balancesToShow.where((b) => b.value < 0).map((b) => AssetMapper.mapAsset(b.assetId).name).toSet().toList();

  String title;
  if (negativeTickers.isNotEmpty) {
    final negativeStr = negativeTickers.join(' + ');
    final positiveStr = positiveTickers.join(' + ');
    title = positiveStr.isNotEmpty ? '$negativeStr → $positiveStr' : negativeStr;
  } else {
    title = positiveTickers.join(' + ');
  }

  final timestamp = isPending ? transaction.timestamp : DateTime.fromMillisecondsSinceEpoch(details.timestamp! * 1000);
  final locale = I18n.locale.languageCode;
  final formattedDate = DateFormat('d MMM, HH:mm', locale).format(timestamp);
  final statusText = isPending ? "Pending".i18n : formattedDate;

  return _buildTransactionItemLayout(
    context: context,
    ref: ref,
    onTap: () => context.pushNamed('liquidTransactionDetails', extra: transaction),
    icon: transactionTypeLiquidIcon(details.kind),
    isPending: isPending,
    title: title.replaceFirst('L-BTC', 'Liquid Bitcoin'),
    subtitle: statusText,
    amountContent: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: balancesToShow.map((balance) {
        final asset = AssetMapper.mapAsset(balance.assetId);
        return Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                valueOfLiquidSubTransaction(asset, balance.value, ref).replaceFirst('+', ''),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (asset == AssetId.LBTC)
                Text(
                  liquidTransactionAmountInFiat(balance, ref),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}