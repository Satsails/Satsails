import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/settings_provider.dart';

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
              const Text('Total balance', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
              _buildBalanceConsumer(ref, titleFontSize, balanceProviderName, 'btcFormat'),
              SizedBox(height: screenHeight * 0.01),
              const Text('or', style: TextStyle(fontSize: 14, color: Colors.white), textAlign: TextAlign.center),
              SizedBox(height: screenHeight * 0.01),
              _buildBalanceConsumer(ref, subtitleFontSize, balanceInFiatName, 'currency'),
            ],
          ),
        ),
      ),
    ),
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

  var settingsValue;
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