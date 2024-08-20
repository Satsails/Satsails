import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';

Widget buildBalanceCard(BuildContext context, WidgetRef ref, String balanceProviderName, String balanceInFiatName) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final cardMargin = screenWidth * 0.05;
  final cardPadding = screenWidth * 0.04;
  final titleFontSize = screenHeight * 0.03;
  final subtitleFontSize = screenHeight * 0.02;

  return SizedBox(
    width: double.infinity,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 10,
      margin: EdgeInsets.all(cardMargin),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: cardPadding, horizontal: cardPadding / 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total balance'.i18n(ref), style: TextStyle(fontSize: titleFontSize * 0.7, color: Colors.white), textAlign: TextAlign.center),
                    _buildPricePercentageChangeTicker(context, ref)
                  ],
                ),
              ),
              _buildBalanceConsumer(ref, titleFontSize, balanceProviderName, 'btcFormat'),
              SizedBox(height: screenHeight * 0.01),
              Text('or'.i18n(ref), style: const TextStyle(fontSize: 14, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: screenHeight * 0.01),
              _buildBalanceConsumer(ref, subtitleFontSize, balanceInFiatName, 'currency'),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildPricePercentageChangeTicker(BuildContext context, WidgetRef ref) {
  final coinGeckoData = ref.watch(coinGeckoDataProvider);
  final screenHeight = MediaQuery.of(context).size.height;
  final titleFontSize = screenHeight * 0.03;

  return coinGeckoData.when(
    data: (data) {
      IconData? icon;
      Color color;
      String displayText = '${data.abs().toStringAsFixed(2)}%';

      if (displayText == '-0.00%' || displayText == '0.00%') {
        displayText = '0%';
        icon = null;
        color = Colors.green;
      } else if (data > 0) {
        icon = Icons.arrow_upward;
        color = Colors.green;
      } else if (data < 0) {
        icon = Icons.arrow_downward;
        color = Colors.red;
      } else {
        icon = null;
        color = Colors.green;
      }

      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: titleFontSize * 0.7, color: Colors.white),
            SizedBox(width: icon != null ? 5.0 : 0), // Add space between icon and text if icon is present
            Text(
              displayText,
              style: TextStyle(fontSize: titleFontSize * 0.7, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
    loading: () {
      return Center(
        child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize * 0.7, color: Colors.white),
      );
    },
    error: (error, stack) {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          'Error',
          style: TextStyle(color: Colors.white, fontSize: titleFontSize * 0.7),
        ),
      );
    },
  );
}



Widget _buildBalanceConsumer(WidgetRef ref, double fontSize, String providerName, String settingsName) {
  final settings = ref.watch(settingsProvider);
  final initializeBalance = ref.watch(initializeBalanceProvider);
  String balance;

  switch (providerName) {
    case 'totalBalanceInDenominationProvider':
      balance = ref.watch(totalBalanceInDenominationProvider(settings.btcFormat));
      break;
    case 'totalBalanceInFiatProvider':
      balance = ref.watch(totalBalanceInFiatProvider(settings.currency));
      break;
    default:
      throw Exception('Invalid providerName: $providerName');
  }

  String settingsValue;
  switch (settingsName) {
    case 'btcFormat':
      settingsValue = settings.btcFormat;
      break;
    case 'currency':
      settingsValue = settings.currency;
      break;
    default:
      throw Exception('Invalid settingsName: $settingsName');
  }

  return initializeBalance.when(
    data: (_) => SizedBox(height: fontSize * 1.5, child: Text('$balance $settingsValue', style: TextStyle(fontSize: fontSize, color: Colors.white), textAlign: TextAlign.center)),
    loading: () => SizedBox(height: fontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: fontSize, color: Colors.white)),
    error: (error, stack) => SizedBox(height: fontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: fontSize)))),
  );
}