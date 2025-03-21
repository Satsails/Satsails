import 'package:Satsails/models/currency_conversions.dart';
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
    final settings = ref.watch(settingsProvider);
    final conversions = ref.watch(currencyNotifierProvider);

    // Variables to hold balance and icon widget
    String nativeBalance = '0';
    String equivalentBalance = '0 USD'; // Default to USD for all cards
    String totalBalance = '0 USD'; // For Bitcoin card
    Widget iconWidget;

    if (widget.assetName == 'Bitcoin') {
      // Bitcoin card with three network icons in a column
      iconWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNetworkItem('BTC', 'lib/assets/bitcoin-logo.png', 'Bitcoin Network'),
          const SizedBox(height: 8),
          _buildNetworkItem('LBTC', 'lib/assets/l-btc.png', 'Liquid Network'),
          const SizedBox(height: 8),
          _buildNetworkItem('Lightning', 'lib/assets/Bitcoin_lightning_logo.png', 'Lightning Network'),
        ],
      );

      // Calculate balance based on selected network
      switch (_selectedNetwork) {
        case 'BTC':
          nativeBalance = walletBalance.btcBalanceInDenominationFormatted(settings.btcFormat);
          final btcBalanceInBtc = (walletBalance.btcBalance ?? 0) / 100000000;
          final btcEquivalent = btcBalanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${btcEquivalent.toStringAsFixed(2)} USD';
          break;
        case 'Lightning':
          nativeBalance = walletBalance.lightningBalanceInDenominationFormatted('sats');
          final lightningBalanceInBtc = (walletBalance.lightningBalance ?? 0) / 100000000;
          final lightningEquivalent = lightningBalanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${lightningEquivalent.toStringAsFixed(2)} USD';
          break;
        case 'LBTC':
          nativeBalance = walletBalance.liquidBalanceInDenominationFormatted(settings.btcFormat);
          final liquidBalanceInBtc = (walletBalance.liquidBalance ?? 0) / 100000000;
          final liquidEquivalent = liquidBalanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${liquidEquivalent.toStringAsFixed(2)} USD';
          break;
      }

      // Calculate total balance across all networks in USD
      final btcBalanceInBtc = (walletBalance.btcBalance ?? 0) / 100000000;
      final lightningBalanceInBtc = (walletBalance.lightningBalance ?? 0) / 100000000;
      final liquidBalanceInBtc = (walletBalance.liquidBalance ?? 0) / 100000000;
      final totalBtc = btcBalanceInBtc + lightningBalanceInBtc + liquidBalanceInBtc;
      final totalUsd = totalBtc * conversions.btcToUsd;
      totalBalance = '${totalUsd.toStringAsFixed(2)} USD';
    } else {
      // Single-icon cards (Depix, USDT, EURx)
      String iconPath;
      String label;
      switch (widget.assetName) {
        case 'Depix':
          iconPath = 'lib/assets/depix.png';
          label = 'Liquid Depix';
          final brlBalance = (walletBalance.brlBalance ?? 0) / 100;
          nativeBalance = '${brlBalance.toStringAsFixed(2)} BRL';
          final balanceInBtc = brlBalance * conversions.brlToBtc;
          final equivalent = balanceInBtc * conversions.btcToUsd;
          equivalentBalance = '${equivalent.toStringAsFixed(2)} USD';
          break;
        case 'USDT':
          iconPath = 'lib/assets/tether.png';
          label = 'Liquid USDT';
          final usdBalance = (walletBalance.usdBalance ?? 0) / 100;
          nativeBalance = '${usdBalance.toStringAsFixed(2)} USD';
          equivalentBalance = nativeBalance; // Already in USD
          break;
        case 'EURx':
          iconPath = 'lib/assets/eurx.png';
          label = 'Liquid EURx';
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
      iconWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 32, height: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      );
    }

    // Send and Receive buttons
    final sendReceiveButtons = Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward, color: Colors.white),
            onPressed: () {
              // TODO: Implement send functionality
            },
          ),
          Container(
            width: 1,
            height: 24,
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward, color: Colors.white),
            onPressed: () {
              // TODO: Implement receive functionality
            },
          ),
        ],
      ),
    );

    return Card(
      color: widget.color,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.assetName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Balance: $nativeBalance',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      'Equivalent: $equivalentBalance',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    if (widget.assetName == 'Bitcoin') ...[
                      const SizedBox(height: 8),
                      Text(
                        'Total: $totalBalance',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ],
                ),
                iconWidget,
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: sendReceiveButtons,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build clickable network items for Bitcoin card
  Widget _buildNetworkItem(String network, String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNetwork = network;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _selectedNetwork == network ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Image.asset(iconPath, width: 32, height: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}