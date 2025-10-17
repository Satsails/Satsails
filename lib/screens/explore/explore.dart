import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Providers
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Main Explore Widget
class Explore extends ConsumerWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text('Explore'.i18n, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              onPressed: () => ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible),
              icon: Icon(isBalanceVisible ? Icons.remove_red_eye : Icons.visibility_off, color: Colors.white),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(color: Colors.black)),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: const _BalanceDisplay(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: const _ActionCards(),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Center(
                  child: LoadingAnimationWidget.fourRotatingDots(color: Colors.orangeAccent, size: 40.sp),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceDisplay extends ConsumerStatefulWidget {
  const _BalanceDisplay();
  @override
  ConsumerState<_BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends ConsumerState<_BalanceDisplay> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBalanceVisible = settings.balanceVisible;
    final denomination = settings.btcFormat;

    final balanceProvider = ref.watch(balanceNotifierProvider);
    final depixBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidDepixBalance) : '***';
    final liquidUsdtBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidUsdtBalance) : '***';
    final euroBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidEuroxBalance) : '***';
    final onChainBtcBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.onChainBtcBalance, denomination) : '***';
    final liquidBtcBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.liquidBtcBalance, denomination) : '***';

    return Card(
      color: const Color(0xFF333333).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Column(
          children: [
            Row(children: [_buildBalanceRow(imagePath: 'lib/assets/bitcoin-logo.png', label: 'Bitcoin'.i18n, balance: onChainBtcBalance), _buildBalanceRow(imagePath: 'lib/assets/l-btc.png', label: 'Liquid Bitcoin', balance: liquidBtcBalance)]),
            SizedBox(height: 16.h),
            Row(children: [_buildBalanceRow(imagePath: 'lib/assets/eurx.png', label: 'Liquid EURx', balance: euroBalance), _buildBalanceRow(imagePath: 'lib/assets/tether.png', label: 'Liquid USDT', balance: liquidUsdtBalance)]),
            SizedBox(height: 16.h),
            Row(children: [_buildBalanceRow(imagePath: 'lib/assets/depix.png', label: 'Liquid Depix', balance: depixBalance), Expanded(child: Container())]),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow({required String imagePath, required String label, required String balance}) {
    return Expanded(
      child: Row(
        children: [
          Image.asset(imagePath, width: 24.sp, height: 24.sp, fit: BoxFit.contain),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(balance, style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _ActionCards extends ConsumerWidget {
  const _ActionCards();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color(0xFF333333).withOpacity(0.4),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => showMessageSnackBar(message: "Coming soon".i18n, context: context, error: true),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                // MODIFIED: Wrapped the content in a Row to place an icon on the right.
                child: Row(
                  children: [
                    // This Expanded widget makes the Column take all available space,
                    // pushing the icon to the far right.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'lib/assets/bitrefill.png',
                            height: 40.h,
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
                            child: Text(
                              'Shop With Bitcoin'.i18n,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Text(
                              'Gift cards, phone refills, and more!'.i18n,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // MODIFIED: Added a clean, white icon on the right.
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.green.withOpacity(0.8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => context.push('/home/explore/deposit_type'),
                  child: Container(
                    height: 100.h,
                    alignment: Alignment.center,
                    child: Text('Buy'.i18n, style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.red.withOpacity(0.8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => context.push('/home/explore/sell_type'),
                  child: Container(
                    height: 100.h,
                    alignment: Alignment.center,
                    child: Text('Sell'.i18n, style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}