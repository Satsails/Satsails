import 'dart:async';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:vibration/vibration.dart';

// A consistent style for all transaction bottom sheets
const _bottomSheetDecoration = BoxDecoration(
  color: Color(0xFF1E1E1E), // A solid dark color for the sheet
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  ),
);
// UPDATED: Style for the top notification banner to be off-white
const _notificationBannerDecoration = BoxDecoration(
  color: Color(0xFF1E1E1E), // Off-white color
  borderRadius: BorderRadius.all(Radius.circular(24.0)),
);

// Helper to show the transaction sent bottom sheet
void showFullscreenTransactionSendModal({
  required BuildContext context,
  required String amount,
  required String receiveAddress,
  int? confirmationBlocks,
  String? asset,
  bool fiat = false,
  String? fiatAmount,
  String? txid,
  bool isLiquid = false,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Required for custom border radius
    builder: (BuildContext context) {
      return PaymentTransactionOverlay(
        amount: amount,
        fiat: fiat,
        fiatAmount: fiatAmount,
        asset: asset,
        txid: txid,
        isLiquid: isLiquid,
        receiveAddress: receiveAddress,
        confirmationBlocks: confirmationBlocks,
      );
    },
  );
}

// Helper to show the exchange bottom sheet
void showFullscreenExchangeModal({
  required BuildContext context,
  required SwapType swapType,
  required int amount,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Required for custom border radius
    builder: (BuildContext context) {
      return ExchangeTransactionOverlay(
        swapType: swapType,
        amount: amount,
      );
    },
  );
}

// UPDATED: This widget is now an off-white notification banner.
class ReceiveTransactionOverlay extends ConsumerStatefulWidget {
  const ReceiveTransactionOverlay({
    super.key,
    required this.amount,
    this.fiat = false,
    this.fiatAmount,
    this.asset,
  });

  final String amount;
  final bool fiat;
  final String? fiatAmount;
  final String? asset;

  @override
  ReceiveTransactionOverlayState createState() =>
      ReceiveTransactionOverlayState();
}

