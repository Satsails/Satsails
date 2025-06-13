import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// Enum to manage the selected section
enum SwapSection { internal, external }

class Exchange extends ConsumerStatefulWidget {
  const Exchange({super.key});

  @override
  _ExchangeState createState() => _ExchangeState();
}

class _ExchangeState extends ConsumerState<Exchange> {
  final TextEditingController controller = TextEditingController();
  SwapSection _selectedSection = SwapSection.internal;

  // --- State for the new universal swap card ---
  ShiftPair _selectedPair = ShiftPair.usdcEthToLiquidUsdt;

  // --- Data for SideShift swaps ---
  final List<ShiftPair> _selectablePairs = [
    ShiftPair.usdcEthToLiquidUsdt,
    ShiftPair.usdcSolToLiquidUsdt,
    ShiftPair.usdcPolygonToLiquidUsdt,
    ShiftPair.usdtEthToLiquidUsdt,
    ShiftPair.usdtTronToLiquidUsdt,
    ShiftPair.usdtSolToLiquidUsdt,
    ShiftPair.usdtPolygonToLiquidUsdt,
    ShiftPair.ethToLiquidBtc,
    ShiftPair.bnbToLiquidBtc,
    ShiftPair.solToLiquidBtc,
  ];

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

  // Helper to create display text for the dropdown
  String _getPairDisplayText(ShiftPair pair) {
    final isLbtc = pair.name.contains('ToLiquidBtc');
    final toAsset = isLbtc ? 'L-BTC' : 'Liquid USDT';

    switch (pair) {
      case ShiftPair.usdcEthToLiquidUsdt:
        return 'Ethereum USDC <> $toAsset';
      case ShiftPair.usdcSolToLiquidUsdt:
        return 'Solana USDC <> $toAsset';
      case ShiftPair.usdcPolygonToLiquidUsdt:
        return 'Polygon USDC <> $toAsset';
      case ShiftPair.usdtEthToLiquidUsdt:
        return 'Ethereum USDT <> $toAsset';
      case ShiftPair.usdtTronToLiquidUsdt:
        return 'Tron USDT <> $toAsset';
      case ShiftPair.usdtSolToLiquidUsdt:
        return 'Solana USDT <> $toAsset';
      case ShiftPair.usdtPolygonToLiquidUsdt:
        return 'Polygon USDT <> $toAsset';
      case ShiftPair.ethToLiquidBtc:
        return 'Ethereum ETH -> $toAsset';
      case ShiftPair.bnbToLiquidBtc:
        return 'BSC BNB -> $toAsset';
      case ShiftPair.solToLiquidBtc:
        return 'Solana SOL -> $toAsset';
      default:
        return 'Select a pair';
    }
  }

