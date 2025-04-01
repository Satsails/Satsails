import 'dart:async';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:vibration/vibration.dart';

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
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        color: Colors.black,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: SafeArea(
          child: PaymentTransactionOverlay(
            amount: amount,
            fiat: fiat,
            fiatAmount: fiatAmount,
            asset: asset,
            txid: txid,
            isLiquid: isLiquid,
            receiveAddress: receiveAddress,
            confirmationBlocks: confirmationBlocks,
          ),
        ),
      );
    },
  );
}

void showFullscreenExchangeModal({
  required BuildContext context,
  required SwapType swapType,
  required int amount, // Add amount as a required parameter
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        color: Colors.black,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: SafeArea(
          child: ExchangeTransactionOverlay(
            swapType: swapType,
            amount: amount,
          ),
        ),
      );
    },
  );
}

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
  ReceiveTransactionOverlayState createState() => ReceiveTransactionOverlayState();
}

class ReceiveTransactionOverlayState extends ConsumerState<ReceiveTransactionOverlay>
    with SingleTickerProviderStateMixin {
  bool checked = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize an animation controller for a "pop" effect
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    // Delay, then show the checkmark + vibrate
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        checked = true;
      });
      _animationController.forward();

      Vibration.hasVibrator().then((bool? hasVibrator) {
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 100);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String getFiatSymbol(String asset) {
    final upper = asset.toUpperCase();

    if (upper.contains('DEPIX')) {
      return 'R\$'; // Brazilian Real
    } else if (upper.contains('EUROX') || upper.contains('EURX')) {
      return '€';   // Euro
    } else if (upper.contains('USDT')) {
      return '\$';  // US Dollar
    }
    // Default fallback (could be $ or something else)
    return '\$';
  }


  /// Returns the full display text for the amount,
  /// e.g. "R\$100" for DEPIX, or "€50" for EUROX, etc.
  String get displayAmount {
    // If it's fiat, use [fiatAmount] and prefix the correct symbol
    if (widget.fiat && widget.fiatAmount != null && widget.asset != null) {
      final symbol = getFiatSymbol(widget.asset!);
      return '$symbol${widget.fiatAmount}';
    } else {
      // Otherwise, show the plain crypto or numeric value
      return widget.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetName = widget.asset ?? '';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: MSHCheckbox(
              size: 100,
              value: checked,
              colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                checkedColor: Colors.green,
                uncheckedColor: Colors.white,
                disabledColor: Colors.grey,
              ),
              style: MSHCheckboxStyle.stroke,
              duration: const Duration(milliseconds: 500),
              onChanged: (_) {},
            ),
          ),
          SizedBox(height: 20.h),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: checked ? Colors.greenAccent.withOpacity(0.3) : Colors.transparent,
                    width: checked ? 1.5 : 0,
                  ),
                ),
                child: getAssetImage(assetName, width: 100.sp, height: 100.sp),
              ),
              SizedBox(width: 8.h),
              Text(
                displayAmount, // The amount received (Fiat or Crypto)
                style: TextStyle(
                  fontSize: 48.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (assetName.isNotEmpty)
            AnimatedOpacity(
              opacity: checked ? 1.0 : 0.5, // Fade-in effect
              duration: const Duration(milliseconds: 500),
              child: Text(
                assetName,
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      color: checked ? Colors.green.withOpacity(0.4) : Colors.transparent,
                      blurRadius: 10,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
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

  /// Number of blocks the transaction is confirmed in.
  /// - null => "Instant"
  /// - 1    => "1 block"
  /// - else => "X blocks"
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
  bool checked = false;
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    );

    // Animate checkmark & optional vibration
    Future.delayed(const Duration(milliseconds: 500), () {
      animationController.forward();
      setState(() {
        checked = true;
      });

      Vibration.hasVibrator().then((bool? hasVibrator) {
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 100);
        }
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  /// Shorten a long string (like txid or address) to first 6...last 6
  String shortenString(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  /// Return R\$ for DEPIX, € for EUROX/EURX, $ for USDT
  String getFiatSymbol(String asset) {
    final upper = asset.toUpperCase();
    if (upper.contains('DEPIX')) {
      return 'R\$';
    } else if (upper.contains('EUROX') || upper.contains('EURX')) {
      return '€';
    } else if (upper.contains('USDT')) {
      return '\$';
    }
    // fallback if needed
    return '\$';
  }

  /// "Instant", "1 block" or "X blocks"
  String get confirmationText {
    final blocks = widget.confirmationBlocks;
    if (blocks == null) return 'Instant'.i18n;
    if (blocks == 1) return '1 block'.i18n;
    return '$blocks ${'blocks'.i18n}';
  }

  /// Determines how to display the amount
  String get displayAmount {
    final assetName = widget.asset ?? '';
    final upper = assetName.toUpperCase();

    // For certain "fiat-like" assets, interpret the amount as sat-based => /1e8
    if (upper.contains('DEPIX') ||
        upper.contains('EUROX') ||
        upper.contains('EURX') ||
        upper.contains('USDT')) {
      final symbol = getFiatSymbol(assetName);
      final parsed = double.tryParse(widget.amount) ?? 0;
      final isBtc = ref.read(settingsProvider).btcFormat == 'BTC';
      // 1) Convert from sat-based => double
      double converted = isBtc ? parsed : parsed / 1e8;
      // 2) Display up to 8 decimals, then strip trailing zeros
      String display = converted.toStringAsFixed(8);
      display = stripTrailingZeros(display);
      return '$symbol$display';
    }

    // Otherwise, fallback to your BTC format logic
    final btcFormat = ref.read(settingsProvider).btcFormat;
    if (widget.fiat && widget.fiatAmount != null) {
      return '${widget.fiatAmount} $assetName'.trim();
    } else {
      switch (btcFormat) {
        case 'sats':
          return '${widget.amount} sats';
        case 'BTC':
          return '${widget.amount} BTC';
        default:
          return widget.amount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arrow-down icon
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 16),

            // Main Card
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF212121),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkmark animation
                  ScaleTransition(
                    scale: scaleAnimation,
                    child: MSHCheckbox(
                      size: 80,
                      value: checked,
                      colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                        checkedColor: Colors.green,
                        uncheckedColor: Colors.white,
                        disabledColor: Colors.grey,
                      ),
                      style: MSHCheckboxStyle.stroke,
                      duration: const Duration(milliseconds: 500),
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bigger Icon + Asset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getAssetImage(widget.asset, height: 48.sp, width: 48.sp),
                      const SizedBox(width: 12),
                      if (widget.asset != null && widget.asset!.isNotEmpty)
                        Text(
                          widget.asset!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amount
                  _transactionDetailRow(
                    label: 'Amount'.i18n,
                    value: displayAmount,
                  ),

                  // Confirmation
                  _transactionDetailRow(
                    label: 'Confirmation'.i18n,
                    value: confirmationText,
                  ),

                  // Recipient
                  _transactionDetailRowMulti(
                    label: 'Recipient'.i18n,
                    value: widget.receiveAddress,
                    isAddressOrTxid: true,
                  ),

                  // Transaction ID
                  if (widget.txid != null && widget.txid!.isNotEmpty)
                    _transactionDetailRowMulti(
                      label: 'Transaction ID'.i18n,
                      value: widget.txid!,
                      isAddressOrTxid: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single-line row for label + value
  Widget _transactionDetailRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          // Value
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Multi-line row: label on top, value below in a subtle container
  Widget _transactionDetailRowMulti({
    required String label,
    required String value,
    bool isAddressOrTxid = false,
  }) {
    final displayValue = isAddressOrTxid ? shortenString(value) : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top label
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          // Value container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Value
                Expanded(
                  child: Text(
                    displayValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Copy button if address/txid
                if (isAddressOrTxid)
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showMessageSnackBar(
                        context: context,
                        message: 'Copied'.i18n,
                        error: false,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExchangeTransactionOverlay extends ConsumerStatefulWidget {
  final SwapType swapType;
  final int amount; // Amount is now an integer

  const ExchangeTransactionOverlay({
    super.key,
    required this.swapType,
    required this.amount,
  });

  @override
  _ExchangeTransactionOverlayState createState() => _ExchangeTransactionOverlayState();
}

class _ExchangeTransactionOverlayState extends ConsumerState<ExchangeTransactionOverlay> {
  @override
  Widget build(BuildContext context) {
    // Get the swap title and parse assets
    final title = _getSwapTitle(widget.swapType);
    final assets = _parseAssetsFromTitle(title.replaceAll('.i18n', ''));
    final fromAsset = assets['from']!;
    final toAsset = assets['to']!;

    // Format the amount based on the fromAsset type
    String formattedAmount;
    if (_isBitcoinLikeAsset(fromAsset)) {
      final denomination = ref
          .read(settingsProvider)
          .btcFormat;
      formattedAmount =
          btcInDenominationFormatted(widget.amount, denomination, true);
    } else {
      formattedAmount = fiatInDenominationFormatted(widget.amount);
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF212121),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF212121),
                    const Color(0xFF1A1A1A),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _transactionDetailRow(
                    label: 'Amount'.i18n,
                    value: formattedAmount,
                  ),
                  const SizedBox(height: 12),
                  if (fromAsset.isNotEmpty)
                    _transactionDetailRow(
                      label: 'From'.i18n,
                      value: fromAsset,
                      assetName: fromAsset,
                    ),
                  const SizedBox(height: 12),
                  if (toAsset.isNotEmpty)
                    _transactionDetailRow(
                      label: 'To'.i18n,
                      value: toAsset,
                      assetName: toAsset,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to determine the swap title
  String _getSwapTitle(SwapType swapType) {
    switch (swapType) {
      case SwapType.sideswapBtcToLbtc:
        return 'Bitcoin to Liquid Bitcoin Swap'.i18n;
      case SwapType.sideswapLbtcToBtc:
        return 'Liquid Bitcoin to Bitcoin Swap'.i18n;
      case SwapType.coinosLnToBTC:
        return 'Lightning to Bitcoin Swap'.i18n;
      case SwapType.coinosLnToLBTC:
        return 'Lightning to Liquid Bitcoin Swap'.i18n;
      case SwapType.coinosBtcToLn:
        return 'Bitcoin to Lightning Swap'.i18n;
      case SwapType.coinosLbtcToLn:
        return 'Liquid Bitcoin to Lightning Swap'.i18n;
      case SwapType.sideswapUsdtToLbtc:
        return 'USDT to Liquid Bitcoin Swap'.i18n;
      case SwapType.sideswapEuroxToLbtc:
        return 'EUROX to Liquid Bitcoin Swap'.i18n;
      case SwapType.sideswapDepixToLbtc:
        return 'DEPIX to Liquid Bitcoin Swap'.i18n;
      case SwapType.sideswapLbtcToUsdt:
        return 'Liquid Bitcoin to USDT Swap'.i18n;
      case SwapType.sideswapLbtcToEurox:
        return 'Liquid Bitcoin to EUROX Swap'.i18n;
      case SwapType.sideswapLbtcToDepix:
        return 'Liquid Bitcoin to DEPIX Swap'.i18n;
      default:
        return 'Exchange Transaction'.i18n;
    }
  }

  // Helper method to parse assets from the title
  Map<String, String> _parseAssetsFromTitle(String title) {
    final parts = title.replaceAll(' Swap', '').split(' to ');
    if (parts.length == 2) {
      return {
        'from': parts[0],
        'to': parts[1],
      };
    }
    return {'from': '', 'to': ''};
  }

  // Helper method to check if an asset is Bitcoin-like (Liquid Bitcoin or Lightning)
  bool _isBitcoinLikeAsset(String asset) {
    return asset == 'Liquid Bitcoin' || asset == 'Lightning';
  }

  // Helper method to build transaction detail rows
  Widget _transactionDetailRow({
    required String label,
    required String value,
    String? assetName,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              if (assetName != null) ...[
                getAssetImage(assetName, width: 28.sp, height: 28.sp),
                SizedBox(width: 12.w),
              ],
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}