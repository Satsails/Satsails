import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';

class LiquidTransactionDetailsScreen extends ConsumerWidget {
  final Tx transaction;

  const LiquidTransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double dynamicMargin = 16.0;
    const double dynamicRadius = 12.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liquid Transaction Details'.i18n(ref),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
                        transactionTypeLiquidIcon(transaction.kind),
                        const SizedBox(width: 8.0),
                        confirmationStatusIcon(transaction),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(liquidTransactionType(transaction, ref), style: const TextStyle(color: Colors.white, fontSize: 18)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              const SizedBox(height: 16.0),
              Text(
                "Transaction Details".i18n(ref),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TransactionDetailRow(
                label: "Date".i18n(ref),
                value: timestampToDateTime(transaction.timestamp),
              ),
              const SizedBox(height: 16.0),
              Text(
                "Amounts".i18n(ref),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              ...transaction.balances.map((balance) {
                return TransactionDetailRow(
                  label: AssetMapper.mapAsset(balance.assetId).name,
                  value: balance.value.toString(),
                  amount: balance.value,
                );
              }).toList(),
              TransactionDetailRow(
                label: "Fee".i18n(ref),
                value: "${transaction.fee}",
              ),
              const SizedBox(height: 16.0),
              Divider(color: Colors.grey.shade700),
              GestureDetector(
                onTap: () async {
                  setTransactionSearchProvider(transaction, ref);
                  Navigator.pushNamed(context, '/search_modal');
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
                        "Search on Mempool".i18n(ref),
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
              amount != null ? subTransactionIcon(amount!) : const SizedBox.shrink(),
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
