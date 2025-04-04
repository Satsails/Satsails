import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
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

// Existing provider for network type
final selectedNetworkTypeProvider = StateProvider<String>((ref) => "Bitcoin network");

// New provider for selected asset
final selectedAssetProvider = StateProvider<String>((ref) => 'Bitcoin (Mainnet)');

class SimplifiedExpensesGraph extends StatelessWidget {
  final Map<DateTime, num> dataToDisplay;

  const SimplifiedExpensesGraph({required this.dataToDisplay, super.key});

  @override
  Widget build(BuildContext context) {
    final spots = dataToDisplay.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();

    final minY = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) : 0.0;
    final maxY = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) : 1.0;

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
          final assetId = AssetMapper.reverseMapTicker(AssetId.LBTC);
          asyncData = AsyncValue.data(ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
          break;
        case 'Lightning network':
          asyncData = AsyncValue.data({});
          break;
        default:
          asyncData = AsyncValue.data({});
      }
    } else {
      final assetId = AssetMapper.reverseMapTickerFromString(assetName);
      asyncData = AsyncValue.data(ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
    }

    return Container(
      width: 170.w,
      height: 50.h,
      child: asyncData.when(
        data: (data) => Padding(
          padding: EdgeInsets.all(4.0.sp),
          child: SimplifiedExpensesGraph(dataToDisplay: data),
        ),
        loading: () => Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            color: Colors.black,
            size: 20,
          ),
        ),
        error: (err, stack) => Center(child: Text('Error')),
      ),
    );
  }
}

