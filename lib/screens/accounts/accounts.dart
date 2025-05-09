import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:Satsails/translations/translations.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Satsails/providers/sideshift_provider.dart';

class Accounts extends ConsumerStatefulWidget {
  const Accounts({super.key});

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends ConsumerState<Accounts> {
  final Map<ShiftPair, Map<String, String>> _logoMap = {
    ShiftPair.usdcEthToLiquidUsdt: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/eth.svg'},
    ShiftPair.usdcSolToLiquidUsdt: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/sol.svg'},
    ShiftPair.usdcPolygonToLiquidUsdt: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/pol.svg'},
    ShiftPair.usdtEthToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/eth.svg'},
    ShiftPair.usdtTronToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/trx.svg'},
    ShiftPair.usdtSolToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/sol.svg'},
    ShiftPair.usdtPolygonToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/pol.svg'},
    ShiftPair.ethToLiquidBtc: {'coin': 'lib/assets/eth.svg', 'network': 'lib/assets/eth.svg'},
    ShiftPair.bnbToLiquidBtc: {'coin': 'lib/assets/bnb.svg', 'network': 'lib/assets/bsc.svg'},
    ShiftPair.solToLiquidBtc: {'coin': 'lib/assets/sol.svg', 'network': 'lib/assets/sol.svg'},
  };

  final Map<ShiftPair, ShiftPair> receiveToSendMap = {
    ShiftPair.usdcEthToLiquidUsdt: ShiftPair.liquidUsdtToUsdcEth,
    ShiftPair.usdcSolToLiquidUsdt: ShiftPair.liquidUsdtToUsdcSol,
    ShiftPair.usdcPolygonToLiquidUsdt: ShiftPair.liquidUsdtToUsdcPolygon,
    ShiftPair.usdtEthToLiquidUsdt: ShiftPair.liquidUsdtToUsdtEth,
    ShiftPair.usdtTronToLiquidUsdt: ShiftPair.liquidUsdtToUsdtTron,
    ShiftPair.usdtSolToLiquidUsdt: ShiftPair.liquidUsdtToUsdtSol,
    ShiftPair.usdtPolygonToLiquidUsdt: ShiftPair.liquidUsdtToUsdtPolygon,
  };

  @override
  Widget build(BuildContext context) {
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                ),
              ),
              Column(
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
                            Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 16.h,
                              children: [
                                _buildAccountCard(
                                  context,
                                  ref,
                                  'Bitcoin',
                                  isBalanceVisible
                                      ? btcInDenominationFormatted(
                                    ref.watch(balanceNotifierProvider).btcBalance,
                                    ref.watch(settingsProvider).btcFormat,
                                  )
                                      : '***',
                                  Image.asset('lib/assets/bitcoin-logo.png', width: 32.sp, height: 32.sp),
                                  ref.watch(bitcoinAddressProvider.future),
                                  isBalanceVisible
                                      ? currencyFormat(
                                    ref.watch(currentBitcoinPriceInCurrencyProvider(
                                      CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).btcBalance),
                                    )).toDouble(),
                                    ref.watch(settingsProvider).currency,
                                  )
                                      : '***',
                                  ref.watch(settingsProvider).currency,
                                  'Bitcoin Network',
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            _buildSectionHeader('Spark Network', 'lib/assets/logo-spark.svg', Colors.white),
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
                                  ref.watch(coinosLnProvider).token.isNotEmpty && isBalanceVisible
                                      ? btcInDenominationFormatted(
                                    ref.watch(balanceNotifierProvider).lightningBalance!,
                                    ref.watch(settingsProvider).btcFormat,
                                  )
                                      : '***',
                                  Image.asset('lib/assets/Bitcoin_lightning_logo.png', width: 32.sp, height: 32.sp),
                                  null,
                                  ref.watch(coinosLnProvider).token.isNotEmpty && isBalanceVisible
                                      ? currencyFormat(
                                    ref.watch(currentBitcoinPriceInCurrencyProvider(
                                      CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).lightningBalance!),
                                    )).toDouble(),
                                    ref.watch(settingsProvider).currency,
                                  )
                                      : '***',
                                  ref.watch(settingsProvider).currency,
                                  'Lightning Network',
                                  isLightning: true,
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            _buildSectionHeader('Liquid Network', 'lib/assets/liquid-logo-white.png', null),
                            SizedBox(height: 12.h),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16.w,
                              runSpacing: 16.h,
                              children: [
                                _buildAccountCard(
                                  context,
                                  ref,
                                  'L-BTC',
                                  isBalanceVisible
                                      ? btcInDenominationFormatted(
                                    ref.watch(balanceNotifierProvider).liquidBalance,
                                    ref.watch(settingsProvider).btcFormat,
                                  )
                                      : '***',
                                  Image.asset('lib/assets/l-btc.png', width: 32.sp, height: 32.sp),
                                  ref.watch(liquidAddressProvider.future),
                                  isBalanceVisible
                                      ? currencyFormat(
                                    ref.watch(currentBitcoinPriceInCurrencyProvider(
                                      CurrencyParams(ref.watch(settingsProvider).currency, ref.watch(balanceNotifierProvider).liquidBalance),
                                    )).toDouble(),
                                    ref.watch(settingsProvider).currency,
                                  )
                                      : '***',
                                  ref.watch(settingsProvider).currency,
                                  'Liquid Network',
                                ),
                                _buildStableCard(
                                  context,
                                  ref,
                                  'Depix',
                                  isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance) : '***',
                                  Image.asset('lib/assets/depix.png', width: 32.sp, height: 32.sp),
                                  ref.watch(liquidAddressProvider.future),
                                  AssetId.BRL,
                                ),
                                _buildStableCard(
                                  context,
                                  ref,
                                  'USDT',
                                  isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance) : '***',
                                  Image.asset('lib/assets/tether.png', width: 32.sp, height: 32.sp),
                                  ref.watch(liquidAddressProvider.future),
                                  AssetId.USD,
                                ),
                                _buildStableCard(
                                  context,
                                  ref,
                                  'EURx',
                                  isBalanceVisible ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance) : '***',
                                  Image.asset('lib/assets/eurx.png', width: 32.sp, height: 32.sp),
                                  ref.watch(liquidAddressProvider.future),
                                  AssetId.EUR,
                                ),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            _buildNonNativeAssetsHeader(),
                            SizedBox(height: 12.h),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16.w,
                              runSpacing: 16.h,
                              children: [
                                _buildAssetCard(context, ref, ShiftPair.usdcEthToLiquidUsdt, 'ETH USDC'),
                                _buildAssetCard(context, ref, ShiftPair.usdcSolToLiquidUsdt, 'SOL USDC'),
                                _buildAssetCard(context, ref, ShiftPair.usdcPolygonToLiquidUsdt, 'POL USDC'),
                                _buildAssetCard(context, ref, ShiftPair.usdtEthToLiquidUsdt, 'ETH USDT'),
                                _buildAssetCard(context, ref, ShiftPair.usdtTronToLiquidUsdt, 'TRX USDT'),
                                _buildAssetCard(context, ref, ShiftPair.usdtSolToLiquidUsdt, 'SOL USDT'),
                                _buildAssetCard(context, ref, ShiftPair.usdtPolygonToLiquidUsdt, 'POL USDT'),
                                _buildAssetCard(context, ref, ShiftPair.ethToLiquidBtc, 'ETH'),
                                _buildAssetCard(context, ref, ShiftPair.bnbToLiquidBtc, 'BNB'),
                                _buildAssetCard(context, ref, ShiftPair.solToLiquidBtc, 'SOL'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String NetworkName, String logoPath, Color? color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNetworkLogo(logoPath, color),
        SizedBox(height: 6.h),
      ],
    );
  }

  Widget _buildNonNativeAssetsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'lib/assets/sideshift.png',
          width: 140.sp,
        ),
        SizedBox(height: 6.sp),
        Text(
          'Non-Native Assets',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.sp),
      ],
    );
  }

  Widget _buildNetworkLogo(String logoPath, Color? color) {
    if (logoPath.endsWith('.svg')) {
      return SvgPicture.asset(
        logoPath,
        width: 25.sp,
        height: 25.sp,
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
      dynamic addressFuture,
      String fiatBalance,
      String fiatDenomination,
      String Network, {
        bool isLightning = false,
      }) {
    return GestureDetector(
      onTapDown: (_) => setState(() {}),
      child: Container(
        width: 190.sp,
        height: 200.sp,
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
                    balanceText.isNotEmpty ? balanceText : 'Loading...',
                    style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fiatBalance.isNotEmpty)
                    Text(
                      fiatBalance,
                      style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(selectedNetworkTypeProvider.notifier).state = Network == 'Lightning Network' ? 'Spark Network' : Network;
                      context.push('/home/receive');
                    },
                    icon: Icon(Icons.arrow_downward, color: Colors.white, size: 28.sp),
                    splashRadius: 28.w,
                    tooltip: 'Receive',
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(sendTxProvider.notifier).resetToDefault();
                      if (Network == 'Bitcoin Network') context.push('/home/pay', extra: 'bitcoin');
                      else if (Network == 'Lightning Network') context.push('/home/pay', extra: 'lightning');
                      else if (Network == 'Liquid Network') {
                        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
                        context.push('/home/pay', extra: 'liquid');
                      }
                    },
                    icon: Icon(Icons.arrow_upward, color: Colors.white, size: 28.sp),
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
        width: 190.sp,
        height: 200.sp,
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
                      ref.read(selectedNetworkTypeProvider.notifier).state = 'Liquid Network';
                      context.push('/home/receive');
                    },
                    icon: Icon(Icons.arrow_downward, color: Colors.white, size: 28.sp),
                    splashRadius: 28.w,
                    tooltip: 'Receive',
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(sendTxProvider.notifier).resetToDefault();
                      ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(assetId));
                      context.push('/home/pay', extra: 'liquid_asset');
                    },
                    icon: Icon(Icons.arrow_upward, color: Colors.white, size: 28.sp),
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

  Widget _buildAssetCard(
      BuildContext context,
      WidgetRef ref,
      ShiftPair pair,
      String assetName,
      ) {
    final logos = _logoMap[pair];
    final List<ShiftPair> singleLogoPairs = [
      ShiftPair.ethToLiquidBtc,
      ShiftPair.bnbToLiquidBtc,
      ShiftPair.solToLiquidBtc,
    ];
    final List<ShiftPair> usdtShiftPairs = [
      ShiftPair.usdcEthToLiquidUsdt,
      ShiftPair.usdcSolToLiquidUsdt,
      ShiftPair.usdcPolygonToLiquidUsdt,
      ShiftPair.usdtEthToLiquidUsdt,
      ShiftPair.usdtPolygonToLiquidUsdt,
      ShiftPair.usdtTronToLiquidUsdt,
      ShiftPair.usdtSolToLiquidUsdt,
    ];

    final Map<ShiftPair, String> displayNames = {
      ShiftPair.ethToLiquidBtc: 'Ethereum',
      ShiftPair.bnbToLiquidBtc: 'Binance Coin',
      ShiftPair.solToLiquidBtc: 'Solana',
      ShiftPair.usdcEthToLiquidUsdt: 'USDC (Ethereum)',
      ShiftPair.usdcSolToLiquidUsdt: 'USDC (Solana)',
      ShiftPair.usdcPolygonToLiquidUsdt: 'USDC (Polygon)',
      ShiftPair.usdtEthToLiquidUsdt: 'USDT (Ethereum)',
      ShiftPair.usdtPolygonToLiquidUsdt: 'USDT (Polygon)',
      ShiftPair.usdtTronToLiquidUsdt: 'USDT (Tron)',
      ShiftPair.usdtSolToLiquidUsdt: 'USDT (Solana)',
    };

    final double fontSize = usdtShiftPairs.contains(pair) ? 16.sp : 18.sp;

    return Container(
      width: 190.sp,
      height: 200.sp,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (logos != null && logos.containsKey('coin'))
                  SvgPicture.asset(logos['coin']!, width: 32.sp, height: 32.sp),
                if (!singleLogoPairs.contains(pair) && logos != null && logos.containsKey('network'))
                  Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: SvgPicture.asset(logos['network']!, width: 32.sp, height: 32.sp),
                  ),
              ],
            ),
            Text(
              displayNames[pair] ?? assetName,
              style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(selectedNetworkTypeProvider.notifier).state = 'SideShift';
                    ref.read(selectedShiftPairProvider.notifier).state = pair;
                    context.push('/home/receive');
                  },
                  icon: Icon(Icons.arrow_downward, color: Colors.white, size: 28.sp),
                  splashRadius: 28.w,
                  tooltip: 'Receive',
                ),
                if (usdtShiftPairs.contains(pair))
                  IconButton(
                    onPressed: () {
                      final sendPair = receiveToSendMap[pair];
                      if (sendPair != null) {
                        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
                        ref.read(selectedSendShiftPairProvider.notifier).state = sendPair;
                        context.push('/home/pay', extra: 'non_native_asset');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Send not supported for this asset'.i18n),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.arrow_upward, color: Colors.white, size: 28.sp),
                    splashRadius: 28.w,
                    tooltip: 'Send',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}