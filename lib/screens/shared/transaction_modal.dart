import 'dart:async';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/creation/components/logo.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

const _solidBackgroundColor = Color(0xFF121212);

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
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, _, __) => PaymentTransactionOverlay(
        amount: amount,
        fiat: fiat,
        fiatAmount: fiatAmount,
        asset: asset,
        txid: txid,
        isLiquid: isLiquid,
        receiveAddress: receiveAddress,
        confirmationBlocks: confirmationBlocks,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

// Shows the full-screen Exchange modal
void showFullscreenExchangeModal({
  required BuildContext context,
  required SwapType swapType,
  required int amount,
  required String orderId,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, _, __) => ExchangeTransactionOverlay(
        swapType: swapType,
        amount: amount,
        orderId: orderId,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

// --- REUSABLE WIDGETS ---

class AnimatedSlideFade extends StatefulWidget {
  final Widget child;
  final int delay;
  final double verticalOffset;

  const AnimatedSlideFade({
    super.key,
    required this.child,
    this.delay = 0,
    this.verticalOffset = 30.0,
  });

  @override
  State<AnimatedSlideFade> createState() => _AnimatedSlideFadeState();
}

class _AnimatedSlideFadeState extends State<AnimatedSlideFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
        begin: Offset(0, widget.verticalOffset / 1000), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class BrandingFooter extends StatelessWidget {
  final int delay;
  const BrandingFooter({super.key, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlideFade(
      delay: delay,
      child: Column(
        children: [
          Logo(
            size: 30.sp, // UPDATED: Increased size
            color: Colors.white,
            opacity: 0.5,
            animated: false,
          ),
          SizedBox(height: 10.h),
          Text(
            'Satsails',
            style: TextStyle(
              fontSize: 18.sp, // UPDATED: Increased size
              color: Colors.white.withOpacity(0.5),
            ),
          )
        ],
      ),
    );
  }
}


// --- OVERLAYS ---

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
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  final String _timestamp =
  DateFormat('MMM d, yyyy HH:mm').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _isChecked = true);
        _animationController.forward();
        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) Vibration.vibrate(duration: 100);
        });
      }
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

  String get displayAmount {
    if (widget.fiat && widget.fiatAmount != null && widget.asset != null) {
      final symbol = getFiatSymbol(widget.asset!);
      return '$symbol${widget.fiatAmount}';
    }
    return widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    final assetName = widget.asset ?? '';

    return Scaffold(
      backgroundColor: _solidBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              const Spacer(),
              AnimatedSlideFade(
                delay: 100,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.green.shade400,
                            size: 40.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Payment Received'.i18n,
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        displayAmount,
                        style: TextStyle(
                          fontSize: 48.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Divider(
                          color: Colors.white.withOpacity(0.1),
                          thickness: 1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (assetName.isNotEmpty) ... [
                                getAssetImage(assetName, width: 28.sp, height: 28.sp),
                                SizedBox(width: 12.w),
                              ],
                              Text(
                                assetName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _timestamp,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const BrandingFooter(delay: 400),
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
    extends ConsumerState<PaymentTransactionOverlay>
    with TickerProviderStateMixin {
  bool _checked = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final String _timestamp =
  DateFormat('MMM d, yyyy HH:mm:ss').format(DateTime.now());

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

  String _getDisplayAmount() {
    if (widget.fiat && widget.fiatAmount != null) {
      return widget.fiatAmount!;
    } else {
      return widget.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _solidBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnimation,
                child:
                getAssetImage(widget.asset, width: 80.sp, height: 80.sp),
              ),
              SizedBox(height: 20.h),
              AnimatedSlideFade(
                delay: 200,
                child: Text('Transaction Sent'.i18n,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 12.h),
              AnimatedSlideFade(
                delay: 300,
                child: Text(
                  _getDisplayAmount(),
                  style: TextStyle(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              if (widget.txid != null && widget.txid!.isNotEmpty)
                AnimatedSlideFade(
                  delay: 400,
                  child: _buildDetailRow(
                    icon: Icons.receipt_long,
                    label: 'Transaction ID'.i18n,
                    value: shortenString(widget.txid!),
                  ),
                ),
              AnimatedSlideFade(
                delay: 500,
                child: _buildDetailRow(
                  icon: Icons.person_outline,
                  label: 'Recipient'.i18n,
                  value: shortenString(widget.receiveAddress),
                ),
              ),
              AnimatedSlideFade(
                delay: 600,
                child: _buildDetailRow(
                  icon: Icons.timer_outlined,
                  label: 'Timestamp'.i18n,
                  value: _timestamp,
                ),
              ),
              const Spacer(),
              const BrandingFooter(delay: 700),
              SizedBox(height: 20.h),
              AnimatedSlideFade(
                delay: 800,
                child: CustomButton(
                  text: 'Done'.i18n,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  primaryColor: const Color(0xFF2E2E2E),
                  secondaryColor: const Color(0xFF1E1E1E),
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.6), size: 20.sp),
          SizedBox(width: 16.w),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 15.sp)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class ExchangeTransactionOverlay extends ConsumerStatefulWidget {
  final SwapType swapType;
  final int amount;
  final String orderId;

  const ExchangeTransactionOverlay({
    super.key,
    required this.swapType,
    required this.amount,
    required this.orderId,
  });

  @override
  _ExchangeTransactionOverlayState createState() =>
      _ExchangeTransactionOverlayState();
}

class _ExchangeTransactionOverlayState
    extends ConsumerState<ExchangeTransactionOverlay>
    with TickerProviderStateMixin {
  final String _timestamp =
  DateFormat('MMM d, yyyy HH:mm:ss').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) Vibration.vibrate(duration: 100);
        });
      }
    });
  }

  String shortenString(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
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

    return Scaffold(
      backgroundColor: _solidBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              const Spacer(),
              AnimatedSlideFade(
                delay: 200,
                child: Text('Swap Initiated'.i18n,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 12.h),
              AnimatedSlideFade(
                delay: 300,
                child: Text(formattedAmount,
                    style: TextStyle(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              SizedBox(height: 30.h),
              AnimatedSlideFade(
                delay: 400,
                child: Container(
                  padding:
                  EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAssetInfo(fromAsset, 'from'),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white.withOpacity(0.6), size: 24.sp),
                      _buildAssetInfo(toAsset, 'To'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              AnimatedSlideFade(
                delay: 500,
                child: _buildMetadataSection(
                    swapId: widget.orderId, timestamp: _timestamp),
              ),
              const Spacer(),
              const BrandingFooter(delay: 600),
              SizedBox(height: 20.h),
              AnimatedSlideFade(
                delay: 700,
                child: CustomButton(
                  text: 'Done'.i18n,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  primaryColor: const Color(0xFF2E2E2E),
                  secondaryColor: const Color(0xFF1E1E1E),
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetInfo(String assetName, String direction) {
    return Column(
      crossAxisAlignment: direction == 'from'
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          direction.i18n,
          style:
          TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13.sp),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            if (direction == 'from') ...[
              getAssetImage(assetName, width: 24.sp, height: 24.sp),
              SizedBox(width: 8.w),
            ],
            Text(assetName,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold)),
            if (direction == 'To') ...[
              SizedBox(width: 8.w),
              getAssetImage(assetName, width: 24.sp, height: 24.sp),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataSection(
      {required String swapId, required String timestamp}) {
    // Style for both labels and values to ensure they are the same size/weight
    final metadataStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: 14.sp,
      fontWeight: FontWeight.normal,
    );
    final labelStyle = TextStyle(
      color: Colors.white.withOpacity(0.5),
      fontSize: 13.sp,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.5,
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Swap ID".i18n, style: labelStyle),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: swapId));
                  showMessageSnackBar(
                      context: context,
                      message: "Swap ID Copied".i18n,
                      error: false);
                },
                child: Row(
                  children: [
                    Text(shortenString(swapId), style: metadataStyle),
                    SizedBox(width: 8.w),
                    Icon(Icons.copy_outlined,
                        size: 15.sp, color: Colors.white.withOpacity(0.6))
                  ],
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Timestamp", style: labelStyle),
              SizedBox(height: 4.h),
              Text(timestamp, style: metadataStyle),
            ],
          )
        ],
      ),
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