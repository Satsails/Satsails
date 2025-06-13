import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/swap_helpers.dart';
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

  // --- State for the Bridge card ---
  ShiftPair? _selectedPair = ShiftPair.usdcEthToLiquidUsdt;
  bool _isDepositing = false; // Start with withdraw direction by default

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

  // --- HELPER METHODS ---

  // Gets asset and network info. Now uses a robust switch for accuracy.
  Map<String, String> _getAssetInfo(ShiftPair pair) {
    switch (pair) {
      case ShiftPair.usdcEthToLiquidUsdt:
        return {'name': 'USDC', 'network': 'Ethereum'};
      case ShiftPair.usdcSolToLiquidUsdt:
        return {'name': 'USDC', 'network': 'Solana'};
      case ShiftPair.usdcPolygonToLiquidUsdt:
        return {'name': 'USDC', 'network': 'Polygon'};
      case ShiftPair.usdtEthToLiquidUsdt:
        return {'name': 'USDT', 'network': 'Ethereum'};
      case ShiftPair.usdtTronToLiquidUsdt:
        return {'name': 'USDT', 'network': 'Tron'};
      case ShiftPair.usdtSolToLiquidUsdt:
        return {'name': 'USDT', 'network': 'Solana'};
      case ShiftPair.usdtPolygonToLiquidUsdt:
        return {'name': 'USDT', 'network': 'Polygon'};
      case ShiftPair.ethToLiquidBtc:
        return {'name': 'ETH', 'network': 'Ethereum'};
      case ShiftPair.bnbToLiquidBtc:
        return {'name': 'BNB', 'network': 'BNB Chain'};
      case ShiftPair.solToLiquidBtc:
        return {'name': 'SOL', 'network': 'Solana'};
      default:
        return {'name': 'Unknown', 'network': 'Unknown'};
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

  // Creates the final display text for the dropdown.
  String _getPairDisplayText(ShiftPair pair) {
    final info = _getAssetInfo(pair);
    final network = info['network']!;
    final name = info['name']!;

    // For native assets like ETH on Ethereum, just show the network name.
    if (network == 'Ethereum' && name == 'ETH') return 'Ethereum';
    if (network == 'Solana' && name == 'SOL') return 'Solana';
    if (network == 'BNB Chain' && name == 'BNB') return 'BNB Chain';

    // For all other tokens, combine network and name.
    return '$network $name';
  }

  // --- BUILD METHODS ---

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
      _buildBridgeExchangeCard(),
      if (_selectedPair != null) ...[
        SizedBox(height: 16.h),
        _buildSingleActionButton(),
      ],
    ];
  }

  Widget _buildBridgeExchangeCard() {
    final fromContent = _isDepositing ? _buildExternalAssetDropdown() : _buildSatsailsAssetStaticDisplay();
    final toContent = _isDepositing ? _buildSatsailsAssetStaticDisplay() : _buildExternalAssetDropdown();
    final isWithdrawalSupported = _selectedPair != null && receiveToSendMap.containsKey(_selectedPair!);

    return Card(
      color: const Color(0x00333333).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Column(
          children: [
            _buildAssetRow("From Asset", fromContent, isNative: !_isDepositing),
            SizedBox(height: 24.h),
            _buildSwapDivider(isEnabled: isWithdrawalSupported),
            SizedBox(height: 24.h),
            _buildAssetRow("To Asset", toContent, isNative: _isDepositing),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetRow(String label, Widget content, {required bool isNative}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.i18n,
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            content,
          ],
        ),
        Text(
          isNative ? 'Native Asset'.i18n : 'External Asset'.i18n,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSwapDivider({required bool isEnabled}) {
    return Row(
      children: [
        SizedBox(width: 24.w),
        const Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
        SizedBox(width: 24.w),
        GestureDetector(
          onTap: isEnabled ? () {
            setState(() {
              _isDepositing = !_isDepositing;
            });
          } : null,
          child: Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: isEnabled ? Colors.grey.shade800 : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.swap_vert,
              color: isEnabled ? Colors.white : Colors.white24,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExternalAssetDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<ShiftPair>(
        value: _selectedPair,
        dropdownColor: const Color(0xFF212121),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        items: _selectablePairs.map((pair) {
          return DropdownMenuItem<ShiftPair>(
            value: pair,
            child: Row(
              children: [
                _buildAssetIcon(pair),
                SizedBox(width: 8.w),
                Text(
                  _getPairDisplayText(pair),
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (ShiftPair? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedPair = newValue;
              if (!_isDepositing && !receiveToSendMap.containsKey(newValue)) {
                _isDepositing = true;
              }
            });
          }
        },
        icon: Padding(
          padding: EdgeInsets.only(left: 8.0.w),
          child: const Icon(Icons.arrow_drop_down, color: Colors.white),
        ),
        isDense: true,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
    );
  }

  Widget _buildSatsailsAssetStaticDisplay() {
    final bool isLbtcPair = _selectedPair?.name.contains('ToLiquidBtc') ?? false;
    final liquidLogo = isLbtcPair ? 'lib/assets/l-btc.png' : 'lib/assets/tether.png';
    final liquidName = isLbtcPair ? 'L-BTC' : 'Liquid USDT';

    return Row(
      children: [
        Image.asset(liquidLogo, width: 28.sp, height: 28.sp),
        SizedBox(width: 8.w),
        Text(
          liquidName,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ],
    );
  }

  Widget _buildSingleActionButton() {
    if (_selectedPair == null) return const SizedBox.shrink();

    final bool isDeposit = _isDepositing;
    final String label = isDeposit ? 'Deposit to Satsails'.i18n : 'Withdrawal from Satsails'.i18n;
    final IconData icon = isDeposit ? Icons.arrow_downward : Icons.arrow_upward;
    final Color iconColor = isDeposit ? const Color(0xFF00C853) : Colors.red;
    final VoidCallback onPressed;

    if (isDeposit) {
      onPressed = () {
        ref.read(selectedNetworkTypeProvider.notifier).state = 'SideShift';
        ref.read(selectedShiftPairProvider.notifier).state = _selectedPair!;
        context.push('/home/receive');
      };
    } else {
      onPressed = () {
        final sendPair = receiveToSendMap[_selectedPair!];
        if (sendPair != null) {
          ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.USD));
          ref.read(selectedSendShiftPairProvider.notifier).state = sendPair;
          context.push('/home/pay', extra: 'non_native_asset');
        }
      };
    }

    if (!isDeposit && !receiveToSendMap.containsKey(_selectedPair!)) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22.sp),
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
    );
  }

  Widget _buildAssetIcon(ShiftPair pair) {
    final logos = _logoMap[pair];
    final bool showNetworkBadge = ![ShiftPair.ethToLiquidBtc, ShiftPair.bnbToLiquidBtc, ShiftPair.solToLiquidBtc].contains(pair);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (logos != null && logos.containsKey('coin'))
          SvgPicture.asset(logos['coin']!, width: 28.sp, height: 28.sp),
        if (logos != null && logos.containsKey('network') && showNetworkBadge)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              padding: EdgeInsets.all(2.sp),
              decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
              child: SvgPicture.asset(logos['network']!, width: 14.sp, height: 14.sp),
            ),
          )
      ],
    );
  }
}