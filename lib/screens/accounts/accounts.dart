import 'package:Satsails/assets/lbtc_icon.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/receive/components/custodial_lightning_widget.dart';
import 'package:Satsails/screens/shared/bottom_navigation_bar.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/screens/pay/pay.dart';

class Accounts extends ConsumerWidget {
  const Accounts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: ref.watch(navigationProvider),
        context: context,
        onTap: (int index) {
          ref.read(navigationProvider.notifier).state = index;
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenWidth * 0.02),
                Text(
                  'Bitcoin',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: screenWidth * 0.02),
                Consumer(
                  builder: (context, ref, _) {
                    final format = ref.watch(settingsProvider).btcFormat;
                    final currency = ref.watch(settingsProvider).currency;
                    final balanceProvider = ref.watch(balanceNotifierProvider);
                    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(format));
                    final bitcoinAddress = ref.watch(bitcoinAddressProvider.future);
                    final bitcoinInCurrency = ref.watch(currentBitcoinPriceInCurrencyProvider(
                      CurrencyParams(ref.watch(settingsProvider).currency, balanceProvider.btcBalance),
                    )).toStringAsFixed(2);
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFFF9800)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            _buildListTile(
                              'Bitcoin',
                              btcBalanceInFormat,
                              const Icon(Icons.currency_bitcoin, color: Colors.white),
                              context,
                              bitcoinAddress,
                              bitcoinInCurrency,
                              currency,
                              format,
                              ref,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenWidth * 0.02),

                // Always show the Lightning card
                Text(
                  'Lightning',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: screenWidth * 0.02),
                Consumer(
                  builder: (context, ref, _) {
                    final hasLightning = ref.watch(coinosLnProvider).token.isNotEmpty;
                    final format = ref.watch(settingsProvider).btcFormat;
                    String? coinosBalanceInCurrency;
                    String lightningBalanceInFormat = '';
                    if (hasLightning) {
                      final coinosBalance = ref.watch(balanceNotifierProvider).lightningBalance;
                      coinosBalanceInCurrency = ref.watch(currentBitcoinPriceInCurrencyProvider(
                        CurrencyParams(ref.watch(settingsProvider).currency, coinosBalance!),
                      )).toStringAsFixed(2);

                      lightningBalanceInFormat = btcInDenominationFormatted(coinosBalance!, format);
                    }
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF7931A), Color(0xFFFFA500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            _buildListTile(
                              'Lightning',
                              lightningBalanceInFormat,
                              const Icon(Icons.flash_on, color: Colors.white),
                              context,
                              null,
                              hasLightning ? coinosBalanceInCurrency! : '',
                              hasLightning ? ref.watch(settingsProvider).currency : '',
                              format,
                              ref,
                              isLightning: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  'Liquid Bitcoin',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: screenWidth * 0.02),
                Consumer(
                  builder: (context, ref, _) {
                    final format = ref.watch(settingsProvider).btcFormat;
                    final currency = ref.watch(settingsProvider).currency;
                    final balanceProvider = ref.watch(balanceNotifierProvider);
                    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(format));
                    final liquid = ref.watch(liquidAddressProvider.future);
                    final liquidInCurrency = ref.watch(currentBitcoinPriceInCurrencyProvider(
                      CurrencyParams(ref.watch(settingsProvider).currency, balanceProvider.liquidBalance),
                    )).toStringAsFixed(2);
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF288BEC), Color(0xFF288BEC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            _buildListTile(
                              'Liquid'.i18n,
                              liquidBalanceInFormat,
                              const Icon(Lbtc_icon.lbtc_icon, color: Colors.white),
                              context,
                              liquid,
                              liquidInCurrency,
                              currency,
                              format,
                              ref,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  'Stable'.i18n,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: screenWidth * 0.02),
                Consumer(
                  builder: (context, ref, _) {
                    final balance = ref.watch(balanceNotifierProvider);
                    final liquid = ref.watch(liquidAddressProvider.future);
                    return Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF009B3A), Color(0xFF009B3A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                _buildListTile(
                                  'Depix',
                                  fiatInDenominationFormatted(balance.brlBalance),
                                  Image.asset(
                                    'lib/assets/depix.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  context,
                                  liquid,
                                  '',
                                  '',
                                  '',
                                  ref,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF008000), Color(0xFF008000)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                _buildListTile(
                                  'USDt',
                                  fiatInDenominationFormatted(balance.usdBalance),
                                  Image.asset(
                                    'lib/assets/tether.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  context,
                                  liquid,
                                  '',
                                  '',
                                  '',
                                  ref,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF003399), Color(0xFF003399)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                _buildListTile(
                                  'EURx',
                                  fiatInDenominationFormatted(balance.eurBalance),
                                  Image.asset(
                                    'lib/assets/eurx.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  context,
                                  liquid,
                                  '',
                                  '',
                                  '',
                                  ref,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
      String title,
      String trailing,
      Widget icon,
      BuildContext context,
      dynamic addressFuture,
      String balance,
      String denomination,
      String format,
      WidgetRef ref, {
        bool isLightning = false,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    bool isBitcoin = title == 'Bitcoin';

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: icon,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (balance.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: screenWidth * 0.02),
                child: Row(
                  children: [
                    Text(
                      balance,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' $denomination',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Text(
          trailing.isNotEmpty ? '$trailing $format' : '',
          style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
        ),
        initiallyExpanded: isBitcoin, // Set this to true for the Bitcoin card
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: screenWidth * 0.04,
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (isLightning) {
                      _receiveLightningPayment(context, ref);
                    } else if (title == 'Bitcoin') {
                      _showBitcoinAddress(context, addressFuture, ref);
                    } else if (title == 'Liquid'.i18n) {
                      _showLiquidAddress(context, addressFuture, ref);
                    } else {
                      _showLiquidAddress(context, addressFuture, ref);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.white),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('Receive'.i18n,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Open the Pay modal sheet when "Send" is clicked
                    _showPayModalSheet(context, ref);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.white),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('Send'.i18n,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBitcoinAddress(
      BuildContext context, dynamic bitcoin, WidgetRef ref) {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        return FutureBuilder<dynamic>(
          future: bitcoin,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                    size: 200, color: Colors.orange),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final String address = snapshot.data is String
                  ? snapshot.data
                  : snapshot.data.confidential;
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Center(
                      child: Padding(
                        padding:
                        EdgeInsets.only(top: screenSize.height * 0.02),
                        child: Text(
                          'Receive'.i18n,
                          style: TextStyle(
                              fontSize: screenSize.width * 0.06,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: buildQrCode(address, context),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    buildAddressText(address, context, ref),
                    SizedBox(height: screenSize.height * 0.02),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No data'));
            }
          },
        );
      },
    );
  }

  void _showLiquidAddress(BuildContext context, dynamic liquid, WidgetRef ref) {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        return FutureBuilder<dynamic>(
          future: liquid,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                    size: 200, color: Colors.orange),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final String address = snapshot.data is String
                  ? snapshot.data
                  : snapshot.data.confidential;
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Center(
                      child: Padding(
                        padding:
                        EdgeInsets.only(top: screenSize.height * 0.02),
                        child: Text(
                          'Receive'.i18n,
                          style: TextStyle(
                              fontSize: screenSize.width * 0.06,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: buildQrCode(address, context),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    buildAddressText(address, context, ref),
                    SizedBox(height: screenSize.height * 0.02),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No data'));
            }
          },
        );
      },
    );
  }

  void _receiveLightningPayment(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.2,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: KeyboardDismissOnTap(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16.0),
                child: const CustodialLightningWidget(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPayModalSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Pay();
          },
        );
      },
    );
  }
}
