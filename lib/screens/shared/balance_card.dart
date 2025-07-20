import 'dart:ui';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

// This provider is still needed for the "Receive" button's logic.
final selectedNetworkTypeProvider = StateProvider<String>((ref) => "Bitcoin Network");

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  // A new combined list of all assets from all networks.
  static final List<Map<String, String>> _allAssets = [
    {'name': 'Bitcoin', 'icon': 'lib/assets/bitcoin-logo.png', 'network': 'Bitcoin Network', 'logo': 'lib/assets/bitcoin-logo.svg'},
    {'name': 'Lightning Bitcoin', 'icon': 'lib/assets/Bitcoin_lightning_logo.png', 'network': 'Lightning Network', 'logo': 'lib/assets/logo-spark.svg'},
    {'name': 'Liquid Bitcoin', 'icon': 'lib/assets/l-btc.png', 'network': 'Liquid Network', 'logo': 'lib/assets/liquid-logo.png'},
    {'name': 'Depix', 'icon': 'lib/assets/depix.png', 'network': 'Liquid Network', 'logo': 'lib/assets/liquid-logo.png'},
    {'name': 'USDT', 'icon': 'lib/assets/tether.png', 'network': 'Liquid Network', 'logo': 'lib/assets/liquid-logo.png'},
    {'name': 'EURx', 'icon': 'lib/assets/eurx.png', 'network': 'Liquid Network', 'logo': 'lib/assets/liquid-logo.png'},
  ];

  // Define the network names for the tabs
  static const _networkNames = ['Bitcoin Network', 'Liquid Network', 'Lightning Network'];


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenheight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenheight < 850;

    final selectedAsset = ref.watch(selectedAssetProvider);
    final selectedNetwork = ref.watch(selectedNetworkProvider);
    final settings = ref.watch(settingsProvider);
    final isBalanceVisible = settings.balanceVisible;
    const textColor = Colors.white;

    final balanceProvider = ref.watch(balanceNotifierProvider);
    final currencyProvider = ref.watch(selectedCurrencyProvider(settings.currency));

    // For Lightning, we always want to show the Liquid Bitcoin balance.
    final assetForBalanceDisplay = selectedNetwork == 'Lightning Network' ? 'Liquid Bitcoin' : selectedAsset;

    String nativeBalance;
    String equivalentBalance = '';

    switch (assetForBalanceDisplay) {
      case 'Bitcoin':
        nativeBalance = isBalanceVisible
            ? btcInDenominationFormatted(
            balanceProvider.onChainBtcBalance, settings.btcFormat)
            : '****';
        equivalentBalance = isBalanceVisible
            ? currencyFormat(balanceProvider.onChainBtcBalance /
            100000000 *
            currencyProvider, settings.currency)
            : '****';
        break;
      case 'Liquid Bitcoin':
        nativeBalance = isBalanceVisible
            ? btcInDenominationFormatted(
            balanceProvider.liquidBtcBalance, settings.btcFormat)
            : '****';
        equivalentBalance = isBalanceVisible
            ? currencyFormat(balanceProvider.liquidBtcBalance /
            100000000 *
            currencyProvider, settings.currency)
            : '****';
        break;
      case 'USDT':
        nativeBalance = isBalanceVisible
            ? fiatInDenominationFormatted(balanceProvider.liquidUsdtBalance)
            : '****';
        break;
      case 'EURx':
        nativeBalance = isBalanceVisible
            ? fiatInDenominationFormatted(balanceProvider.liquidEuroxBalance)
            : '****';
        break;
      case 'Depix':
        nativeBalance = isBalanceVisible
            ? fiatInDenominationFormatted(balanceProvider.liquidDepixBalance)
            : '****';
        break;
      default:
        nativeBalance = '****';
        equivalentBalance = '****';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121), // Hardcoded dark color
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNetworkSelector(context, ref),
            SizedBox(height: 12.h),
            _buildAssetSelector(context, ref),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  _buildBalanceDisplay(nativeBalance, equivalentBalance, isSmallScreen, ref),
                  const Spacer(),
                  if (!isSmallScreen)
                    Expanded(
                      flex: 3,
                      child: Opacity(
                        opacity: isBalanceVisible ? 1.0 : 0.0,
                        child: MiniExpensesGraph(
                          selectedAsset: assetForBalanceDisplay,
                          textColor: textColor,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                ],
              ),
            ),

            SizedBox(height: 8.h),
            _buildActionButtons(context, ref, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkSelector(BuildContext context, WidgetRef ref) {
    final selectedNetwork = ref.watch(selectedNetworkProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _networkNames.map((networkName) {
          final isSelected = networkName == selectedNetwork;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(selectedNetworkProvider.notifier).state = networkName;
                final firstAsset = _allAssets.firstWhere((asset) => asset['network'] == networkName);
                ref.read(selectedAssetProvider.notifier).state = firstAsset['name']!;
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black.withOpacity(0.3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    networkName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssetSelector(BuildContext context, WidgetRef ref) {
    final selectedAsset = ref.watch(selectedAssetProvider);
    final selectedNetwork = ref.watch(selectedNetworkProvider);

    // Helper widget to build a single asset chip
    Widget buildChip(Map<String, String> asset, bool isSelected, {VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(right: 8.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
          ),
          child: Row(
            children: [
              Image.asset(asset['icon']!, width: 20.sp, height: 20.sp),
              SizedBox(width: 8.w),
              Text(
                asset['name']!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (selectedNetwork == 'Liquid Network') {
      final liquidAssets = _allAssets.where((asset) => asset['network'] == 'Liquid Network').toList();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: liquidAssets.map((asset) {
            final isSelected = asset['name'] == selectedAsset;
            return buildChip(asset, isSelected, onTap: () {
              ref.read(selectedAssetProvider.notifier).state = asset['name']!;
            });
          }).toList(),
        ),
      );
    } else {
      // For Bitcoin and Lightning, show a single, static chip
      final currentAsset = _allAssets.firstWhere((asset) => asset['network'] == selectedNetwork);
      return Row(
        // Changed from .center to .start to align left
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildChip(currentAsset, true), // It's always selected
        ],
      );
    }
  }

  Widget _buildBalanceDisplay(String nativeBalance, String equivalentBalance, bool isSmallScreen, WidgetRef ref) {
    const textColor = Colors.white;
    final selectedAsset = ref.watch(selectedAssetProvider);
    final selectedNetwork = ref.watch(selectedNetworkProvider);
    final primaryBalanceSize = isSmallScreen ? 28.sp : 36.sp;
    final secondaryBalanceSize = isSmallScreen ? 15.sp : 18.sp;

    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;
    final isSyncing = ref.watch(backgroundSyncInProgressProvider);
    final isOnline = ref.watch(settingsProvider).online;

    final Widget syncStatus = GestureDetector(
      onTap: isSyncing ? null : () => ref.read(backgroundSyncNotifierProvider.notifier).performFullUpdate(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.sp,
            height: 10.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? (isSyncing ? Colors.orange : Colors.green) : Colors.red,
            ),
          ),
          SizedBox(width: 8.sp),
          Text(
              isSyncing ? 'Syncing'.i18n : 'Update Balances'.i18n,
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14.sp)
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance numbers on the left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nativeBalance,
                  style: TextStyle(
                    fontSize: primaryBalanceSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2.h),
                if (['Bitcoin', 'Liquid Bitcoin', 'Lightning Bitcoin'].contains(selectedAsset) || selectedNetwork == 'Lightning Network')
                  Text(
                    equivalentBalance,
                    style: TextStyle(
                      fontSize: secondaryBalanceSize,
                      color: textColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            // Visibility icon on the right
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible),
              icon: Icon(
                isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: textColor,
                size: 24.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        syncStatus, // Sync status below the balance
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    const textColor = Colors.white;
    final buttonColor = Colors.white.withOpacity(0.15);
    final buttonFontSize = isSmallScreen ? 12.sp : 13.sp;
    final selectedAsset = ref.watch(selectedAssetProvider);

    final network = _allAssets.firstWhere((asset) => asset['name'] == selectedAsset)['network']!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildActionButton(
              icon: Icons.arrow_downward,
              label: 'Receive'.i18n,
              onPressed: () {
                if (network == 'Lightning Network') {
                  ref.read(selectedNetworkTypeProvider.notifier).state = 'Boltz Network';
                } else {
                  ref.read(selectedNetworkTypeProvider.notifier).state = network;
                }
                context.push('/home/receive');
              },
              textColor: textColor,
              buttonColor: buttonColor,
              fontSize: buttonFontSize,
            ),
            SizedBox(width: 8.w),
            _buildActionButton(
              icon: Icons.arrow_upward,
              label: 'Send'.i18n,
              onPressed: () {
                ref.read(sendTxProvider.notifier).resetToDefault();
                _handleSendNavigation(context, ref, selectedAsset);
              },
              textColor: textColor,
              buttonColor: buttonColor,
              fontSize: buttonFontSize,
            ),
          ],
        ),
        // The "if (isBalanceVisible)" condition has been removed from here.
        GestureDetector(
          onTap: () {
            context.pushNamed('analytics');
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: textColor.withOpacity(0.5), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 16.w, color: textColor),
                SizedBox(width: 6.w),
                Text(
                  'All wallets'.i18n,
                  style: TextStyle(
                    color: textColor,
                    fontSize: buttonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color textColor,
    required Color buttonColor,
    required double fontSize,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 16.w, weight: 700),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendNavigation(BuildContext context, WidgetRef ref, String selectedAsset) {
    switch (selectedAsset) {
      case 'Bitcoin':
        context.push('/home/pay', extra: 'bitcoin');
        break;
      case 'Lightning Bitcoin':
        context.push('/home/pay', extra: 'lightning');
        break;
      case 'Liquid Bitcoin':
        ref
            .read(sendTxProvider.notifier)
            .updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        context.push('/home/pay', extra: 'liquid');
        break;
      default:
        String assetId;
        switch (selectedAsset) {
          case 'USDT':
            assetId = AssetMapper.reverseMapTicker(AssetId.USD);
            break;
          case 'EURx':
            assetId = AssetMapper.reverseMapTicker(AssetId.EUR);
            break;
          case 'Depix':
            assetId = AssetMapper.reverseMapTicker(AssetId.BRL);
            break;
          default:
            assetId = '';
        }
        ref.read(sendTxProvider.notifier).updateAssetId(assetId);
        context.push('/home/pay', extra: 'liquid_asset');
    }
  }
}

class MiniExpensesGraph extends ConsumerWidget {
  final String selectedAsset;
  final Color textColor;

  const MiniExpensesGraph({
    required this.selectedAsset,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final AsyncValue<Map<DateTime, num>> asyncData;

    switch (selectedAsset) {
      case 'Bitcoin':
      case 'Lightning Bitcoin':
        asyncData =
            AsyncValue.data(ref.watch(bitcoinBalanceInFormatByDayProvider));
        break;
      case 'Liquid Bitcoin':
        final assetId = AssetMapper.reverseMapTicker(AssetId.LBTC);
        asyncData = AsyncValue.data(
            ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
        break;
      case 'USDT':
        final assetId = AssetMapper.reverseMapTicker(AssetId.USD);
        asyncData = AsyncValue.data(
            ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
        break;
      case 'EURx':
        final assetId = AssetMapper.reverseMapTicker(AssetId.EUR);
        asyncData = AsyncValue.data(
            ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
        break;
      case 'Depix':
        final assetId = AssetMapper.reverseMapTicker(AssetId.BRL);
        asyncData = AsyncValue.data(
            ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
        break;
      default:
        asyncData = const AsyncValue.data({});
    }

    return asyncData.when(
      data: (data) => Padding(
        padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
        child: SimplifiedExpensesGraph(
          dataToDisplay: data,
          graphColor: textColor,
        ),
      ),
      loading: () => Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: textColor,
          size: 20,
        ),
      ),
      error: (err, stack) => const Center(child: Text('Error')),
    );
  }
}

class SimplifiedExpensesGraph extends StatelessWidget {
  final Map<DateTime, num> dataToDisplay;
  final Color graphColor;

  const SimplifiedExpensesGraph({
    required this.dataToDisplay,
    required this.graphColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = dataToDisplay.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();

    double minY, maxY;

    if (spots.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();
      spots = [
        FlSpot(now - const Duration(days: 7).inMilliseconds.toDouble(), 0),
        FlSpot(now, 0),
      ];
      minY = 0;
      maxY = 1;
    } else {
      minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      double padding = (maxY - minY) * 0.2;
      if (padding == 0) padding = 1;
      minY -= padding;
      maxY += padding;
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: graphColor.withOpacity(0.9),
            barWidth: 2.5,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  graphColor.withOpacity(0.2),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == barData.spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 3.5,
                    color: graphColor,
                    strokeWidth: 1.5,
                  );
                }
                return FlDotCirclePainter(radius: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}
