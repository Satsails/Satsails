import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:go_router/go_router.dart';

class BalanceCard extends ConsumerWidget {
  final String assetName;
  final Color color;
  final String networkFilter;

  const BalanceCard({
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

    return Container(
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
            child: InkWell(
              onTap: () {
                context.pushNamed('analytics');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF212121),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'analytics',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
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