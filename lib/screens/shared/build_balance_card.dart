import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/screens/shared/denominatino_change_modal_bottom_sheet.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';

final selectedButtonProvider = StateProvider<String>((ref) => 'currency');

final isBalanceVisibleProvider = StateProvider<bool>((ref) => false);

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
      margin: EdgeInsets.symmetric(horizontal: cardMargin),
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
          padding: EdgeInsets.symmetric(vertical:  MediaQuery.of(context).size.height < 800 ? cardPadding / 2 : cardPadding, horizontal: cardPadding / 2),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Total balance:'.i18n(ref), style: TextStyle(fontSize: titleFontSize * 0.7, color: Colors.black)),
                        _buildVisibilityToggleIcon(context, ref),
                      ],
                    ),
                    _buildPricePercentageChangeTicker(context, ref),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildBalanceConsumer(ref, titleFontSize, balanceProviderName, 'btcFormat', FontWeight.bold),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildBalanceConsumer(ref, subtitleFontSize, balanceInFiatName, 'currency', FontWeight.normal),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _showDenominationChangeModalBottomSheet(context, ref);
                  },
                  child: Text('Change'.i18n(ref), style: const TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showDenominationChangeModalBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    builder: (BuildContext context) {
      return DenominationChangeModalBottomSheet(settingsNotifier: ref.read(settingsProvider.notifier));
    },
  );
}

Widget _buildPricePercentageChangeTicker(BuildContext context, WidgetRef ref) {
  final coinGeckoData = ref.watch(coinGeckoBitcoinChange);
  final screenHeight = MediaQuery.of(context).size.height;
  final titleFontSize = screenHeight * 0.03;
  final containerHeight = titleFontSize * 1.5; // Define a fixed height for the container

  return SizedBox(
    height: containerHeight,
    child: coinGeckoData.when(
      data: (data) {
        IconData? icon;
        Color color;
        String displayText = '${data.abs().toStringAsFixed(2)}%';

        if (displayText == '-0.00%' || displayText == '0.00%') {
          displayText = '0%';
          icon = null;
          color = const Color(0xFF00752B);
        } else if (data > 0) {
          icon = Icons.arrow_upward;
          color = const Color(0xFF00752B);
        } else if (data < 0) {
          icon = Icons.arrow_downward;
          color = Colors.red;
        } else {
          icon = null;
          color = const Color(0xFF00752B);
        }

        return Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: titleFontSize * 0.5, color: Colors.black),
              SizedBox(width: icon != null ? 5.0 : 0), // Add space between icon and text if icon is present
              Text(
                displayText,
                style: TextStyle(fontSize: titleFontSize * 0.5, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
      loading: () {
        return LoadingAnimationWidget.prograssiveDots(size: titleFontSize * 0.5, color: Colors.black);
      },
      error: (error, stack) {
        return Container(
          height: containerHeight,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              'Error',
              style: TextStyle(color: Colors.black, fontSize: titleFontSize * 0.5),
            ),
          ),
        );
      },
    ),
  );
}


Widget _buildVisibilityToggleIcon(BuildContext context, WidgetRef ref) {
  final isBalanceVisible = ref.watch(isBalanceVisibleProvider);

  return IconButton(
    icon: Icon(
      isBalanceVisible ? Icons.visibility : Icons.visibility_off,
      color: Colors.black,
    ),
    onPressed: () {
      ref.read(isBalanceVisibleProvider.notifier).state = !isBalanceVisible;
    },
  );
}

Widget _buildBalanceConsumer(WidgetRef ref, double fontSize, String providerName, String settingsName, FontWeight font) {
  final settings = ref.watch(settingsProvider);
  final isBalanceVisible = ref.watch(isBalanceVisibleProvider);

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

  return SizedBox(
    height: fontSize * 1.5,
    child: Text(
      isBalanceVisible ? '$balance $settingsValue' : '******',
      style: TextStyle(fontSize: fontSize, color: Colors.black, fontWeight: font),
    ),
  );
}
