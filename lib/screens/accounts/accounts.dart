import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:satsails/models/balance_model.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/liquid_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/providers/transaction_data_provider.dart';
import 'package:satsails/screens/shared/copy_text.dart';
import 'package:satsails/screens/shared/qr_code.dart';

class Accounts extends StatelessWidget {
  const Accounts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Account Management'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: screenWidth * 0.02),
            const Text(
              'Savings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenWidth * 0.02),
            Consumer(
              builder: (context, ref, _) {
                final format = ref.watch(settingsProvider).btcFormat;
                final currency = ref.watch(settingsProvider).currency;
                final balanceProvider = ref.watch(balanceNotifierProvider);
                final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(format));
                final bitcoinAddress = ref.watch(bitcoinAddressProvider.future);
                final bitcoinInCurrency = ref.watch(currentBitcoinPriceInCurrencyProvider(CurrencyParams(ref.watch(settingsProvider).currency, balanceProvider.btcBalance))).toStringAsFixed(2);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      children: [
                        _buildListTile('Bitcoin', btcBalanceInFormat, const Icon(LineAwesome.bitcoin, color: Colors.white), context, bitcoinAddress, bitcoinInCurrency, currency, format),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: screenWidth * 0.02),
            const Text(
              'Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenWidth * 0.02),
            Consumer(
              builder: (context, ref, _) {
                final format = ref.watch(settingsProvider).btcFormat;
                final currency = ref.watch(settingsProvider).currency;
                final balanceProvider = ref.watch(balanceNotifierProvider);
                final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(format));
                final balance = ref.watch(balanceNotifierProvider);
                final liquid = ref.watch(liquidAddressProvider.future);
                final liquidInCurrency = ref.watch(currentBitcoinPriceInCurrencyProvider(CurrencyParams(ref.watch(settingsProvider).currency, balanceProvider.liquidBalance))).toStringAsFixed(2);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.deepPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      children: [
                        _buildListTile('Liquid', liquidBalanceInFormat, const Icon(LineAwesome.bitcoin, color: Colors.white), context, liquid, liquidInCurrency, currency, format),
                        _buildListTile('Lightning', '', const Icon(LineAwesome.bolt_solid, color: Colors.white), context, liquid, '', '', ''),
                        _buildListTile('Real', balance.brlBalance.toString(), Flag(Flags.brazil), context, liquid, '', '', ''),
                        _buildListTile('Dollar', balance.usdBalance.toString(), Flag(Flags.united_states_of_america), context, liquid, '', '', ''),
                        _buildListTile('Euro', balance.eurBalance.toString(), Flag(Flags.european_union), context, liquid, '', '', ''),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String trailing, icon, BuildContext context, bitcoin, String balance, String denomination, String format) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: icon,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '$title  ', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              TextSpan(text: balance, style: const TextStyle(fontSize: 16, color: Colors.white)),
              TextSpan(text: ' $denomination', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
        trailing: Text(trailing + ' '+ format, style: const TextStyle(fontSize: 16, color: Colors.white)),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  _receivePayment(context, bitcoin);
                },
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
              TextButton(
                onPressed: () {Navigator.pushNamed(context, '/pay');},
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }



  void _receivePayment(BuildContext context, dynamic bitcoin) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        return FutureBuilder<dynamic>(
          future: bitcoin,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final String address = snapshot.data is String ? snapshot.data : snapshot.data.address;
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Receive',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildQrCode(address, context),
                        SizedBox(height: screenSize.height * 0.02),
                        buildAddressText(address, context),
                        SizedBox(height: screenSize.height * 0.02),
                      ],
                    );
                  },
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
}
