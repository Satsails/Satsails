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
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// This provider is still needed for the "Receive" button's logic.
final selectedNetworkTypeProvider = StateProvider<String>((ref) => "Bitcoin Network");

class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({super.key});

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  static final List<Map<String, String>> _allAssets = [
    {'name': 'Bitcoin', 'icon': 'lib/assets/bitcoin-logo.png', 'network': 'Bitcoin Network'},
    {'name': 'Lightning Bitcoin', 'icon': 'lib/assets/Bitcoin_lightning_logo.png', 'network': 'Lightning Network'},
    {'name': 'Liquid Bitcoin', 'icon': 'lib/assets/l-btc.png', 'network': 'Liquid Network'},
    {'name': 'USDT', 'icon': 'lib/assets/tether.png', 'network': 'Liquid Network'},
    {'name': 'EURx', 'icon': 'lib/assets/eurx.png', 'network': 'Liquid Network'},
    {'name': 'Depix', 'icon': 'lib/assets/depix.png', 'network': 'Liquid Network'},
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialAsset = ref.read(selectedAssetProvider);
    final initialIndex = _allAssets.indexWhere((asset) => asset['name'] == initialAsset);
    _pageController = PageController(initialPage: initialIndex >= 0 ? initialIndex : 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenheight < 850;

    ref.listen<String>(selectedAssetProvider, (previous, next) {
      final newIndex = _allAssets.indexWhere((asset) => asset['name'] == next);
      if (newIndex != -1 && _pageController.page?.round() != newIndex) {
        _pageController.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAssetSelectorDropdown(context, ref),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _allAssets.length,
                onPageChanged: (index) {
                  ref.read(selectedAssetProvider.notifier).state = _allAssets[index]['name']!;
                },
                itemBuilder: (context, index) {
                  // Pass the controller and index to each child for the animation
                  return _AssetDetailsView(
                    assetData: _allAssets[index],
                    isSmallScreen: isSmallScreen,
                    pageController: _pageController,
                    pageIndex: index,
                  );
                },
              ),
            ),

            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _allAssets.length,
                effect: WormEffect(
                  dotColor: Colors.white.withOpacity(0.2),
                  activeDotColor: Colors.white.withOpacity(0.7),
                  dotHeight: 8.r,
                  dotWidth: 8.r,
                ),
              ),
            ),

            SizedBox(height: 8.h),
            _buildActionButtons(context, ref, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetSelectorDropdown(BuildContext context, WidgetRef ref) {
    final selectedAsset = ref.watch(selectedAssetProvider);
    final networks = ['Bitcoin Network', 'Lightning Network', 'Liquid Network'];

    List<DropdownMenuItem<String>> items = [];
    for (var network in networks) {
      items.add(
        DropdownMenuItem(
          enabled: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 2.h),
            child: Text(
              network,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      );

      final networkAssets = _allAssets.where((asset) => asset['network'] == network);
      items.addAll(
        networkAssets.map((asset) {
          final isSelected = selectedAsset == asset['name'];
          return DropdownMenuItem<String>(
            value: asset['name'],
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Image.asset(asset['icon']!, width: 24.sp, height: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      asset['name']!,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20.sp,
                    )
                ],
              ),
            ),
          );
        }),
      );

      if (network != networks.last) {
        items.add(
          DropdownMenuItem(
            enabled: false,
            child: Divider(
              height: 4.h,
              thickness: 1.h,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        );
      }
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedAsset,
        isExpanded: true,
        dropdownColor: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12.r),
        // --- MODIFIED: Removed menuMaxHeight property to prevent scrolling ---
        itemHeight: null,
        icon: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Asset'.i18n,
                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 20.sp,
              ),
            ],
          ),
        ),
        onChanged: (newValue) {
          if (newValue != null) {
            ref.read(selectedAssetProvider.notifier).state = newValue;
          }
        },
        items: items,
        selectedItemBuilder: (BuildContext context) {
          List<Widget> builderItems = [];
          for (var network in networks) {
            builderItems.add(Container());

            final networkAssets = _allAssets.where((asset) => asset['network'] == network);
            builderItems.addAll(
              networkAssets.map((asset) {
                return Row(
                  children: [
                    Image.asset(asset['icon']!, width: 24.sp, height: 24.sp),
                    SizedBox(width: 12.w),
                    Text(
                      asset['name']!,
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }),
            );
            if (network != networks.last) {
              builderItems.add(Container());
            }
          }
          return builderItems;
        },
      ),
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
        GestureDetector(
          onTap: () {
            context.push('/accounts');
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
                Icon(Icons.wallet, size: 16.w, color: textColor),
                SizedBox(width: 6.w),
                Text(
                  'All Assets'.i18n,
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

class _AssetDetailsView extends ConsumerWidget {
  final Map<String, String> assetData;
  final bool isSmallScreen;
  final PageController pageController;
  final int pageIndex;

  const _AssetDetailsView({
    required this.assetData,
    required this.isSmallScreen,
    required this.pageController,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double opacity = 1.0;
        if (pageController.position.haveDimensions) {
          double page = pageController.page ?? 0.0;
          double pageOffset = page - pageIndex;
          opacity = (1 - pageOffset.abs()).clamp(0.0, 1.0);
        }
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: _buildContentView(ref),
    );
  }

  Widget _buildContentView(WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isBalanceVisible = settings.balanceVisible;
    const textColor = Colors.white;

    final balanceProvider = ref.watch(balanceNotifierProvider);
    final currencyProvider = ref.watch(selectedCurrencyProvider(settings.currency));

    final selectedAsset = assetData['name']!;
    final assetForBalanceDisplay = assetData['network'] == 'Lightning Network' ? 'Liquid Bitcoin' : selectedAsset;

    String nativeBalance;
    String equivalentBalance = '';

    switch (assetForBalanceDisplay) {
      case 'Bitcoin':
        nativeBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.onChainBtcBalance, settings.btcFormat) : '****';
        equivalentBalance = isBalanceVisible ? currencyFormat(balanceProvider.onChainBtcBalance / 100000000 * currencyProvider, settings.currency) : '****';
        break;
      case 'Liquid Bitcoin':
        nativeBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.liquidBtcBalance, settings.btcFormat) : '****';
        equivalentBalance = isBalanceVisible ? currencyFormat(balanceProvider.liquidBtcBalance / 100000000 * currencyProvider, settings.currency) : '****';
        break;
      case 'USDT':
        nativeBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidUsdtBalance) : '****';
        break;
      case 'EURx':
        nativeBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidEuroxBalance) : '****';
        break;
      case 'Depix':
        nativeBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidDepixBalance) : '****';
        break;
      default:
        nativeBalance = '****';
        equivalentBalance = '****';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        _buildBalanceDisplay(nativeBalance, equivalentBalance, isSmallScreen, ref, selectedAsset),
        const Spacer(),
        if (!isSmallScreen)
          Expanded(
            flex: 3,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: isBalanceVisible
                  ? MiniExpensesGraph(
                key: ValueKey(assetForBalanceDisplay),
                selectedAsset: assetForBalanceDisplay,
                textColor: textColor,
              )
                  : const SizedBox.shrink(),
            ),
          )
      ],
    );
  }

  Widget _buildBalanceDisplay(String nativeBalance, String equivalentBalance, bool isSmallScreen, WidgetRef ref, String selectedAsset) {
    const textColor = Colors.white;
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
            isOnline ? (isSyncing ? 'Syncing'.i18n : 'Update Balances'.i18n) : 'Offline'.i18n,
            style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14.sp),
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
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeBalance,
                    style: TextStyle(
                      fontSize: primaryBalanceSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  if (['Bitcoin', 'Liquid Bitcoin', 'Lightning Bitcoin'].contains(selectedAsset))
                    Text(
                      equivalentBalance,
                      style: TextStyle(
                        fontSize: secondaryBalanceSize,
                        color: textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
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
        syncStatus,
      ],
    );
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
            dotData: const FlDotData(
              show: false,
            ),
          ),
        ],
      ),
    );
  }
}