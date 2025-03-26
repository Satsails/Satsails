import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SimplifiedExpensesGraph extends StatelessWidget {
  final Map<DateTime, num> dataToDisplay;

  const SimplifiedExpensesGraph({required this.dataToDisplay, super.key});

  @override
  Widget build(BuildContext context) {
    // Convert data to FlSpot list
    final spots = dataToDisplay.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();

    // Calculate minY and maxY to scale the graph properly
    final minY = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) : 0.0;
    final maxY = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) : 1.0;

    // Define the graph color
    final graphColor = Color(0xFF212121);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: graphColor,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  graphColor.withOpacity(0.3),
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
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
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

class MiniExpensesGraph extends ConsumerWidget {
  final String networkFilter;
  final String assetName;

  const MiniExpensesGraph({
    required this.networkFilter,
    required this.assetName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final AsyncValue<Map<DateTime, num>> asyncData;

    if (assetName == 'Bitcoin') {
      switch (networkFilter) {
        case 'Bitcoin network':
          asyncData = AsyncValue.data(ref.watch(bitcoinBalanceInFormatByDayProvider));
          break;
        case 'Liquid network':
          final assetId = AssetMapper.reverseMapTicker(AssetId.LBTC); // L-BTC asset ID
          asyncData = AsyncValue.data(ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
          break;
        case 'Lightning network':
          asyncData = ref.watch(lightningBalanceOverPeriodByDayProvider);
          break;
        default:
          asyncData = AsyncValue.data({});
      }
    } else {
      // For non-Bitcoin assets (assumed to be on Liquid network)
      final assetId = AssetMapper.reverseMapTicker(AssetId.USD);
      asyncData = AsyncValue.data(ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
    }

    return Container(
      width: 100,
      height: 100,
      child: asyncData.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: SimplifiedExpensesGraph(dataToDisplay: data),
        ),
        loading: () => Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.orangeAccent,
            size: 30,
          ),
        ),
        error: (err, stack) => Center(child: Text('Error')),
      ),
    );
  }
}

class BalanceCard extends ConsumerWidget {
  final String assetName;
  final Color color;
  final String networkFilter;

  const BalanceCard({
    required this.assetName,
    required this.color,
    required this.networkFilter,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final currency = ref.watch(settingsProvider).currency;

    final Map<String, String> _networkImages = {
      'Bitcoin network': 'lib/assets/bitcoin-logo.png',
      'Liquid network': 'lib/assets/l-btc.png',
      'Lightning network': 'lib/assets/Bitcoin_lightning_logo.png',
    };

    final networkShortNames = {
      'Bitcoin network': 'Mainnet',
      'Liquid network': 'Liquid',
      'Lightning network': 'Lightning',
    };

    final depixBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance);
    final usdBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance);
    final euroBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance);
    final btcBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).btcBalance, btcFormat);
    final liquidBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidBalance, btcFormat);
    final lightningBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).lightningBalance ?? 0, btcFormat);

    String nativeBalance;
    String equivalentBalance = '';
    if (assetName == 'Bitcoin') {
      switch (networkFilter) {
        case 'Bitcoin network':
          nativeBalance = btcBalance;
          equivalentBalance = currencyFormat(ref.watch(balanceNotifierProvider).btcBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency);
          break;
        case 'Liquid network':
          nativeBalance = liquidBalance;
          equivalentBalance = currencyFormat(ref.watch(balanceNotifierProvider).liquidBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency);
          break;
        case 'Lightning network':
          nativeBalance = lightningBalance;
          equivalentBalance = currencyFormat((ref.watch(balanceNotifierProvider).lightningBalance ?? 0) / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency);
          break;
        default:
          nativeBalance = '';
          equivalentBalance = '';
      }
    } else {
      switch (assetName) {
        case 'Depix':
          nativeBalance = depixBalance;
          break;
        case 'USDT':
          nativeBalance = usdBalance;
          break;
        case 'EURx':
          nativeBalance = euroBalance;
          break;
        default:
          nativeBalance = '0';
          equivalentBalance = '0 USD';
      }
    }

    final buyButton = GestureDetector(
      onTap: () {
        ref.read(navigationProvider.notifier).state = 4;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.circular(24.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
          size: 24.w,
        ),
      ),
    );

    final bottomButtons = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              // TODO: Implement send functionality
            },
            icon: Icon(Icons.arrow_upward, color: Colors.white, size: 28.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          ),
          buyButton,
          IconButton(
            onPressed: () {
              // TODO: Implement receive functionality
            },
            icon: Icon(Icons.arrow_downward, color: Colors.white, size: 28.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        context.pushNamed('analytics');
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.none,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                _networkImages[networkFilter] ?? 'lib/assets/default.png',
                                width: 24.w,
                                height: 24.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                assetName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                ' (${networkShortNames[networkFilter] ?? networkFilter})',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            nativeBalance,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (assetName == 'Bitcoin') ...[
                            SizedBox(height: 4.h),
                            Text(
                              equivalentBalance,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MiniExpensesGraph(
                          networkFilter: networkFilter,
                          assetName: assetName,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -20.h,
              child: bottomButtons,
            ),
          ],
        ),
      ),
    );
  }
}