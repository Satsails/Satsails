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
  String? _expandedCardId;

  void _handleCardTap(String cardId) {
    setState(() {
      if (_expandedCardId == cardId) {
        _expandedCardId = null;
      } else {
        _expandedCardId = cardId;
      }
    });
  }

  Widget _buildVerticalActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
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

  Widget _buildLightningCard(
      {required BuildContext context, required WidgetRef ref, required bool isExpanded, required VoidCallback onTap}) {
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isExpanded ? 220.sp : 120.sp,
        decoration: BoxDecoration(
          color: const Color(0xFF333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
              ),
              IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white70),
                onPressed: onTap,
              ),
            ]),
            const Spacer(),
            Text(
              'Send and receive on the Lightning Network using your Liquid Bitcoin'.i18n,
              style: TextStyle(fontSize: 14.sp, color: Colors.white70, fontWeight: FontWeight.w600),
              maxLines: isExpanded ? 2 : 1, // Adjust max lines based on state
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: isExpanded
                  ? Row(
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
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required BuildContext context, required WidgetRef ref, required String title,
    required String balanceText, required Widget icon, required String fiatBalance,
    required bool isExpanded, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isExpanded ? 220.sp : 120.sp,
        decoration: BoxDecoration(
          color: const Color(0xFF333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              icon,
              SizedBox(width: 10.w),
              Expanded(
                  child: Text(title, style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)
              ),
              // =========================================================================
              // NEW: Added expand/collapse button for clear user affordance.
              // =========================================================================
              IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white70),
                onPressed: onTap,
              ),
            ]),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(balanceText.isNotEmpty ? balanceText : 'Loading...', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              if (fiatBalance.isNotEmpty) Text(fiatBalance, style: TextStyle(fontSize: 14.sp, color: Colors.white70)),
            ]),
            const Spacer(),
            AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: isExpanded
                  ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _buildVerticalActionChip(
                    icon: Icons.arrow_downward, label: 'Receive'.i18n,
                    onPressed: () {
                      final networkType = title == 'L-BTC' ? 'Liquid Network' : 'Bitcoin Network';
                      ref.read(selectedNetworkTypeProvider.notifier).state = networkType;
                      context.push('/home/receive');
                    }),
                SizedBox(width: 12.w),
                _buildVerticalActionChip(
                    icon: Icons.arrow_upward, label: 'Send'.i18n,
                    onPressed: () {
                      ref.read(sendTxProvider.notifier).resetToDefault();
                      if (title == 'Bitcoin') {
                        context.push('/home/pay', extra: 'bitcoin');
                      } else if (title == 'L-BTC') {
                        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
                        context.push('/home/pay', extra: 'liquid');
                      }
                    }),
              ])
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStableCard({
    required BuildContext context, required WidgetRef ref, required String title,
    required String balanceText, required Widget icon, required AssetId assetId,
    required bool isExpanded, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isExpanded ? 220.sp : 120.sp,
        decoration: BoxDecoration(
          color: const Color(0xFF333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              icon,
              SizedBox(width: 10.w),
              Expanded(
                  child: Text(title, style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)
              ),
              IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.white70),
                onPressed: onTap,
              ),
            ]),
            const Spacer(),
            Text(balanceText.isNotEmpty ? balanceText : 'Loading...', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            const Spacer(),
            AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: isExpanded
                  ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _buildVerticalActionChip(
                    icon: Icons.arrow_downward, label: 'Receive'.i18n,
                    onPressed: () {
                      ref.read(selectedNetworkTypeProvider.notifier).state = 'Liquid Network';
                      context.push('/home/receive');
                    }),
                SizedBox(width: 12.w),
                _buildVerticalActionChip(
                    icon: Icons.arrow_upward, label: 'Send'.i18n,
                    onPressed: () {
                      ref.read(sendTxProvider.notifier).resetToDefault();
                      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(assetId));
                      context.push('/home/pay', extra: 'liquid_asset');
                    }),
              ])
                  : const SizedBox.shrink(),
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
                title: Text('Accounts'.i18n, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.sp)),
                backgroundColor: Colors.black, automaticallyImplyLeading: false, centerTitle: false,
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: IconButton(
                      onPressed: () => ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible),
                      icon: Icon(isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white, size: 24.sp),
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
                            context: context, ref: ref, title: 'Bitcoin',
                            isExpanded: _expandedCardId == 'Bitcoin', onTap: () => _handleCardTap('Bitcoin'),
                            balanceText: isBalanceVisible ? btcInDenominationFormatted(ref.watch(balanceNotifierProvider).onChainBtcBalance, ref.watch(settingsProvider).btcFormat) : '••••••',
                            icon: Image.asset('lib/assets/bitcoin-logo.png', width: 32.sp, height: 32.sp),
                            fiatBalance: isBalanceVisible ? currencyFormat(ref.watch(currentBitcoinPriceInCurrencyProvider(CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).onChainBtcBalance))).toDouble(), ref.watch(settingsProvider).currency) : '••••••'
                        ),
                        SizedBox(height: 24.h),
                        _buildSectionHeader('Boltz Network', 'lib/assets/boltz.svg', Colors.white),
                        SizedBox(height: 12.h),
                        _buildLightningCard(context: context, ref: ref, isExpanded: _expandedCardId == 'Lightning', onTap: () => _handleCardTap('Lightning')),
                        SizedBox(height: 24.h),
                        _buildSectionHeader('Liquid Network', 'lib/assets/liquid-logo-white.png', null),
                        SizedBox(height: 12.h),
                        _buildAccountCard(
                            context: context, ref: ref, title: 'L-BTC',
                            isExpanded: _expandedCardId == 'L-BTC', onTap: () => _handleCardTap('L-BTC'),
                            balanceText: isBalanceVisible ? btcInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidBtcBalance, ref.watch(settingsProvider).btcFormat) : '••••••',
                            icon: Image.asset('lib/assets/l-btc.png', width: 32.sp, height: 32.sp),
                            fiatBalance: isBalanceVisible ? currencyFormat(ref.watch(currentBitcoinPriceInCurrencyProvider(CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).liquidBtcBalance))).toDouble(), ref.watch(settingsProvider).currency) : '••••••'
                        ),
                        SizedBox(height: 16.h),
                        _buildStableCard(
                            context: context, ref: ref, title: 'Depix',
                            isExpanded: _expandedCardId == 'Depix', onTap: () => _handleCardTap('Depix'),
                            balanceText: isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidDepixBalance) : '••••••',
                            icon: Image.asset('lib/assets/depix.png', width: 32.sp, height: 32.sp),
                            assetId: AssetId.BRL
                        ),
                        SizedBox(height: 16.h),
                        _buildStableCard(
                            context: context, ref: ref, title: 'USDT',
                            isExpanded: _expandedCardId == 'USDT', onTap: () => _handleCardTap('USDT'),
                            balanceText: isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidUsdtBalance) : '••••••',
                            icon: Image.asset('lib/assets/tether.png', width: 32.sp, height: 32.sp),
                            assetId: AssetId.USD
                        ),
                        SizedBox(height: 16.h),
                        _buildStableCard(
                            context: context, ref: ref, title: 'EURx',
                            isExpanded: _expandedCardId == 'EURx', onTap: () => _handleCardTap('EURx'),
                            balanceText: isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidEuroxBalance) : '••••••',
                            icon: Image.asset('lib/assets/eurx.png', width: 32.sp, height: 32.sp),
                            assetId: AssetId.EUR
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
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
      child: logoPath.endsWith('.svg')
          ? SvgPicture.asset(logoPath, height: 20.h, colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null)
          : Image.asset(logoPath, height: 20.h),
    );
  }
}