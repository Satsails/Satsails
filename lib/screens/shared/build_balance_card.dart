import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';

class BalanceCard extends ConsumerWidget {
  final String assetName;
  final Color color;
  final String networkFilter;
  final GlobalKey _cardKey = GlobalKey();

  BalanceCard({
    required this.assetName,
    required this.color,
    required this.networkFilter,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletBalance = ref.watch(balanceNotifierProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final conversions = ref.watch(currencyNotifierProvider);

    String nativeBalance = '0';
    String equivalentBalance = '0 USD';
    Widget? iconWidget;

    if (assetName == 'Bitcoin') {
      int balanceInSats;
      switch (networkFilter) {
        case 'Bitcoin network':
          balanceInSats = walletBalance.btcBalance ?? 0;
          break;
        case 'Liquid network':
          balanceInSats = walletBalance.liquidBalance ?? 0;
          break;
        case 'Lightning network':
          balanceInSats = walletBalance.lightningBalance ?? 0;
          break;
        default:
          balanceInSats = 0;
      }
      nativeBalance = btcInDenominationFormatted(balanceInSats, btcFormat);
      final balanceInBtc = balanceInSats / 100000000;
      final equivalent = balanceInBtc * conversions.btcToUsd;
      equivalentBalance = '${equivalent.toStringAsFixed(2)} USD';
    } else {
      String iconPath;
      String label;
      switch (assetName) {
        case 'Depix':
          iconPath = 'lib/assets/depix.png';
          label = 'Depix';
          final brlBalance = (walletBalance.brlBalance) / 100;
          nativeBalance = '${brlBalance.toStringAsFixed(2)} BRL';
          final balanceInBtc = brlBalance * conversions.brlToBtc;
          final equivalent = balanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${equivalent.toStringAsFixed(2)} USD';
          break;
        case 'USDT':
          iconPath = 'lib/assets/tether.png';
          label = 'USDT';
          final usdBalance = (walletBalance.usdBalance) / 100;
          nativeBalance = '${usdBalance.toStringAsFixed(2)} USD';
          equivalentBalance = nativeBalance;
          break;
        case 'EURx':
          iconPath = 'lib/assets/eurx.png';
          label = 'EURx';
          final eurBalance = (walletBalance.eurBalance) / 100;
          nativeBalance = '${eurBalance.toStringAsFixed(2)} EUR';
          final balanceInBtc = eurBalance * conversions.eurToBtc;
          final equivalent = balanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${equivalent.toStringAsFixed(2)} USD';
          break;
        default:
          iconPath = '';
          label = '';
          nativeBalance = '0';
          equivalentBalance = '0 USD';
      }
      iconWidget = _buildAssetItem(assetName, iconPath, label, isSelected: true);
    }

    final sendReceiveButtons = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              // TODO: Implement send functionality
            },
            icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            constraints: const BoxConstraints(),
          ),
          const VerticalDivider(color: Colors.white, thickness: 1),
          IconButton(
            onPressed: () {
              // TODO: Implement receive functionality
            },
            icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );

    final screenSize = MediaQuery.of(context).size;

    return Container(
      key: _cardKey,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.none,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Balance: $nativeBalance',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Equivalent: $equivalentBalance',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Total: 20', // TODO: Make this dynamic if needed
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {
                final RenderBox renderBox = _cardKey.currentContext!.findRenderObject() as RenderBox;
                final size = renderBox.size;
                final position = renderBox.localToGlobal(Offset.zero);

                late OverlayEntry overlayEntry;
                overlayEntry = OverlayEntry(
                  builder: (context) => ExpandedBalanceCard(
                    initialLeft: position.dx,
                    initialTop: position.dy,
                    initialWidth: size.width,
                    initialHeight: size.height,
                    screenWidth: screenSize.width,
                    screenHeight: screenSize.height,
                    assetName: assetName,
                    color: color,
                    nativeBalance: nativeBalance,
                    equivalentBalance: equivalentBalance,
                    onClose: () => overlayEntry.remove(), // Remove the overlay when closed
                  ),
                );
                Overlay.of(context).insert(overlayEntry);
              },
            ),
          ),
          Positioned(
            bottom: -20,
            child: sendReceiveButtons,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItem(String key, String iconPath, String label,
      {VoidCallback? onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedBalanceCard extends StatefulWidget {
  final double initialLeft;
  final double initialTop;
  final double initialWidth;
  final double initialHeight;
  final double screenWidth;
  final double screenHeight;
  final String assetName;
  final Color color;
  final String nativeBalance;
  final String equivalentBalance;
  final VoidCallback onClose;

  const ExpandedBalanceCard({
    required this.initialLeft,
    required this.initialTop,
    required this.initialWidth,
    required this.initialHeight,
    required this.screenWidth,
    required this.screenHeight,
    required this.assetName,
    required this.color,
    required this.nativeBalance,
    required this.equivalentBalance,
    required this.onClose,
    super.key,
  });

  @override
  _ExpandedBalanceCardState createState() => _ExpandedBalanceCardState();
}

class _ExpandedBalanceCardState extends State<ExpandedBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _leftAnimation;
  late Animation<double> _topAnimation;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _leftAnimation = Tween<double>(begin: widget.initialLeft, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _topAnimation = Tween<double>(begin: widget.initialTop, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _widthAnimation = Tween<double>(begin: widget.initialWidth, end: widget.screenWidth)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _heightAnimation = Tween<double>(begin: widget.initialHeight, end: widget.screenHeight)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onClose();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _leftAnimation.value,
          top: _topAnimation.value,
          width: _widthAnimation.value,
          height: _heightAnimation.value,
          child: Container(
            color: widget.color,
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      _controller.reverse();
                    },
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Balance: ${widget.nativeBalance}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Equivalent: ${widget.equivalentBalance}',
                        style: const TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'grown',
                        style: TextStyle(fontSize: 36, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF212121),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              // TODO: Implement new action
                            },
                            icon: const Icon(Icons.add, color: Colors.white, size: 32),
                          ),
                          const VerticalDivider(color: Colors.white, thickness: 1),
                          IconButton(
                            onPressed: () {
                              // TODO: Implement new action
                            },
                            icon: const Icon(Icons.remove, color: Colors.white, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}