Widget _buildPricePercentageChangeTicker(BuildContext context, WidgetRef ref) {
  final currency = ref.watch(settingsProvider).currency;
  final coinGeckoData = ref.watch(coinGeckoBitcoinChange(currency.toLowerCase()));
  final currentPrice = ref.watch(selectedCurrencyProvider(currency)) * 1;

  return coinGeckoData.when(
    data: (data) {
      IconData? icon;
      Color textColor = Colors.black;
      String displayText = '${data.abs().toStringAsFixed(2)}%';

      if (displayText == '-0.00%' || displayText == '0.00%') {
        displayText = '0%';
        icon = null;
      } else if (data > 0) {
        icon = Icons.arrow_upward;
      } else if (data < 0) {
        icon = Icons.arrow_downward;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentPrice.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(width: 8.w),
            if (icon != null) Icon(icon, size: 16.sp, color: textColor, weight: 700),
            SizedBox(width: icon != null ? 4.0 : 0),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
    loading: () => LoadingAnimationWidget.progressiveDots(
      size: 16.sp,
      color: Colors.black,
    ),
    error: (error, stack) => Text(
      'Error',
      style: TextStyle(fontSize: 16.sp, color: Colors.black),
    ),
  );
}

final isBalanceVisibleProvider = StateProvider<bool>((ref) => true);

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
    final isBalanceVisible = ref.watch(isBalanceVisibleProvider);

    final Map<String, String> _networkImages = {
      'Bitcoin network': 'lib/assets/bitcoin-logo.png',
      'Liquid network': 'lib/assets/l-btc.png',
      'Lightning network': 'lib/assets/Bitcoin_lightning_logo.png',
    };

    final Map<String, String> _assetImages = {
      'Depix': 'lib/assets/depix.png',
      'USDT': 'lib/assets/tether.png',
      'EURx': 'lib/assets/eurx.png',
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
          nativeBalance = isBalanceVisible ? btcBalance : '****';
          equivalentBalance = isBalanceVisible
              ? currencyFormat(ref.watch(balanceNotifierProvider).btcBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency)
              : '****';
          break;
        case 'Liquid network':
          nativeBalance = isBalanceVisible ? liquidBalance : '****';
          equivalentBalance = isBalanceVisible
              ? currencyFormat(ref.watch(balanceNotifierProvider).liquidBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency)
              : '****';
          break;
        case 'Lightning network':
          nativeBalance = isBalanceVisible ? lightningBalance : '****';
          equivalentBalance = isBalanceVisible
              ? currencyFormat((ref.watch(balanceNotifierProvider).lightningBalance ?? 0) / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency)
              : '****';
          break;
        default:
          nativeBalance = '****';
          equivalentBalance = '****';
      }
    } else {
      switch (assetName) {
        case 'Depix':
          nativeBalance = isBalanceVisible ? depixBalance : '****';
          break;
        case 'USDT':
          nativeBalance = isBalanceVisible ? usdBalance : '****';
          break;
        case 'EURx':
          nativeBalance = isBalanceVisible ? euroBalance : '****';
          break;
        default:
          nativeBalance = '****';
          equivalentBalance = '****';
      }
    }

    final bottomButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            ref.read(sendTxProvider.notifier).resetToDefault();
            ref.read(sendBlocksProvider.notifier).state = 1;

            if (assetName == 'Bitcoin') {
              if (networkFilter == 'Bitcoin network') {
                context.push('/home/pay', extra: 'bitcoin');
              } else if (networkFilter == 'Liquid network') {
                ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
                context.push('/home/pay', extra: 'liquid');
              } else if (networkFilter == 'Lightning network') {
                context.push('/home/pay', extra: 'lightning');
              }
            } else {
              late String assetToUpdate;
              switch (assetName) {
                case 'Depix':
                  assetToUpdate = AssetMapper.reverseMapTicker(AssetId.BRL);
                  break;
                case 'USDT':
                  assetToUpdate = AssetMapper.reverseMapTicker(AssetId.USD);
                  break;
                case 'EURx':
                  assetToUpdate = AssetMapper.reverseMapTicker(AssetId.EUR);
                  break;
              }
              ref.read(sendTxProvider.notifier).updateAssetId(assetToUpdate);
              context.push('/home/pay', extra: 'liquid_asset');
            }
          },
          icon: Icon(Icons.arrow_upward, color: Color(0xFF212121), size: 28.w, weight: 700),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
        IconButton(
          onPressed: () {
            ref.read(selectedNetworkTypeProvider.notifier).state = networkFilter;
            context.push('/home/receive');
          },
          icon: Icon(Icons.arrow_downward, color: Color(0xFF212121), size: 28.w, weight: 700),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        String fullAsset;
        if (assetName == 'Bitcoin') {
          fullAsset = 'Bitcoin (${networkShortNames[networkFilter] ?? networkFilter})';
        } else {
          fullAsset = '$assetName (Liquid)';
        }

        ref.read(selectedAssetProvider.notifier).state = fullAsset;
        context.pushNamed('analytics');
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
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
                padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (assetName == 'Bitcoin')
                          Image.asset(
                            _networkImages[networkFilter] ?? 'lib/assets/default.png',
                            width: 24.w,
                            height: 24.w,
                          )
                        else
                          Image.asset(
                            _assetImages[assetName] ?? 'lib/assets/default.png',
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
                            fontSize: 16.sp,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            ref.read(isBalanceVisibleProvider.notifier).state =
                            !ref.read(isBalanceVisibleProvider);
                          },
                          icon: Icon(
                            isBalanceVisible ? Icons.remove_red_eye : Icons.visibility_off,
                            color: Colors.black,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                    fontSize: 16.sp,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MiniExpensesGraph(
                              networkFilter: networkFilter,
                              assetName: assetName,
                            ),
                            if (assetName == 'Bitcoin') ...[
                              SizedBox(height: 8.h),
                              _buildPricePercentageChangeTicker(context, ref),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: Icon(
                Icons.touch_app,
                color: Color(0xFF212121),
                size: 28.sp,
              ),
            ),
            Positioned(
              bottom: 2.h,
              left: 16.w,
              child: bottomButtons,
            ),
          ],
        ),
      ),
    );
  }
}