class ReceiveTransactionOverlayState extends ConsumerState<ReceiveTransactionOverlay>
    with TickerProviderStateMixin {
  bool _isChecked = false;
  bool _showContent = false;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isChecked = true);
        _animationController.forward();
        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) Vibration.vibrate(duration: 100);
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String getFiatSymbol(String asset) {
    final upper = asset.toUpperCase();
    if (upper.contains('DEPIX')) return 'R\$';
    if (upper.contains('EUROX') || upper.contains('EURX')) return '€';
    if (upper.contains('USDT')) return '\$';
    return '\$';
  }

  @override
  Widget build(BuildContext context) {
    final assetName = widget.asset ?? '';
    const textColor = Colors.white;

    String primaryAmount;
    String? secondaryAmount;

    if (widget.fiat && widget.fiatAmount != null && widget.asset != null) {
      primaryAmount = '${getFiatSymbol(widget.asset!)}${widget.fiatAmount}';
      secondaryAmount = null;
    } else {
      primaryAmount = widget.amount;
      if (widget.fiatAmount != null && widget.asset != null) {
        secondaryAmount = '${getFiatSymbol(widget.asset!)}${widget.fiatAmount}';
      }
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: _notificationBannerDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: MSHCheckbox(
                  size: 36.sp,
                  value: _isChecked,
                  colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                    checkedColor: Colors.green.shade600,
                  ),
                  style: MSHCheckboxStyle.stroke,
                  onChanged: (_) {},
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeIn,
                  opacity: _showContent ? 1.0 : 0.0,
                  child: Row(
                    children: [
                      if (assetName.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: getAssetImage(assetName,
                              width: 36.sp, height: 36.sp),
                        ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              primaryAmount,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                decoration: TextDecoration.none,
                                fontFamily: 'Roboto', // Flutter's default Material font
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              secondaryAmount ??
                                  'Payment successfully received'.i18n,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: textColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none, // No underline
                                fontFamily: 'Roboto', // Flutter's default Material font
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
}

class PaymentTransactionOverlay extends ConsumerStatefulWidget {
  final String amount;
  final bool fiat;
  final String? fiatAmount;
  final String? asset;
  final String? txid;
  final bool isLiquid;
  final String receiveAddress;
  final int? confirmationBlocks;

  const PaymentTransactionOverlay({
    super.key,
    required this.amount,
    required this.receiveAddress,
    this.fiat = false,
    this.fiatAmount,
    this.asset,
    this.txid,
    this.isLiquid = false,
    this.confirmationBlocks,
  });

  @override
  _PaymentTransactionOverlayState createState() =>
      _PaymentTransactionOverlayState();
}

class _PaymentTransactionOverlayState
    extends ConsumerState<PaymentTransactionOverlay> with TickerProviderStateMixin {
  bool _checked = false;
  bool _showContent = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _checked = true);
        _animationController.forward();
        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) Vibration.vibrate(duration: 100);
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String shortenString(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  String _getConfirmationText() {
    final blocks = widget.confirmationBlocks;
    if (blocks == null) return 'Instant'.i18n;
    if (blocks == 1) return '1 block'.i18n;
    return '$blocks ${'blocks'.i18n}';
  }

  String _getDisplayAmount() {
    if (widget.fiat && widget.fiatAmount != null) {
      return widget.fiatAmount!;
    } else {
      return widget.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _bottomSheetDecoration,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              SizedBox(height: 20.h),
              ScaleTransition(
                scale: _scaleAnimation,
                child: MSHCheckbox(
                  size: 90.sp,
                  value: _checked,
                  colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                      checkedColor: Colors.green),
                  style: MSHCheckboxStyle.stroke,
                  onChanged: (_) {},
                ),
              ),
              SizedBox(height: 16.h),
              Text('Transaction Sent'.i18n,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 24.h),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                opacity: _showContent ? 1.0 : 0.0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: getAssetImage(widget.asset,
                              width: 32.sp, height: 32.sp),
                        ),
                        Text(
                          _getDisplayAmount(),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Divider(color: Colors.white.withOpacity(0.15)),
                    ),
                    _buildDetailRow(
                      label: 'Confirmation'.i18n,
                      value: _getConfirmationText(),
                    ),
                    _buildDetailRow(
                      label: 'Recipient'.i18n,
                      value: shortenString(widget.receiveAddress),
                      canCopy: true,
                      copyValue: widget.receiveAddress,
                    ),
                    if (widget.txid != null && widget.txid!.isNotEmpty)
                      _buildDetailRow(
                        label: 'Transaction ID'.i18n,
                        value: shortenString(widget.txid!),
                        canCopy: true,
                        copyValue: widget.txid!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required String label,
        required String value,
        bool canCopy = false,
        String? copyValue}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 15.sp)),
          Row(
            children: [
              Text(value,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500)),
              if (canCopy)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: copyValue ?? value));
                    showMessageSnackBar(
                        context: context, message: 'Copied'.i18n, error: false);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Icon(Icons.copy,
                        size: 16.sp, color: Colors.white.withOpacity(0.6)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExchangeTransactionOverlay extends ConsumerStatefulWidget {
  final SwapType swapType;
  final int amount;

  const ExchangeTransactionOverlay({
    super.key,
    required this.swapType,
    required this.amount,
  });

  @override
  _ExchangeTransactionOverlayState createState() =>
      _ExchangeTransactionOverlayState();
}

class _ExchangeTransactionOverlayState
    extends ConsumerState<ExchangeTransactionOverlay>
    with TickerProviderStateMixin {
  bool _checked = false;
  bool _showContent = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _checked = true);
        _animationController.forward();
        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) Vibration.vibrate(duration: 100);
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _getSwapTitle(widget.swapType);
    final assets = _parseAssetsFromTitle(title);
    final fromAsset = assets['from']!;
    final toAsset = assets['to']!;

    String formattedAmount;
    if (_isBitcoinLikeAsset(fromAsset)) {
      final denomination = ref.read(settingsProvider).btcFormat;
      formattedAmount =
          btcInDenominationFormatted(widget.amount, denomination, true);
    } else {
      formattedAmount = fiatInDenominationFormatted(widget.amount);
    }

    return Container(
      decoration: _bottomSheetDecoration,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100))),
              SizedBox(height: 20.h),
              ScaleTransition(
                scale: _scaleAnimation,
                child: MSHCheckbox(
                    size: 90.sp,
                    value: _checked,
                    colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                        checkedColor: Colors.green),
                    style: MSHCheckboxStyle.stroke,
                    onChanged: (_) {}),
              ),
              SizedBox(height: 16.h),
              Text('Swap Initiated'.i18n,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 24.h),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                opacity: _showContent ? 1.0 : 0.0,
                child: Column(
                  children: [
                    Text(formattedAmount,
                        style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9))),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAssetColumn(fromAsset, 'From'.i18n),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(Icons.arrow_forward,
                              color: Colors.white.withOpacity(0.6),
                              size: 24.sp),
                        ),
                        _buildAssetColumn(toAsset, 'To'.i18n),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetColumn(String assetName, String label) {
    return Column(
      children: [
        getAssetImage(assetName, width: 40.sp, height: 40.sp),
        SizedBox(height: 8.h),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 14.sp)),
        SizedBox(height: 2.h),
        Text(assetName,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getSwapTitle(SwapType swapType) {
    switch (swapType) {
      case SwapType.sideswapBtcToLbtc:
        return 'Bitcoin to Liquid Bitcoin';
      case SwapType.sideswapLbtcToBtc:
        return 'Liquid Bitcoin to Bitcoin';
      case SwapType.coinosLnToBTC:
        return 'Lightning to Bitcoin';
      case SwapType.coinosLnToLBTC:
        return 'Lightning to Liquid Bitcoin';
      case SwapType.coinosBtcToLn:
        return 'Bitcoin to Lightning';
      case SwapType.coinosLbtcToLn:
        return 'Liquid Bitcoin to Lightning';
      case SwapType.sideswapUsdtToLbtc:
        return 'USDT to Liquid Bitcoin';
      case SwapType.sideswapEuroxToLbtc:
        return 'EUROX to Liquid Bitcoin';
      case SwapType.sideswapDepixToLbtc:
        return 'DEPIX to Liquid Bitcoin';
      case SwapType.sideswapLbtcToUsdt:
        return 'Liquid Bitcoin to USDT';
      case SwapType.sideswapLbtcToEurox:
        return 'Liquid Bitcoin to EUROX';
      case SwapType.sideswapLbtcToDepix:
        return 'Liquid Bitcoin to DEPIX';
      case SwapType.sideswapDepixToUsdt:
        return 'DEPIX to USDT';
      case SwapType.sideswapUsdtToEurox:
        return 'USDT to EUROX';
      case SwapType.sideswapUsdtToDepix:
        return 'USDT to DEPIX';
      case SwapType.sideswapEuroxToUsdt:
        return 'EUROX to USDT';
      default:
        return 'Exchange';
    }
  }

  Map<String, String> _parseAssetsFromTitle(String title) {
    final parts = title.split(' to ');
    if (parts.length == 2) {
      return {'from': parts[0], 'to': parts[1]};
    }
    return {'from': '', 'to': ''};
  }

  bool _isBitcoinLikeAsset(String asset) {
    return asset == 'Liquid Bitcoin' ||
        asset == 'Lightning' ||
        asset == 'Bitcoin';
  }
}