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

// Abstract class to handle different bridge types in one dropdown
abstract class BridgeOption {
  const BridgeOption();
}

class SideShiftBridgeOption extends BridgeOption {
  final ShiftPair pair;
  const SideShiftBridgeOption(this.pair);
}

class LightningBridgeOption extends BridgeOption {
  const LightningBridgeOption();
}


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

  BridgeOption? _selectedBridgeOption;
// --- MODIFIED: Default direction is now withdrawal ---
  bool _isDepositing = false;

  late final List<BridgeOption> _allBridgeOptions;

  final Map<ShiftPair, ShiftPair> receiveToSendMap = {
    ShiftPair.usdcEthToLiquidUsdt: ShiftPair.liquidUsdtToUsdcEth,
    ShiftPair.usdcSolToLiquidUsdt: ShiftPair.liquidUsdtToUsdcSol,
    ShiftPair.usdcPolygonToLiquidUsdt: ShiftPair.liquidUsdtToUsdcPolygon,
    ShiftPair.usdtEthToLiquidUsdt: ShiftPair.liquidUsdtToUsdtEth,
    ShiftPair.usdtTronToLiquidUsdt: ShiftPair.liquidUsdtToUsdtTron,
    ShiftPair.usdtSolToLiquidUsdt: ShiftPair.liquidUsdtToUsdtSol,
    ShiftPair.usdtPolygonToLiquidUsdt: ShiftPair.liquidUsdtToUsdtPolygon,
    ShiftPair.btcToLiquidBtc: ShiftPair.liquidBtcToBtc,
    ShiftPair.usdtArbitrumToLiquidUsdt: ShiftPair.liquidUsdtToUsdtArbitrum,
  };

  @override
  void initState() {
    super.initState();

    final List<ShiftPair> selectablePairs = [
      ShiftPair.btcToLiquidBtc,
      ShiftPair.usdtArbitrumToLiquidUsdt,
      ShiftPair.usdcEthToLiquidUsdt, ShiftPair.usdcSolToLiquidUsdt, ShiftPair.usdcPolygonToLiquidUsdt,
      ShiftPair.usdtEthToLiquidUsdt, ShiftPair.usdtTronToLiquidUsdt, ShiftPair.usdtSolToLiquidUsdt, ShiftPair.usdtPolygonToLiquidUsdt,
      ShiftPair.ethToLiquidBtc, ShiftPair.bnbToLiquidBtc, ShiftPair.solToLiquidBtc,
    ];

    _allBridgeOptions = [
      const LightningBridgeOption(),
      ...selectablePairs.map((pair) => SideShiftBridgeOption(pair)),
    ];

    _selectedBridgeOption = _allBridgeOptions.firstWhere(
          (option) => option is SideShiftBridgeOption && option.pair == ShiftPair.btcToLiquidBtc,
      orElse: () => _allBridgeOptions.first,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final swapType = ref.read(swapTypeProvider);
      if (swapType != null) {
        ref.read(swapTypeNotifierProvider.notifier).updateProviders(swapType);
      }
    });
  }

// --- HELPER METHODS ---
  Map<String, String> _getAssetInfo(ShiftPair pair) {
    switch (pair) {
      case ShiftPair.usdcEthToLiquidUsdt: return {'name': 'USDC', 'network': 'Ethereum'};
      case ShiftPair.usdcSolToLiquidUsdt: return {'name': 'USDC', 'network': 'Solana'};
      case ShiftPair.usdcPolygonToLiquidUsdt: return {'name': 'USDC', 'network': 'Polygon'};
      case ShiftPair.usdtEthToLiquidUsdt: return {'name': 'USDT', 'network': 'Ethereum'};
      case ShiftPair.usdtTronToLiquidUsdt: return {'name': 'USDT', 'network': 'Tron'};
      case ShiftPair.usdtSolToLiquidUsdt: return {'name': 'USDT', 'network': 'Solana'};
      case ShiftPair.usdtPolygonToLiquidUsdt: return {'name': 'USDT', 'network': 'Polygon'};
      case ShiftPair.ethToLiquidBtc: return {'name': 'ETH', 'network': 'Ethereum'};
      case ShiftPair.bnbToLiquidBtc: return {'name': 'BNB', 'network': 'BNB Chain'};
      case ShiftPair.solToLiquidBtc: return {'name': 'SOL', 'network': 'Solana'};
      case ShiftPair.btcToLiquidBtc: return {'name': 'Bitcoin', 'network': 'Bitcoin'};
      case ShiftPair.usdtArbitrumToLiquidUsdt: return {'name': 'USDT', 'network': 'Arbitrum'};
      default: return {'name': 'Unknown', 'network': 'Unknown'};
    }
  }

  String _getPairDisplayText(ShiftPair pair) {
    final info = _getAssetInfo(pair);
    final network = info['network']!;
    final name = info['name']!;
    if (network == 'Ethereum' && name == 'ETH') return 'Ethereum';
    if (network == 'Solana' && name == 'SOL') return 'Solana';
    if (network == 'BNB Chain' && name == 'BNB') return 'BNB Chain';
    if (network == 'Bitcoin' && name == 'Bitcoin') return 'Bitcoin';
    return '$network $name';
  }