  // Helper to get the dynamic description for the card
  String _getPairDescription(ShiftPair pair) {
    final isLbtc = pair.name.contains('ToLiquidBtc');
    final toAsset = isLbtc ? 'L-BTC' : 'Liquid USDT';
    final fromAssetName = _getPairDisplayText(pair).split(' ')[0] + ' ' + _getPairDisplayText(pair).split(' ')[1];

    if (receiveToSendMap.containsKey(pair)) {
      return 'Swap between ${fromAssetName} and ${toAsset} in your wallet.'.i18n;
    } else {
      return 'Deposit ${fromAssetName} to receive ${toAsset} in your wallet.'.i18n;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final swapType = ref.read(swapTypeProvider);
      if (swapType != null) {
        ref.read(swapTypeNotifierProvider.notifier).updateProviders(swapType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Text(
            'Exchange'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
              KeyboardDismissOnTap(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 16.h),
                      _buildSwapPicker(),
                      SizedBox(height: 16.h),
                      Expanded(
                        child: ListView(
                          children: [
                            if (_selectedSection == SwapSection.internal)
                              ..._buildInternalSwapWidgets()
                            else
                              ..._buildExternalSwapWidgets(),
                            SizedBox(height: 100.sp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwapPicker() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildPickerOption(SwapSection.internal, 'Swaps'),
          _buildPickerOption(SwapSection.external, 'Bridge To Other Networks'),
        ],
      ),
    );
  }

  Widget _buildPickerOption(SwapSection section, String text) {
    final bool isSelected = _selectedSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSection = section;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black.withOpacity(0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              text.i18n,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInternalSwapWidgets() {
    return [
      buildBalanceCardWithMaxButton(ref, controller),
      SizedBox(height: 0.01.sh),
      buildExchangeCard(context, ref, controller),
      SizedBox(height: 0.01.sh),
      buildAdvancedOptionsCard(ref),
      feeSelection(ref),
      slideToSend(ref, context),
    ];
  }

  List<Widget> _buildExternalSwapWidgets() {
    return [
      Padding(
        padding: EdgeInsets.only(bottom: 16.h, top: 4.h),
        child: Text(
          'Swap non-native assets from other networks with your Satsails assets.'.i18n,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
          ),
        ),
      ),
      _buildUniversalSwapCard(),
    ];
  }

  Widget _buildVerticalActionChip({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversalSwapCard() {
    final logos = _logoMap[_selectedPair];
    final isLbtcDestination = _selectedPair.name.contains('ToLiquidBtc');
    final destinationLogo = isLbtcDestination ? 'lib/assets/l-btc.png' : 'lib/assets/tether.png';

    final pairName = _selectedPair.name;
    String assetTicker = "Asset";
    if (pairName.contains('usdc')) assetTicker = 'USDC';
    if (pairName.contains('usdt')) assetTicker = 'USDT';
    if (pairName.contains('eth')) assetTicker = 'ETH';
    if (pairName.contains('bnb')) assetTicker = 'BNB';
    if (pairName.contains('sol')) assetTicker = 'SOL';

    final isWithdrawSupported = receiveToSendMap.containsKey(_selectedPair);

    // Condition to hide network badge for native network coins (ETH, SOL, BNB)
    final bool showNetworkBadge = !(_selectedPair == ShiftPair.ethToLiquidBtc ||
        _selectedPair == ShiftPair.bnbToLiquidBtc ||
        _selectedPair == ShiftPair.solToLiquidBtc);

    return Container(
      height: 300.sp, // Increased height slightly for description
      decoration: BoxDecoration(
        color: const Color(0x00333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<ShiftPair>(
                value: _selectedPair,
                dropdownColor: const Color(0xFF212121),
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                items: _selectablePairs.map((pair) {
                  return DropdownMenuItem<ShiftPair>(
                    value: pair,
                    child: Text(
                      _getPairDisplayText(pair),
                      style: TextStyle(color: Colors.white, fontSize: 18.sp),
                    ),
                  );
                }).toList(),
                onChanged: (ShiftPair? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPair = newValue;
                    });
                  }
                },
                icon: Padding(
                  padding: EdgeInsets.only(left: 8.0.w),
                  child: const Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
                isDense: true,
                isExpanded: true,
                style: TextStyle(color: Colors.white, fontSize: 18.sp),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (logos != null && logos.containsKey('coin'))
                      SvgPicture.asset(logos['coin']!, width: 40.sp, height: 40.sp),
                    if (logos != null && logos.containsKey('network') && showNetworkBadge)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: EdgeInsets.all(2.sp),
                          decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                          child: SvgPicture.asset(logos['network']!, width: 16.sp, height: 16.sp),
                        ),
                      )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Icon(Icons.swap_horiz, color: Colors.white70, size: 30.sp),
                ),
                Image.asset(destinationLogo, width: 40.sp, height: 40.sp),
              ],
            ),
            // --- New Dynamic Description ---
            Text(
              _getPairDescription(_selectedPair),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            Row(
              mainAxisAlignment: isWithdrawSupported ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                _buildVerticalActionChip(
                  icon: Icons.input,
                  label: 'Deposit ${assetTicker}'.i18n,
                  onPressed: () {
                    ref.read(selectedNetworkTypeProvider.notifier).state = 'SideShift';
                    ref.read(selectedShiftPairProvider.notifier).state = _selectedPair;
                    context.push('/home/receive');
                  },
                ),
                if (isWithdrawSupported) ...[
                  SizedBox(width: 12.w),
                  _buildVerticalActionChip(
                    icon: Icons.output,
                    label: 'Withdraw to ${assetTicker}'.i18n,
                    onPressed: () {
                      final sendPair = receiveToSendMap[_selectedPair];
                      if (sendPair != null) {
                        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
                        ref.read(selectedSendShiftPairProvider.notifier).state = sendPair;
                        context.push('/home/pay', extra: 'non_native_asset');
                      }
                    },
                  )
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}