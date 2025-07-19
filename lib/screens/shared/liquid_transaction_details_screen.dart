import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/helpers/formatters.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LiquidTransactionDetailsScreen extends ConsumerWidget {
  final LiquidTransaction transaction;

  const LiquidTransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final denomination = ref.read(settingsProvider).btcFormat;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Liquid Transaction Details'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold,),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0x00333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
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
                        SizedBox(width: 8.w),
                        confirmationStatusIcon(transaction.lwkDetails),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      liquidTransactionType(transaction.lwkDetails),
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade700),
              SizedBox(height: 16.h),
              Text(
                "Transaction Details".i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TransactionDetailRow(
                label: "Date".i18n,
                value: timestampToDateTime(transaction.lwkDetails.timestamp),
              ),
              SizedBox(height: 16.h),
              Text(
                "Amounts".i18n,
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              ...transaction.lwkDetails.balances.map((balance) {
                return TransactionDetailRow(
                  label: AssetMapper.mapAsset(balance.assetId).name,
                  value: btcInDenominationFormatted(
                    balance.value,
                    denomination,
                    AssetMapper.mapAsset(balance.assetId) == AssetId.LBTC,
                  ),
                  amount: balance.value,
                );
              }),
              TransactionDetailRow(
                label: "Fee".i18n,
                value: "${btcInDenominationFormatted(transaction.lwkDetails.fee.toInt(), denomination)} $denomination",
              ),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey.shade700),
              GestureDetector(
                onTap: () async {
                  setTransactionSearchProvider(transaction.lwkDetails, ref);
                  context.push('/search_modal');
                },
                child: Container(
                  margin: EdgeInsets.only(top: 12.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 24.w),
                      SizedBox(width: 8.w),
                      Text(
                        "Search on Mempool".i18n,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
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
    // Map of asset tickers to their icon paths
    final assetIcons = {
      'L-BTC': 'lib/assets/l-btc.png',
      'Fee': 'lib/assets/l-btc.png',
      'USDT': 'lib/assets/tether.png',
      'EURx': 'lib/assets/eurx.png',
      'Depix': 'lib/assets/depix.png',
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (assetIcons[label] != null)
                Image.asset(
                  assetIcons[label]!,
                  width: 24.w,
                  height: 24.h,
                ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
            ],
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
        ],
      ),
    );
  }
}