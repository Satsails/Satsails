import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/common_operation_methods.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lwk/lwk.dart';

class LiquidTransactionDetailsScreen extends ConsumerWidget {
  final LiquidTransaction transaction;

  const LiquidTransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Liquid Transaction Details'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.w),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            _buildHeader(context, ref),
            SizedBox(height: 24.h),
            _buildDetailsCard(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final denomination = settings.btcFormat;

    // Determine the primary balance to display in the header (prioritize L-BTC)
    Balance? primaryBalance;
    try {
      primaryBalance = transaction.lwkDetails.balances.firstWhere(
            (b) => AssetMapper.mapAsset(b.assetId) == AssetId.LBTC && b.value.abs() > 0,
        orElse: () => transaction.lwkDetails.balances.first,
      );
    } catch (e) {
      primaryBalance = null;
    }

    // Calculate fiat value if the primary asset is L-BTC
    double fiatValue = 0.0;
    if (primaryBalance != null && AssetMapper.mapAsset(primaryBalance.assetId) == AssetId.LBTC) {
      final currencyRate = ref.watch(selectedCurrencyProvider(settings.currency));
      fiatValue = primaryBalance.value.abs().toDouble() / 100000000 * currencyRate;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0x00333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              transactionTypeLiquidIcon(transaction.lwkDetails.kind),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            primaryBalance != null
                ? btcInDenominationFormatted(
              primaryBalance.value,
              denomination,
              AssetMapper.mapAsset(primaryBalance.assetId) == AssetId.LBTC,
            )
                : liquidTransactionType(transaction.lwkDetails),
            style: TextStyle(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          if (fiatValue > 0.0)
            Text(
              currencyFormat(fiatValue, settings.currency),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, WidgetRef ref) {
    final denomination = ref.read(settingsProvider).btcFormat;
    final isConfirmed = transaction.isConfirmed;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0x00333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Transaction Details".i18n),
          SizedBox(height: 8.h),
          TransactionDetailRow(
            label: "Date".i18n,
            value: timestampToDateTime(transaction.lwkDetails.timestamp),
          ),
          TransactionDetailRow(
            label: "Status".i18n,
            value: isConfirmed ? "Confirmed".i18n : "Pending".i18n,
            valueColor: isConfirmed ? Colors.green.shade400 : Colors.orange.shade400,
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildSectionHeader("Amounts".i18n),
          SizedBox(height: 8.h),
          ...transaction.lwkDetails.balances.map((balance) {
            return TransactionDetailRow(
              label: AssetMapper.mapAsset(balance.assetId).name,
              value: btcInDenominationFormatted(
                balance.value,
                denomination,
                AssetMapper.mapAsset(balance.assetId) == AssetId.LBTC,
              ),
            );
          }),
          TransactionDetailRow(
            label: "Fee".i18n,
            value: "${btcInDenominationFormatted(transaction.lwkDetails.fee.toInt(), denomination)} $denomination",
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 32.h),
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return _buildActionButton(
        icon: Icons.travel_explore,
        label: "Mempool".i18n,
        onPressed: () {
          setTransactionSearchProvider(transaction.lwkDetails, ref);
          context.push('/search_modal');
        },
        buttonColor: Colors.white.withOpacity(0.15),
        textColor: Colors.white);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color buttonColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const TransactionDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final assetIcons = {
      'L-BTC': 'lib/assets/l-btc.png',
      'Fee': 'lib/assets/l-btc.png',
      'USDT': 'lib/assets/tether.png',
      'EURx': 'lib/assets/eurx.png',
      'Depix': 'lib/assets/depix.png',
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          if (assetIcons[label] != null)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Image.asset(assetIcons[label]!, width: 24.w, height: 24.h),
            ),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}