import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/helpers/asset_mapper.dart';

class Accounts extends ConsumerStatefulWidget {
  const Accounts({super.key});

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends ConsumerState<Accounts> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Modern AppBar
              AppBar(
                title: const Text(
                  'Accounts',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                backgroundColor: Colors.black,
                centerTitle: true,
                elevation: 0,
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bitcoin Section (Always Visible)
                        _buildSectionHeader('Bitcoin Network'),
                        SizedBox(height: 8.h),
                        Wrap(
                          alignment: WrapAlignment.center,
                          runSpacing: 16.h,
                          children: [
                            _buildAccountCard(
                              context,
                              ref,
                              'Bitcoin',
                              btcInDenominationFormatted(
                                ref.watch(balanceNotifierProvider).btcBalance,
                                ref.watch(settingsProvider).btcFormat,
                              ),
                              Image.asset('lib/assets/bitcoin-logo.png', width: 24.w, height: 24.w),
                              ref.watch(bitcoinAddressProvider.future),
                              ref.watch(currentBitcoinPriceInCurrencyProvider(
                                CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).btcBalance),
                              )).toStringAsFixed(2),
                              ref.watch(settingsProvider).currency,
                              ref.watch(settingsProvider).btcFormat,
                              'Bitcoin network',
                              gradientColors: const [Color(0xFFFF9800), Color(0xFFFFA726)],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Lightning Section (Always Visible)
                        _buildSectionHeader('Lightning Network'),
                        SizedBox(height: 8.h),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16.w,
                          runSpacing: 16.h,
                          children: [
                            _buildAccountCard(
                              context,
                              ref,
                              'Lightning',
                              ref.watch(coinosLnProvider).token.isNotEmpty
                                  ? btcInDenominationFormatted(
                                ref.watch(balanceNotifierProvider).lightningBalance!,
                                ref.watch(settingsProvider).btcFormat,
                              )
                                  : '',
                              Image.asset('lib/assets/Bitcoin_lightning_logo.png', width: 24.w, height: 24.w),
                              null,
                              ref.watch(coinosLnProvider).token.isNotEmpty
                                  ? ref.watch(currentBitcoinPriceInCurrencyProvider(
                                CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).lightningBalance!),
                              )).toStringAsFixed(2)
                                  : '',
                              ref.watch(coinosLnProvider).token.isNotEmpty ? ref.watch(settingsProvider).currency : '',
                              ref.watch(settingsProvider).btcFormat,
                              'Lightning network',
                              gradientColors: const [Color(0xFFF7931A), Color(0xFFFFB74D)],
                              isLightning: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Liquid Network Section (Always Visible)
                        _buildSectionHeader('Liquid Network'),
                        SizedBox(height: 8.h),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16.w,
                          runSpacing: 16.h,
                          children: [
                            _buildAccountCard(
                              context,
                              ref,
                              'Bitcoin',
                              btcInDenominationFormatted(
                                ref.watch(balanceNotifierProvider).liquidBalance,
                                ref.watch(settingsProvider).btcFormat,
                              ),
                              Image.asset('lib/assets/l-btc.png', width: 24.w, height: 24.w),
                              ref.watch(liquidAddressProvider.future),
                              ref.watch(currentBitcoinPriceInCurrencyProvider(
                                CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).liquidBalance),
                              )).toStringAsFixed(2),
                              ref.watch(settingsProvider).currency,
                              ref.watch(settingsProvider).btcFormat,
                              'Liquid network',
                              gradientColors: const [Color(0xFF288BEC), Color(0xFF5DADE2)],
                            ),
                            _buildStableCard(
                              context,
                              ref,
                              'Depix',
                              fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance),
                              Image.asset('lib/assets/depix.png', width: 24.w, height: 24.w),
                              ref.watch(liquidAddressProvider.future),
                              AssetId.BRL,
                              gradientColors: const [Color(0xFF009B3A), Color(0xFF4CAF50)],
                            ),
                            _buildStableCard(
                              context,
                              ref,
                              'USDt',
                              fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance),
                              Image.asset('lib/assets/tether.png', width: 24.w, height: 24.w),
                              ref.watch(liquidAddressProvider.future),
                              AssetId.USD,
                              gradientColors: const [Color(0xFF008000), Color(0xFF66BB6A)],
                            ),
                            _buildStableCard(
                              context,
                              ref,
                              'EURx',
                              fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance),
                              Image.asset('lib/assets/eurx.png', width: 24.w, height: 24.w),
                              ref.watch(liquidAddressProvider.future),
                              AssetId.EUR,
                              gradientColors: const [Color(0xFF003399), Color(0xFF1976D2)],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 4.h),
        Container(width: 50.w, height: 2.h, color: Colors.orange),
      ],
    );
  }

  // Enhanced Account Card with Solid Color and Black Text/Icons
  Widget _buildAccountCard(
      BuildContext context,
      WidgetRef ref,
      String title,
      String balanceText,
      Widget icon,
      dynamic addressFuture,
      String fiatBalance,
      String fiatDenomination,
      String format,
      String network,
      {required List<Color> gradientColors, bool isLightning = false}) {
    return Container(
      width: 180.w,
      height: 180.w,
      decoration: BoxDecoration(
        color: gradientColors[0], // Use the primary color instead of gradient
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(fontSize: 19.sp, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  balanceText.isNotEmpty ? '$balanceText $format' : 'Loading...',
                  style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.bold),
                ),
                if (fiatBalance.isNotEmpty)
                  Text(
                    '$fiatBalance $fiatDenomination',
                    style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(selectedNetworkTypeProvider.notifier).state = network;
                    context.push('/home/receive');
                  },
                  icon: Icon(Icons.arrow_downward, color: Colors.black, size: 24.w),
                  splashRadius: 24.w,
                ),
                IconButton(
                  onPressed: () {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    if (network == 'Bitcoin network') context.push('/home/pay', extra: 'bitcoin');
                    else if (network == 'Lightning network') context.push('/home/pay', extra: 'lightning');
                    else if (network == 'Liquid network') {
                      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
                      context.push('/home/pay', extra: 'liquid');
                    }
                  },
                  icon: Icon(Icons.arrow_upward, color: Colors.black, size: 24.w),
                  splashRadius: 24.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Stable Card with Solid Color and Black Text/Icons
  Widget _buildStableCard(
      BuildContext context,
      WidgetRef ref,
      String title,
      String balanceText,
      Widget icon,
      dynamic addressFuture,
      AssetId assetId,
      {required List<Color> gradientColors}) {
    return Container(
      width: 180.w,
      height: 180.w,
      decoration: BoxDecoration(
        color: gradientColors[0], // Use the primary color instead of gradient
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(fontSize: 19.sp, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              balanceText,
              style: TextStyle(fontSize: 18.sp, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(selectedNetworkTypeProvider.notifier).state = 'Liquid network';
                    context.push('/home/receive');
                  },
                  icon: Icon(Icons.arrow_downward, color: Colors.black, size: 24.w),
                  splashRadius: 24.w,
                ),
                IconButton(
                  onPressed: () {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(assetId));
                    context.push('/home/pay', extra: 'liquid_asset');
                  },
                  icon: Icon(Icons.arrow_upward, color: Colors.black, size: 24.w),
                  splashRadius: 24.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}