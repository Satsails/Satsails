import 'dart:ui';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../providers/currency_conversions_provider.dart';

// Helper classes and enums for Bridge functionality
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

final selectedNetworkTypeProvider = StateProvider<String>((ref) => "Bitcoin Network");

class BalanceCard extends ConsumerStatefulWidget {
  const BalanceCard({super.key});

  @override
  ConsumerState<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> with TickerProviderStateMixin {
  static final List<Map<String, String>> _allAssets = [
    {'name': 'Bitcoin', 'icon': 'lib/assets/bitcoin-logo.png', 'network': 'Bitcoin Network'},
    {'name': 'Lightning', 'icon': 'lib/assets/Bitcoin_lightning_logo.png', 'network': 'Lightning Network'},
    {'name': 'Liquid Bitcoin', 'icon': 'lib/assets/l-btc.png', 'network': 'Liquid Network'},
    {'name': 'USDT', 'icon': 'lib/assets/tether.png', 'network': 'Liquid Network'},
    {'name': 'EURx', 'icon': 'lib/assets/eurx.png', 'network': 'Liquid Network'},
    {'name': 'Depix', 'icon': 'lib/assets/depix.png', 'network': 'Liquid Network'},
  ];

  late final PageController _pageController;

  // Custom Popup State
  late final AnimationController _popupAnimationController;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    final initialAsset = ref.read(selectedAssetProvider);
    final initialIndex = _allAssets.indexWhere((asset) => asset['name'] == initialAsset);
    _pageController = PageController(initialPage: initialIndex >= 0 ? initialIndex : 0);

    _popupAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _popupAnimationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showTransactionSheet({required bool isSend}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return TransactionOptionsSheet(
          isSend: isSend,
          allNativeAssets: _allAssets,
        );
      },
    );
  }

  void _togglePopup() {
    if (_overlayEntry != null) {
      _closePopup();
    } else {
      _openPopup();
    }
  }

  void _openPopup() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _popupAnimationController.forward();
  }

  void _closePopup() {
    _popupAnimationController.reverse().then((_) {
      _removeOverlay();
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenheight < 750;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildAssetSelector(context, ref, isSmallScreen)),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _allAssets.length,
                onPageChanged: (index) {
                  ref.read(selectedAssetProvider.notifier).state = _allAssets[index]['name']!;
                },
                itemBuilder: (context, index) {
                  return _AssetDetailsView(
                    assetData: _allAssets[index],
                    isSmallScreen: isSmallScreen,
                    pageController: _pageController,
                    pageIndex: index,
                  );
                },
              ),
            ),
            _buildActionButtons(context, ref, isSmallScreen),
            SizedBox(height: 8.h),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusIndicator(WidgetRef ref) {
    final isSyncing = ref.watch(backgroundSyncInProgressProvider);
    final isOnline = ref.watch(settingsProvider).online;

    return GestureDetector(
      onTap: isSyncing ? null : () => ref.read(backgroundSyncNotifierProvider.notifier).performFullUpdate(),
      child: Container(
        width: 10.sp,
        height: 10.sp,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? (isSyncing ? Colors.orange : Colors.green) : Colors.red,
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          // Scrim / Backdrop
          FadeTransition(
            opacity: CurvedAnimation(parent: _popupAnimationController, curve: Curves.easeOut),
            child: GestureDetector(
              onTap: _closePopup,
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
          // The popup menu itself
          FadeTransition(
            opacity: CurvedAnimation(parent: _popupAnimationController, curve: Curves.easeOut),
            child: ScaleTransition(
              alignment: Alignment.center,
              scale: CurvedAnimation(parent: _popupAnimationController, curve: Curves.easeOutCubic),
              child: _buildPopupMenu(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPopupMenu() {
    final balanceState = ref.watch(balanceNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final isBalanceVisible = settings.balanceVisible;
    final selectedAsset = ref.watch(selectedAssetProvider);
    final networks = ['Bitcoin Network', 'Lightning Network', 'Liquid Network'];

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 0.9.sw, // 90% of screen width
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: BoxConstraints(maxHeight: 0.6.sh), // 60% of screen height
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C).withOpacity(0.85),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                shrinkWrap: true,
                itemCount: _allAssets.length + networks.length,
                separatorBuilder: (context, index) {
                  final isLastItemInGroup = _allAssets.where((a) => a['network'] == networks.first).length == index ||
                      _allAssets.where((a) => a['network'] == networks[1] || a['network'] == networks[0]).length + 1 == index;
                  return isLastItemInGroup ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                    child: Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                  ) : const SizedBox.shrink();
                },
                itemBuilder: (context, index) {
                  int assetIndex = index;
                  if (index < _allAssets.where((a) => a['network'] == networks.first).length + 1) { // Bitcoin Network
                    if (index == 0) return _buildNetworkHeader(networks.first);
                    assetIndex -= 1;
                  } else if (index < _allAssets.where((a) => a['network'] != networks.last).length + 2) { // Lightning Network
                    if (index == _allAssets.where((a) => a['network'] == networks.first).length + 1) return _buildNetworkHeader(networks[1]);
                    assetIndex -= 2;
                  } else { // Liquid Network
                    if (index == _allAssets.where((a) => a['network'] != networks.last).length + 2) return _buildNetworkHeader(networks.last);
                    assetIndex -= 3;
                  }

                  final asset = _allAssets[assetIndex];
                  final assetName = asset['name']!;
                  final isSelected = selectedAsset == assetName;

                  String balanceString;
                  final assetForBalance = asset['network'] == 'Lightning Network' ? 'Liquid Bitcoin' : assetName;

                  switch (assetForBalance) {
                    case 'Bitcoin': balanceString = btcInDenominationFormatted(balanceState.onChainBtcBalance, settings.btcFormat); break;
                    case 'Liquid Bitcoin': balanceString = btcInDenominationFormatted(balanceState.liquidBtcBalance, settings.btcFormat); break;
                    case 'USDT': balanceString = fiatInDenominationFormatted(balanceState.liquidUsdtBalance); break;
                    case 'EURx': balanceString = fiatInDenominationFormatted(balanceState.liquidEuroxBalance); break;
                    case 'Depix': balanceString = fiatInDenominationFormatted(balanceState.liquidDepixBalance); break;
                    default: balanceString = '';
                  }

                  if (!isBalanceVisible) balanceString = '••••••';

                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedAssetProvider.notifier).state = assetName;
                      _closePopup();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                      child: Row(
                        children: [
                          Image.asset(asset['icon']!, width: 32.sp, height: 32.sp),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Text(
                              assetName,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18.sp),
                            ),
                          ),
                          Text(
                            balanceString,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500, fontSize: 16.sp),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkHeader(String networkName) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      child: Text(
        networkName.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildAssetSelector(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    final selectedAssetName = ref.watch(selectedAssetProvider);
    final selectedAssetData = _allAssets.firstWhere(
          (a) => a['name'] == selectedAssetName,
      orElse: () => _allAssets.first,
    );

    final assetNameFontSize = isSmallScreen ? 16.sp : 18.sp;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePopup,
      child: Row(
        children: [
          Image.asset(selectedAssetData['icon']!, width: 28.sp, height: 28.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              selectedAssetData['name']!,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: assetNameFontSize,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildSyncStatusIndicator(ref),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Balances'.i18n,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 4.w),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
                      parent: _popupAnimationController,
                      curve: Curves.easeInOut)),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    const textColor = Colors.white;
    final buttonColor = Colors.black.withOpacity(0.2);
    final buttonFontSize = isSmallScreen ? 14.sp : 15.sp;

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_downward,
            label: 'Receive'.i18n,
            onPressed: () => _showTransactionSheet(isSend: false),
            textColor: textColor,
            buttonColor: buttonColor,
            fontSize: buttonFontSize,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_upward,
            label: 'Send'.i18n,
            onPressed: () => _showTransactionSheet(isSend: true),
            textColor: textColor,
            buttonColor: buttonColor,
            fontSize: buttonFontSize,
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 18.w, weight: 700),
            SizedBox(width: 8.w),
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
}

class TransactionOptionsSheet extends ConsumerStatefulWidget {
  final bool isSend;
  final List<Map<String, String>> allNativeAssets;

  const TransactionOptionsSheet({
    required this.isSend,
    required this.allNativeAssets,
    super.key,
  });

  @override
  ConsumerState<TransactionOptionsSheet> createState() =>
      _TransactionOptionsSheetState();
}

class _TransactionOptionsSheetState extends ConsumerState<TransactionOptionsSheet> {
  final GlobalKey _firstViewKey = GlobalKey();
  final GlobalKey _secondViewKey = GlobalKey();
  double? _sheetHeight;

  static final List<ShiftPair> _selectablePairs = [
    ShiftPair.btcToLiquidBtc, ShiftPair.usdtArbitrumToLiquidUsdt,
    ShiftPair.usdcEthToLiquidUsdt, ShiftPair.usdcSolToLiquidUsdt, ShiftPair.usdcPolygonToLiquidUsdt,
    ShiftPair.usdtEthToLiquidUsdt, ShiftPair.usdtTronToLiquidUsdt, ShiftPair.usdtSolToLiquidUsdt, ShiftPair.usdtPolygonToLiquidUsdt,
    ShiftPair.ethToLiquidBtc, ShiftPair.bnbToLiquidBtc, ShiftPair.solToLiquidBtc,
  ];

  static final List<BridgeOption> _allBridgeOptions = [
    ..._selectablePairs.map((pair) => SideShiftBridgeOption(pair)),
  ];

  static const Map<ShiftPair, ShiftPair> _receiveToSendMap = {
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

  Map<String, String>? _selectedNativeAsset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateSheetHeight(_firstViewKey);
    });
  }

  void _updateSheetHeight(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final newHeight = (context.findRenderObject() as RenderBox).size.height;
      final totalHeight = newHeight + 40.h + MediaQuery.of(context).padding.bottom;
      final maxHeight = MediaQuery.of(context).size.height * 0.9;
      setState(() {
        _sheetHeight = totalHeight > maxHeight ? maxHeight : totalHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _sheetHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          _buildGrabber(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                final slideIn = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                if (child.key == const ValueKey('BridgeSelection')) {
                  return SlideTransition(position: slideIn, child: child);
                }
                return FadeTransition(opacity: animation, child: child);
              },
              child: _selectedNativeAsset == null
                  ? _buildNativeAssetSelectionView()
                  : _buildBridgeOptionsView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeAssetSelectionView() {
    return SingleChildScrollView(
      key: const ValueKey('NativeSelection'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          key: _firstViewKey,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSheetHeader(
              title: widget.isSend ? 'Send From'.i18n : 'Receive To'.i18n,
            ),
            SizedBox(height: 8.h),
            ...widget.allNativeAssets.map((asset) => _buildNativeAssetTile(context, ref, asset)),
            SizedBox(height: 10.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildBridgeOptionsView() {
    final assetIcon = _selectedNativeAsset!['icon']!;
    final bridgeOptions = _getFilteredBridgeOptions();
    final assetName = _selectedNativeAsset!['name'];

    return SingleChildScrollView(
      key: const ValueKey('BridgeSelection'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          key: _secondViewKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetHeader(
              title: widget.isSend ? "Send to".i18n : "Receive via".i18n,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() => _selectedNativeAsset = null);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateSheetHeight(_firstViewKey);
                  });
                },
              ),
              assetIcon: assetIcon,
            ),
            SizedBox(height: 16.h),
            _buildSectionHeader("On-chain".i18n),
            _buildNativeAssetTile(context, ref, _selectedNativeAsset!, isSecondStep: true),
            if (bridgeOptions.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _buildSectionHeader("via Smart Contracts".i18n),
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                child: Text(
                  "Fees apply".i18n,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.4,
                ),
                itemCount: bridgeOptions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildBridgeAssetTile(context, ref, bridgeOptions[index]);
                },
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildNativeAssetTile(BuildContext context, WidgetRef ref, Map<String, String> asset, {bool isSecondStep = false}) {
    final assetName = asset['name']!;
    final network = asset['network']!;
    final isBridgeable = ['Liquid Bitcoin', 'USDT'].contains(assetName);

    return _buildOptionCard(
      leading: Image.asset(asset['icon']!, width: 36.sp, height: 36.sp),
      title: assetName,
      subtitle: isSecondStep ? network.replaceAll(' Network', '') : null,
      trailing: (isBridgeable && !isSecondStep) ? Icon(Icons.arrow_forward_ios, color: Colors.grey.shade600, size: 16) : null,
      onTap: () {
        if (isBridgeable && !isSecondStep) {
          setState(() => _selectedNativeAsset = asset);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateSheetHeight(_secondViewKey);
          });
          return;
        }

        Navigator.pop(context);
        if (widget.isSend) {
          ref.read(sendTxProvider.notifier).resetToDefault();
          _handleNativeSendNavigation(context, ref, assetName);
        } else {
          if (network == 'Lightning Network') {
            ref.read(selectedNetworkTypeProvider.notifier).state = 'Boltz Network';
          } else {
            ref.read(selectedNetworkTypeProvider.notifier).state = network;
          }
          ref.read(selectedAssetProvider.notifier).state = assetName;
          context.push('/home/receive');
        }
      },
    );
  }

  Widget _buildBridgeAssetTile(BuildContext context, WidgetRef ref, BridgeOption option) {
    if (option is SideShiftBridgeOption) {
      final pair = option.pair;
      final sendPair = _receiveToSendMap[pair];
      if (widget.isSend && sendPair == null) {
        return const SizedBox.shrink();
      }

      return _buildOptionCard(
        leading: _buildAssetIcon(pair),
        title: _getPairDisplayText(pair),
        subtitle: "via SideShift".i18n,
        isGrid: true,
        onTap: () {
          Navigator.pop(context);
          if (widget.isSend) {
            if (sendPair != null) {
              final isLbtcPair = sendPair.name.contains('liquidBtc');
              ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(isLbtcPair ? AssetId.LBTC : AssetId.USD));
              ref.read(selectedSendShiftPairProvider.notifier).state = sendPair;
              context.push('/home/pay', extra: 'non_native_asset');
            }
          } else {
            ref.read(selectedNetworkTypeProvider.notifier).state = 'SideShift';
            ref.read(selectedShiftPairProvider.notifier).state = pair;
            context.push('/home/receive');
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGrabber() {
    return Container(
      width: 40.w,
      height: 5.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  Widget _buildSheetHeader({required String title, Widget? leading, String? assetIcon}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48.w,
            child: leading ?? const SizedBox.shrink(),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (assetIcon != null) ...[
                Image.asset(assetIcon, width: 24.sp, height: 24.sp),
                SizedBox(width: 10.w),
              ],
              Text(
                title,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h, top: 4.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildOptionCard({
    required Widget leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    bool isGrid = false,
  }) {
    final content = isGrid
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        leading,
        const Spacer(),
        Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
        if (subtitle != null) ...[
          SizedBox(height: 2.h),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
        ],
      ],
    )
        : Row(
      children: [
        leading,
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              if (subtitle != null) ...[
                SizedBox(height: 3.h),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );

    return Card(
      elevation: 0,
      margin: isGrid ? EdgeInsets.zero : EdgeInsets.only(bottom: 12.h),
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: isGrid ? 16.h : 14.h,
          ),
          child: content,
        ),
      ),
    );
  }

  List<BridgeOption> _getFilteredBridgeOptions() {
    final assetName = _selectedNativeAsset!['name']!;
    if (widget.isSend) {
      if (assetName == 'Liquid Bitcoin') {
        return _allBridgeOptions.whereType<SideShiftBridgeOption>()
            .where((opt) => _receiveToSendMap[opt.pair]?.name.contains('liquidBtcTo') ?? false)
            .toList();
      }
      if (assetName == 'USDT') {
        return _allBridgeOptions.whereType<SideShiftBridgeOption>()
            .where((opt) => _receiveToSendMap[opt.pair]?.name.contains('liquidUsdtTo') ?? false)
            .toList();
      }
    } else {
      if (assetName == 'Liquid Bitcoin') {
        return _allBridgeOptions.whereType<SideShiftBridgeOption>()
            .where((opt) => opt.pair.name.contains('ToLiquidBtc'))
            .toList();
      }
      if (assetName == 'USDT') {
        return _allBridgeOptions.whereType<SideShiftBridgeOption>()
            .where((opt) => opt.pair.name.contains('ToLiquidUsdt'))
            .toList();
      }
    }
    return [];
  }

  void _handleNativeSendNavigation(BuildContext context, WidgetRef ref, String selectedAsset) {
    switch (selectedAsset) {
      case 'Bitcoin': context.push('/home/pay', extra: 'bitcoin'); break;
      case 'Lightning': context.push('/home/pay', extra: 'lightning'); break;
      case 'Liquid Bitcoin':
        ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
        context.push('/home/pay', extra: 'liquid');
        break;
      default:
        String assetId;
        switch (selectedAsset) {
          case 'USDT': assetId = AssetMapper.reverseMapTicker(AssetId.USD); break;
          case 'EURx': assetId = AssetMapper.reverseMapTicker(AssetId.EUR); break;
          case 'Depix': assetId = AssetMapper.reverseMapTicker(AssetId.BRL); break;
          default: assetId = '';
        }
        ref.read(sendTxProvider.notifier).updateAssetId(assetId);
        context.push('/home/pay', extra: 'liquid_asset');
    }
  }

  String _getPairDisplayText(ShiftPair pair) {
    final info = _getAssetInfo(pair);
    final network = info['network']!;
    final name = info['name']!;
    if (widget.isSend) {
      final sendPair = _receiveToSendMap[pair];
      if (sendPair == ShiftPair.liquidBtcToBtc) return 'Bitcoin';
      if (sendPair == ShiftPair.liquidUsdtToUsdcEth) return 'Ethereum USDC';
      if (sendPair == ShiftPair.liquidUsdtToUsdcSol) return 'Solana USDC';
      if (sendPair == ShiftPair.liquidUsdtToUsdcPolygon) return 'Polygon USDC';
      if (sendPair == ShiftPair.liquidUsdtToUsdtEth) return 'Ethereum USDT';
      if (sendPair == ShiftPair.liquidUsdtToUsdtTron) return 'Tron USDT';
      if (sendPair == ShiftPair.liquidUsdtToUsdtSol) return 'Solana USDT';
      if (sendPair == ShiftPair.liquidUsdtToUsdtPolygon) return 'Polygon USDT';
      if (sendPair == ShiftPair.liquidUsdtToUsdtArbitrum) return 'Arbitrum USDT';
    } else {
      if (network == 'Ethereum' && name == 'ETH') return 'Ethereum';
      if (network == 'Solana' && name == 'SOL') return 'Solana';
      if (network == 'BNB Chain' && name == 'BNB') return 'BNB';
      if (network == 'Bitcoin' && name == 'Bitcoin') return 'Bitcoin';
      return '$network $name';
    }
    return 'Unknown';
  }

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

  Widget _buildAssetIcon(ShiftPair pair) {
    ShiftPair pairToShow = pair;
    if (widget.isSend) {
      pairToShow = _receiveToSendMap[pair] ?? pair;
    }

    final logos = {
      // Receive pairs
      ShiftPair.usdcEthToLiquidUsdt: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/eth.svg'},
      ShiftPair.usdcSolToLiquidUsdt: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/sol.svg'},
      ShiftPair.usdcPolygonToLiquidUsdt: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/pol.svg'},
      ShiftPair.usdtEthToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/eth.svg'},
      ShiftPair.usdtTronToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/trx.svg'},
      ShiftPair.usdtSolToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/sol.svg'},
      ShiftPair.usdtPolygonToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/pol.svg'},
      ShiftPair.ethToLiquidBtc: {'coin': 'lib/assets/eth.svg'},
      ShiftPair.bnbToLiquidBtc: {'coin': 'lib/assets/bnb.svg'},
      ShiftPair.solToLiquidBtc: {'coin': 'lib/assets/sol.svg'},
      ShiftPair.btcToLiquidBtc: {'coin': 'lib/assets/bitcoin-logo.png'},
      ShiftPair.usdtArbitrumToLiquidUsdt: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/arbitrum-logo.png'},
      // Send pairs
      ShiftPair.liquidBtcToBtc: {'coin': 'lib/assets/bitcoin-logo.png'},
      ShiftPair.liquidUsdtToUsdcEth: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/eth.svg'},
      ShiftPair.liquidUsdtToUsdcSol: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/sol.svg'},
      ShiftPair.liquidUsdtToUsdcPolygon: {'coin': 'lib/assets/usdc.svg', 'network': 'lib/assets/pol.svg'},
      ShiftPair.liquidUsdtToUsdtEth: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/eth.svg'},
      ShiftPair.liquidUsdtToUsdtTron: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/trx.svg'},
      ShiftPair.liquidUsdtToUsdtSol: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/sol.svg'},
      ShiftPair.liquidUsdtToUsdtPolygon: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/pol.svg'},
      ShiftPair.liquidUsdtToUsdtArbitrum: {'coin': 'lib/assets/usdt.svg', 'network': 'lib/assets/arbitrum-logo.png'},
    }[pairToShow];

    final coinPath = logos?['coin'];
    final networkPath = logos?['network'];
    final bool showNetworkBadge = networkPath != null;
    final double iconSize = 36.sp;

    Widget coinIcon;
    if (coinPath == null) {
      coinIcon = Icon(Icons.error, color: Colors.red, size: iconSize);
    } else if (coinPath.endsWith('.svg')) {
      coinIcon = SvgPicture.asset(coinPath, width: iconSize, height: iconSize);
    } else {
      coinIcon = Image.asset(coinPath, width: iconSize, height: iconSize);
    }

    Widget? networkIcon;
    if (networkPath != null) {
      final double networkIconSize = 18.sp;
      if (networkPath.endsWith('.svg')) {
        networkIcon = SvgPicture.asset(networkPath, width: networkIconSize, height: networkIconSize);
      } else {
        networkIcon = Image.asset(networkPath, width: networkIconSize, height: networkIconSize);
      }
    }

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Stack(
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
      ),
    );
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
                  if (['Bitcoin', 'Liquid Bitcoin', 'Lightning'].contains(selectedAsset))
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
          ],
        ),
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
      case 'Lightning':
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
      data: (data) {
        final isHistoryEmpty = data.isEmpty || data.values.toSet().length <= 1;

        if (isHistoryEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
          child: SimplifiedExpensesGraph(
            dataToDisplay: data,
            graphColor: textColor,
          ),
        );
      },
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