import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Satsails/providers/sideshift_provider.dart';

class Accounts extends ConsumerStatefulWidget {
  const Accounts({super.key});

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends ConsumerState<Accounts> {
  Widget _buildVerticalActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLightningCard(BuildContext context, WidgetRef ref) {
    final Widget lightningIcon = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('lib/assets/Bitcoin_lightning_logo.png', width: 32.sp, height: 32.sp),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Icon(Icons.swap_horiz, color: Colors.white70, size: 20.sp),
        ),
        Image.asset('lib/assets/l-btc.png', width: 32.sp, height: 32.sp),
      ],
    );

    return Container(
      height: 220.sp,
      decoration: BoxDecoration(
        color: const Color(0x00333333).withOpacity(0.4),
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
            Row(children: [
              lightningIcon,
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Lightning Network'.i18n,
                  style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send and receive on the Lightning Network using your Liquid Bitcoin'.i18n,
                  style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVerticalActionChip(
                  icon: Icons.arrow_downward,
                  label: 'Receive'.i18n,
                  onPressed: () {
                    ref.read(selectedNetworkTypeProvider.notifier).state = 'Boltz Network';
                    context.push('/home/receive');
                  },
                ),
                SizedBox(width: 12.w),
                _buildVerticalActionChip(
                  icon: Icons.arrow_upward,
                  label: 'Send'.i18n,
                  onPressed: () {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    context.push('/home/pay', extra: 'lightning');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppBar(
                title: Text(
                  'Accounts'.i18n,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.sp,
                  ),
                ),
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false,
                centerTitle: false,
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: IconButton(
                      onPressed: () {
                        ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible);
                      },
                      icon: Icon(
                        isBalanceVisible ? Icons.remove_red_eye : Icons.visibility_off,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ],
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Bitcoin Network', 'lib/assets/bitcoin-logo-white.svg', null),
                        SizedBox(height: 12.h),
                        _buildAccountCard(
                          context,
                          ref,
                          'Bitcoin',
                          isBalanceVisible
                              ? btcInDenominationFormatted(
                            ref.watch(balanceNotifierProvider).onChainBtcBalance,
                            ref.watch(settingsProvider).btcFormat,
                          )
                              : '***',
                          Image.asset('lib/assets/bitcoin-logo.png', width: 32.sp, height: 32.sp),
                          isBalanceVisible
                              ? currencyFormat(
                            ref
                                .watch(currentBitcoinPriceInCurrencyProvider(
                              CurrencyParams(
                                  ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).onChainBtcBalance),
                            ))
                                .toDouble(),
                            ref.watch(settingsProvider).currency,
                          )
                              : '***',
                        ),
                        SizedBox(height: 24.h),
                        _buildSectionHeader('Boltz Network', 'lib/assets/boltz.svg', Colors.white),
                        SizedBox(height: 12.h),
                        _buildLightningCard(context, ref),
                        SizedBox(height: 24.h),
                        _buildSectionHeader('Liquid Network', 'lib/assets/liquid-logo-white.png', null),
                        SizedBox(height: 12.h),
                        Column(
                          children: [
                            _buildAccountCard(
                              context,
                              ref,
                              'L-BTC',
                              isBalanceVisible
                                  ? btcInDenominationFormatted(
                                ref.watch(balanceNotifierProvider).liquidBtcBalance,
                                ref.watch(settingsProvider).btcFormat,
                              )
                                  : '***',
                              Image.asset('lib/assets/l-btc.png', width: 32.sp, height: 32.sp),
                              isBalanceVisible
                                  ? currencyFormat(
                                ref
                                    .watch(currentBitcoinPriceInCurrencyProvider(
                                  CurrencyParams(
                                      ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).liquidBtcBalance),
                                ))
                                    .toDouble(),
                                ref.watch(settingsProvider).currency,
                              )
                                  : '***',
                            ),
                            SizedBox(height: 16.h),
                            _buildStableCard(
                              context,
                              ref,
                              'Depix',
                              isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidDepixBalance) : '***',
                              Image.asset('lib/assets/depix.png', width: 32.sp, height: 32.sp),
                              AssetId.BRL,
                            ),
                            SizedBox(height: 16.h),
                            _buildStableCard(
                              context,
                              ref,
                              'USDT',
                              isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidUsdtBalance) : '***',
                              Image.asset('lib/assets/tether.png', width: 32.sp, height: 32.sp),
                              AssetId.USD,
                            ),
                            SizedBox(height: 16.h),
                            _buildStableCard(
                              context,
                              ref,
                              'EURx',
                              isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidEuroxBalance) : '***',
                              Image.asset('lib/assets/eurx.png', width: 32.sp, height: 32.sp),
                              AssetId.EUR,
                            ),
                          ],
                        ),
                        SizedBox(height: 100.sp),
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

  Widget _buildSectionHeader(String title, String logoPath, Color? color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNetworkLogo(logoPath, color),
        SizedBox(height: 6.h),
      ],
    );
  }

  Widget _buildNetworkLogo(String logoPath, Color? color) {
    if (logoPath.endsWith('.svg')) {
      return SvgPicture.asset(
        logoPath,
        width: 100.sp,
        color: color,
      );
    } else {
      return Image.asset(
        logoPath,
        width: 100.sp,
      );
    }
  }

  Widget _buildAccountCard(
      BuildContext context,
      WidgetRef ref,
      String title,
      String balanceText,
      Widget icon,
      String fiatBalance,
      ) {
    return Container(
      height: 220.sp,
      decoration: BoxDecoration(
        color: const Color(0x00333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              icon,
              SizedBox(width: 10.w),
              Expanded(
                  child: Text(title,
                      style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis))
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(balanceText.isNotEmpty ? balanceText : 'Loading...',
                  style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
              if (fiatBalance.isNotEmpty) Text(fiatBalance, style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildVerticalActionChip(
                  icon: Icons.arrow_downward,
                  label: 'Receive'.i18n,
                  onPressed: () {
                    final networkType = title == 'L-BTC' ? 'Liquid Network' : 'Bitcoin Network';
                    ref.read(selectedNetworkTypeProvider.notifier).state = networkType;
                    context.push('/home/receive');
                  }),
              SizedBox(width: 12.w),
              _buildVerticalActionChip(
                  icon: Icons.arrow_upward,
                  label: 'Send'.i18n,
                  onPressed: () {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    if (title == 'Bitcoin') {
                      context.push('/home/pay', extra: 'bitcoin');
                    } else if (title == 'L-BTC') {
                      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
                      context.push('/home/pay', extra: 'liquid');
                    }
                  }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildStableCard(
      BuildContext context,
      WidgetRef ref,
      String title,
      String balanceText,
      Widget icon,
      AssetId assetId,
      ) {
    return Container(
      height: 220.sp,
      decoration: BoxDecoration(
        color: const Color(0x00333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              icon,
              SizedBox(width: 10.w),
              Expanded(
                  child: Text(title,
                      style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis))
            ]),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(balanceText.isNotEmpty ? balanceText : 'Loading...',
                    style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildVerticalActionChip(
                  icon: Icons.arrow_downward,
                  label: 'Receive'.i18n,
                  onPressed: () {
                    ref.read(selectedNetworkTypeProvider.notifier).state = 'Liquid Network';
                    context.push('/home/receive');
                  }),
              SizedBox(width: 12.w),
              _buildVerticalActionChip(
                  icon: Icons.arrow_upward,
                  label: 'Send'.i18n,
                  onPressed: () {
                    ref.read(sendTxProvider.notifier).resetToDefault();
                    ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(assetId));
                    context.push('/home/pay', extra: 'liquid_asset');
                  }),
            ]),
          ],
        ),
      ),
    );
  }
}