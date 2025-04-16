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
                title: Text(
                  'Accounts',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.sp,
                  ),
                ),
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false,
                centerTitle: true,
                elevation: 0,
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bitcoin Section
                        _buildSectionHeader('Bitcoin Network'),
                        SizedBox(height: 12.h),
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
                              Image.asset('lib/assets/bitcoin-logo.png', width: 32.w, height: 32.w),
                              ref.watch(bitcoinAddressProvider.future),
                              ref.watch(currentBitcoinPriceInCurrencyProvider(
                                CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).btcBalance),
                              )).toStringAsFixed(2),
                              ref.watch(settingsProvider).currency,
                              ref.watch(settingsProvider).btcFormat,
                              'Bitcoin network',
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        // Lightning Section
                        _buildSectionHeader('Lightning Network'),
                        SizedBox(height: 12.h),
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
                              Image.asset('lib/assets/Bitcoin_lightning_logo.png', width: 32.w, height: 32.w),
                              null,
                              ref.watch(coinosLnProvider).token.isNotEmpty
                                  ? ref.watch(currentBitcoinPriceInCurrencyProvider(
                                CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).lightningBalance!),
                              )).toStringAsFixed(2)
                                  : '',
                              ref.watch(coinosLnProvider).token.isNotEmpty ? ref.watch(settingsProvider).currency : '',
                              ref.watch(settingsProvider).btcFormat,
                              'Lightning network',
                              isLightning: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        // Liquid Network Section
                        _buildSectionHeader('Liquid Network'),
                        SizedBox(height: 12.h),
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
                              Image.asset('lib/assets/l-btc.png', width: 32.w, height: 32.w),
                              ref.watch(liquidAddressProvider.future),
                              ref.watch(currentBitcoinPriceInCurrencyProvider(
                                CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).liquidBalance),
                              )).toStringAsFixed(2),
                              ref.watch(settingsProvider).currency,
                              ref.watch(settingsProvider).btcFormat,
                              'Liquid network',
                            ),
                            _buildStableCard(
                              context,
                              ref,
                              'Depix',
                              fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance),
                              Image.asset('lib/assets/depix.png', width: 32.w, height: 32.w),
                              ref.watch(liquidAddressProvider.future),
                              AssetId.BRL,
                            ),
                            _buildStableCard(
                              context,
                              ref,
                              'USDt',
                              fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance),
                              Image.asset('lib/assets/tether.png', width: 32.w, height: 32.w),
                              ref.watch(liquidAddressProvider.future),
                              AssetId.USD,
                            ),
                            _buildStableCard(
                              context,
                              ref,
                              'EURx',
                              fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance),
                              Image.asset('lib/assets/eurx.png', width: 32.w, height: 32.w),
                              ref.watch(liquidAddressProvider.future),
                              AssetId.EUR,
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
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        SizedBox(height: 6.h),
        Container(width: 60.w, height: 3.h, color: Colors.orange),
      ],
    );
  }

  // Enhanced Account Card
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
      String network, {
        bool isLightning = false,
      }) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      child: Container(
        width: 190.w,
        height: 200.h,
        decoration: BoxDecoration(
          color: const Color(0x333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icon,
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    balanceText.isNotEmpty ? '$balanceText $format' : 'Loading...',
                    style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fiatBalance.isNotEmpty)
                    Text(
                      '$fiatBalance $fiatDenomination',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white70),
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
                    icon: Icon(Icons.arrow_downward, color: Colors.white, size: 28.w), // White buttons
                    splashRadius: 28.w,
                    tooltip: 'Receive',
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
                    icon: Icon(Icons.arrow_upward, color: Colors.white, size: 28.w), // White buttons
                    splashRadius: 28.w,
                    tooltip: 'Send',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced Stable Card
  Widget _buildStableCard(
      BuildContext context,
      WidgetRef ref,
      String title,
      String balanceText,
      Widget icon,
      dynamic addressFuture,
      AssetId assetId,
      ) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      child: Container(
        width: 190.w,
        height: 200.h,
        decoration: BoxDecoration(
          color: const Color(0x333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icon,
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                balanceText.isNotEmpty ? balanceText : 'Loading...',
                style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(selectedNetworkTypeProvider.notifier).state = 'Liquid network';
                      context.push('/home/receive');
                    },
                    icon: Icon(Icons.arrow_downward, color: Colors.white, size: 28.w), // White buttons
                    splashRadius: 28.w,
                    tooltip: 'Receive',
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(sendTxProvider.notifier).resetToDefault();
                      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(assetId));
                      context.push('/home/pay', extra: 'liquid_asset');
                    },
                    icon: Icon(Icons.arrow_upward, color: Colors.white, size: 28.w), // White buttons
                    splashRadius: 28.w,
                    tooltip: 'Send',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}