// --- BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.unfocus();
          return false;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text(
            'Exchange'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
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
          _buildPickerOption(SwapSection.external, 'To Other Wallets'),
        ],
      ),
    );
  }

  Widget _buildPickerOption(SwapSection section, String text) {
    final bool isSelected = _selectedSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(sendTxProvider.notifier).resetToDefault();
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
      SizedBox(height: 16.h),
      buildExchangeCard(context, ref, controller),
      SizedBox(height: 24.h),
      buildAdvancedOptionsCard(ref),
      feeSelection(ref),
      slideToSend(ref, context),
    ];
  }

  List<Widget> _buildExternalSwapWidgets() {
    return [
      _buildBridgeExchangeCard(),
      SizedBox(height: 16.h),
      _buildDynamicActionButtons(),
    ];
  }

  Widget _buildBridgeExchangeCard() {
    final selectedOption = _selectedBridgeOption;

    final Widget externalAssetWidget = _buildBridgeOptionDropdown();
    Widget nativeAssetWidget;
    bool isSwapEnabled;

    if (selectedOption is SideShiftBridgeOption) {
      nativeAssetWidget = _buildSatsailsAssetStaticDisplay(selectedOption.pair);
      isSwapEnabled = receiveToSendMap.containsKey(selectedOption.pair);
    } else { // LightningBridgeOption
      nativeAssetWidget = _buildLbtcStaticDisplay();
      isSwapEnabled = true;
    }

    final Widget fromContent = _isDepositing ? externalAssetWidget : nativeAssetWidget;
    final Widget toContent = _isDepositing ? nativeAssetWidget : externalAssetWidget;

    final bool isFromNative = fromContent == nativeAssetWidget;

    return Card(
      color: const Color(0x00333333).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Column(
          children: [
            _buildAssetRow("From Asset", fromContent, isNative: isFromNative),
            SizedBox(height: 24.h),
            _buildSwapDivider(isEnabled: isSwapEnabled),
            SizedBox(height: 24.h),
            _buildAssetRow("To Asset", toContent, isNative: !isFromNative),
          ],
        ),
      ),
    );
  }

  Widget _buildBridgeOptionDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<BridgeOption>(
        value: _selectedBridgeOption,
        dropdownColor: const Color(0xFF212121),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        items: _allBridgeOptions.map((option) {
          return DropdownMenuItem<BridgeOption>(
            value: option,
            child: _buildOptionDisplay(option),
          );
        }).toList(),
        onChanged: (BridgeOption? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedBridgeOption = newValue;
            });
          }
        },
        icon: Padding(padding: EdgeInsets.only(left: 8.0.w), child: const Icon(Icons.arrow_drop_down, color: Colors.white)),
        isDense: true,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
      ),
    );
  }

  Widget _buildOptionDisplay(BridgeOption option) {
    if (option is LightningBridgeOption) {
      return Row(
        children: [
          Image.asset('lib/assets/Bitcoin_lightning_logo.png', width: 28.sp, height: 28.sp),
          SizedBox(width: 8.w),
          Text("Lightning Network".i18n, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
        ],
      );
    }

    final pair = (option as SideShiftBridgeOption).pair;
    return Row(
      children: [
        _buildAssetIcon(pair),
        SizedBox(width: 8.w),
        Text(_getPairDisplayText(pair), style: TextStyle(color: Colors.white, fontSize: 16.sp)),
      ],
    );
  }

  Widget _buildDynamicActionButtons() {
    final selectedOption = _selectedBridgeOption;
    if (selectedOption is SideShiftBridgeOption) {
      return _buildSingleActionButton(selectedOption.pair);
    } else if (selectedOption is LightningBridgeOption) {
      return _buildLightningActionButton();
    }
    return const SizedBox.shrink();
  }

  Widget _buildAssetRow(String label, Widget content, {required bool isNative}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.i18n, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              SizedBox(height: 12.h),
              content,
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Text(isNative ? 'Satsails Asset'.i18n : 'External Asset'.i18n, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
      ],
    );
  }

  Widget _buildSwapDivider({required bool isEnabled}) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GestureDetector(
            onTap: isEnabled ? () => setState(() => _isDepositing = !_isDepositing) : null,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isEnabled ? Colors.grey.shade800 : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.swap_vert, color: isEnabled ? Colors.white : Colors.white24, size: 24.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLbtcStaticDisplay() => Row(
    children: [
      Image.asset('lib/assets/l-btc.png', width: 28.sp, height: 28.sp),
      SizedBox(width: 8.w),
      Text('L-BTC', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
    ],
  );

  Widget _buildSatsailsAssetStaticDisplay(ShiftPair pair) {
    final bool isLbtcPair = pair.name.contains('Btc');
    final liquidLogo = isLbtcPair ? 'lib/assets/l-btc.png' : 'lib/assets/tether.png';
    final liquidName = isLbtcPair ? 'L-BTC' : 'Liquid USDT';

    return Row(
      children: [
        Image.asset(liquidLogo, width: 28.sp, height: 28.sp),
        SizedBox(width: 8.w),
        Text(liquidName, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
      ],
    );
  }

  Widget _buildLightningActionButton() {
    final bool isDeposit = _isDepositing;
    final String label = isDeposit ? 'Deposit to Satsails'.i18n : 'Withdrawal from Satsails'.i18n;
    final IconData icon = isDeposit ? Icons.arrow_downward : Icons.arrow_upward;
    final Color iconColor = isDeposit ? const Color(0xFF00C853) : Colors.red;

    final VoidCallback onPressed = isDeposit
        ? () {
      ref.read(selectedNetworkTypeProvider.notifier).state = 'Boltz Network';
      context.push('/home/receive');
    }
        : () {
      ref.read(sendTxProvider.notifier).resetToDefault();
      context.push('/home/pay', extra: 'lightning');
    };

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
            Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleActionButton(ShiftPair pair) {
    final bool isDeposit = _isDepositing;

// --- MODIFIED: Check for unavailability and show a disabled button ---
    if (!isDeposit && !receiveToSendMap.containsKey(pair)) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, color: Colors.grey, size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              'Withdrawal Unavailable'.i18n,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

// This is the original, active button
    final String label = isDeposit ? 'Deposit to Satsails'.i18n : 'Withdrawal from Satsails'.i18n;
    final IconData icon = isDeposit ? Icons.arrow_downward : Icons.arrow_upward;
    final Color iconColor = isDeposit ? const Color(0xFF00C853) : Colors.red;

    final VoidCallback onPressed;
    if (isDeposit) {
      onPressed = () {
        ref.read(selectedNetworkTypeProvider.notifier).state = 'SideShift';
        ref.read(selectedShiftPairProvider.notifier).state = pair;
        context.push('/home/receive');
      };
    } else {
      final sendPair = receiveToSendMap[pair];
      onPressed = () {
        if (sendPair != null) {
          final isLbtcPair = sendPair.name.contains('liquidBtc');
          ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(isLbtcPair ? AssetId.LBTC : AssetId.USD));
          ref.read(selectedSendShiftPairProvider.notifier).state = sendPair;
          context.push('/home/pay', extra: 'non_native_asset');
        }
      };
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
            Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetIcon(ShiftPair pair) {
    final logos = {
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
      ShiftPair.btcToLiquidBtc: {'coin': 'lib/assets/bitcoin-logo.png'},
      ShiftPair.usdtArbitrumToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/arbitrum-logo.png'},
    }[pair];

    final coinPath = logos?['coin'];
    final networkPath = logos?['network'];
    final bool showNetworkBadge = networkPath != null && pair != ShiftPair.ethToLiquidBtc && pair != ShiftPair.bnbToLiquidBtc && pair != ShiftPair.solToLiquidBtc;

    Widget coinIcon;
    if (coinPath == null) {
      coinIcon = Icon(Icons.error, color: Colors.red, size: 28.sp);
    } else if (coinPath.endsWith('.svg')) {
      coinIcon = SvgPicture.asset(coinPath, width: 28.sp, height: 28.sp);
    } else {
      coinIcon = Image.asset(coinPath, width: 28.sp, height: 28.sp);
    }

    Widget? networkIcon;
    if (networkPath != null) {
      if (networkPath.endsWith('.svg')) {
        networkIcon = SvgPicture.asset(networkPath, width: 14.sp, height: 14.sp);
      } else {
        networkIcon = Image.asset(networkPath, width: 14.sp, height: 14.sp);
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        coinIcon,
        if (showNetworkBadge && networkIcon != null)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              padding: EdgeInsets.all(2.sp),
              decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
              child: networkIcon,
            ),
          )
      ],
    );
  }
}