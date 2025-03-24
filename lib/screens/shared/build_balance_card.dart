import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';

class BalanceCard extends ConsumerStatefulWidget {
  final String assetName;
  final Color color;

  const BalanceCard({required this.assetName, required this.color, super.key});

  @override
  _BalanceCardState createState() => _BalanceCardState();
}

class _BalanceCardState extends ConsumerState<BalanceCard> {
  String _selectedNetwork = 'BTC'; // Default to Bitcoin network for Bitcoin card

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(balanceNotifierProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final conversions = ref.watch(currencyNotifierProvider);

    // Variables to hold balance and icon widget
    String nativeBalance = '0';
    String equivalentBalance = '0 USD';
    String totalBalance = '0 USD'; // For Bitcoin card
    Widget iconWidget;

    // Logic for balance calculation and icon widget
    if (widget.assetName == 'Bitcoin') {

      switch (_selectedNetwork) {
        case 'BTC':
          nativeBalance = btcInDenominationFormatted(walletBalance.btcBalance ?? 0, btcFormat);
          final btcBalanceInBtc = (walletBalance.btcBalance ?? 0) / 100000000;
          final btcEquivalent = btcBalanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${btcEquivalent.toStringAsFixed(2)} USD';
          break;
        case 'Lightning':
          nativeBalance = btcInDenominationFormatted(walletBalance.lightningBalance ?? 0, btcFormat);
          final lightningBalanceInBtc = (walletBalance.lightningBalance ?? 0) / 100000000;
          final lightningEquivalent = lightningBalanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${lightningEquivalent.toStringAsFixed(2)} USD';
          break;
        case 'LBTC':
          nativeBalance = btcInDenominationFormatted(walletBalance.liquidBalance ?? 0, btcFormat);
          final liquidBalanceInBtc = (walletBalance.liquidBalance ?? 0) / 100000000;
          final liquidEquivalent = liquidBalanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${liquidEquivalent.toStringAsFixed(2)} USD';
          break;
      }

      final btcBalanceInBtc = (walletBalance.btcBalance ?? 0) / 100000000;
      final lightningBalanceInBtc = (walletBalance.lightningBalance ?? 0) / 100000000;
      final liquidBalanceInBtc = (walletBalance.liquidBalance ?? 0) / 100000000;
      final totalBtc = btcBalanceInBtc + lightningBalanceInBtc + liquidBalanceInBtc;
      final totalUsd = totalBtc * conversions.btcToUsd;
      totalBalance = '${totalUsd.toStringAsFixed(2)} USD';
    } else {
      String iconPath;
      String label;
      switch (widget.assetName) {
        case 'Depix':
          iconPath = 'lib/assets/depix.png';
          label = 'Depix';
          final brlBalance = (walletBalance.brlBalance ?? 0) / 100;
          nativeBalance = '${brlBalance.toStringAsFixed(2)} BRL';
          final balanceInBtc = brlBalance * conversions.brlToBtc;
          final equivalent = balanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${equivalent.toStringAsFixed(2)} USD';
          break;
        case 'USDT':
          iconPath = 'lib/assets/tether.png';
          label = 'USDT';
          final usdBalance = (walletBalance.usdBalance ?? 0) / 100;
          nativeBalance = '${usdBalance.toStringAsFixed(2)} USD';
          equivalentBalance = nativeBalance;
          break;
        case 'EURx':
          iconPath = 'lib/assets/eurx.png';
          label = 'EURx';
          final eurBalance = (walletBalance.eurBalance ?? 0) / 100;
          nativeBalance = '${eurBalance.toStringAsFixed(2)} EUR';
          final balanceInBtc = eurBalance * conversions.eurToBtc;
          final equivalent = balanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${equivalent.toStringAsFixed(2)} USD';
          break;
        default:
          iconPath = '';
          label = '';
      }
      iconWidget = _buildAssetItem(widget.assetName, iconPath, label, isSelected: true);
    }

    // Send and Receive buttons
    final sendReceiveButtons = Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              // TODO: Implement send functionality
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Send',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          VerticalDivider(color: Colors.white.withOpacity(0.2), thickness: 1),
          TextButton(
            onPressed: () {
              // TODO: Implement receive functionality
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Receive',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    // Card layout
    return Container(
      decoration: BoxDecoration(
        color: widget.color, // Solid color instead of gradient
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Balance: $nativeBalance',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                'Equivalent: $equivalentBalance',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              Spacer(),
              Center(child: sendReceiveButtons),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build asset items with name above icon
  Widget _buildAssetItem(String key, String iconPath, String label, {VoidCallback? onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF212121),
          borderRadius: BorderRadius.circular(8), // Optional: adds rounded corners
        ),
        padding: const EdgeInsets.all(8), // Adds padding inside the box
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