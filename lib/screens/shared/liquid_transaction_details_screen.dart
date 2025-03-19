import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:go_router/go_router.dart';

class LiquidTransactionDetailsScreen extends ConsumerWidget {
  final LiquidTransaction transaction;

  const LiquidTransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double dynamicMargin = 16.0;
    const double dynamicRadius = 12.0;
    final denomination = ref.read(settingsProvider).btcFormat;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liquid Transaction Details'.i18n,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: dynamicMargin, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(dynamicRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        transactionTypeLiquidIcon(transaction.lwkDetails.kind),
                        const SizedBox(width: 8.0),
                        confirmationStatusIcon(transaction.lwkDetails),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(liquidTransactionType(transaction.lwkDetails), style: const TextStyle(color: Colors.white, fontSize: 18)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 16.0),
              Text(
                "Transaction Details".i18n,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Date".i18n,
                value: timestampToDateTime(transaction.lwkDetails.timestamp),
              ),
              const SizedBox(height: 16.0),
              Text(
                "Amounts".i18n,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              ...transaction.lwkDetails.balances.map((balance) {
                return TransactionDetailRow(
                  label: AssetMapper.mapAsset(balance.assetId).name,
                  value: btcInDenominationFormatted(balance.value, denomination, AssetMapper.mapAsset(balance.assetId) == AssetId.LBTC),
                  amount: balance.value,
                );
              }).toList(),
              TransactionDetailRow(
                label: "Fee".i18n,
                value: "${btcInDenominationFormatted(transaction.lwkDetails.fee.toInt(), denomination)} $denomination",
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              GestureDetector(
                onTap: () async {
                  setTransactionSearchProvider(transaction.lwkDetails, ref);
                  context.push('/search_modal');
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(dynamicRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Text(
                        "Search on Mempool".i18n,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final int? amount;

  const TransactionDetailRow({super.key, required this.label, required this.value, this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              amount != null ? subTransactionIndicator(amount!) : const SizedBox.shrink(),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
