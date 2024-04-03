import 'package:flutter/material.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/navigation_provider.dart';
import 'package:satsails/screens/accounts/accounts.dart';
import 'package:satsails/screens/shared/bottom_navigation_bar.dart';
import 'package:card_loading/card_loading.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  Future<dynamic> getBtcPrice(WidgetRef ref) async {
    final currency = ref
        .watch(settingsProvider)
        .currency;
    final fx = Forex();
    final result = await fx.getCurrencyConverted(
        sourceCurrency: 'BTC', destinationCurrency: currency, sourceAmount: 1);
    final error = fx.getErrorNotifier.value;

    if (error != null) {
      return "Error fetching prices";
    }
    return '$result $currency';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, ref),
      body: SafeArea(child: _buildBody(context, ref)),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(child: _buildMiddleSection(context, ref)),
        _buildActionButtons(context),
        CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          context: context,
          onTap: (int index) {
            ref
                .read(navigationProvider.notifier)
                .state = index;
          },
        ),
      ],
    );
  }

  Widget _buildDiagram(WidgetRef ref, BuildContext context) {
    final balance = ref.watch(balanceNotifierProvider.notifier);

    return SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.3,
      child: balance.state.btcBalance == 0
          ? PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 1,
              title: '',
              radius: 60,
              color: Colors.grey,
            ),
          ],
          borderData: FlBorderData(
            show: false,
          ),
        ),
      )
          : PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: balance.state.btcBalance.toDouble() +
                  balance.state.liquidBalance.toDouble(),
              title: '',
              radius: 20,
              badgeWidget: const Icon(
                  Icons.currency_bitcoin, color: Colors.white),
              color: Colors.orange,
            ),
            PieChartSectionData(
                value: balance.state.brlBalance.toDouble(),
                title: '',
                radius: 20,
                badgeWidget: Flag(Flags.brazil),
                color: Colors.greenAccent
            ),
            PieChartSectionData(
              value: balance.state.cadBalance.toDouble(),
              title: '',
              radius: 20,
              badgeWidget: Flag(Flags.canada),
              color: Colors.red,
            ),
            PieChartSectionData(
              value: balance.state.eurBalance.toDouble(),
              title: '',
              radius: 20,
              badgeWidget: Flag(Flags.european_union),
              color: Colors.blue,
            ),
            PieChartSectionData(
              value: balance.state.usdBalance.toDouble(),
              title: '',
              radius: 20,
              badgeWidget: Flag(Flags.united_states_of_america),
              color: Colors.green,
            ),
          ],
          borderData: FlBorderData(
            show: false,
          ),
        ),
      ),
    );
  }


  Widget _buildMiddleSection(BuildContext context, WidgetRef ref) {
    final totalBalanceInCurrency = ref.watch(totalBalanceInCurrencyProvider);
    final initializeBalance = ref.watch(initializeBalanceProvider);
    final balance = ref.watch(balanceNotifierProvider.notifier);
    final settings = ref.watch(settingsProvider);

    // Dynamic sizing for text and margins based on screen size
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final cardMargin = screenWidth * 0.05;
    final cardPadding = screenWidth * 0.04;
    final titleFontSize = screenHeight *
        0.025; // Larger font size for the balance
    final subtitleFontSize = screenHeight *
        0.02; // Smaller font size for the currency and 'or' text

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Card(
              color: Colors.orange,
              margin: EdgeInsets.all(cardMargin),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: cardPadding, horizontal: cardPadding / 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    initializeBalance.when(
                      data: (_) =>
                          Text(
                            '${balance.state.btcBalance.toStringAsFixed(
                                2)} ${settings.btcFormat}',
                            style: TextStyle(fontSize: titleFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                      loading: () => const CardLoading(height: 10, width: 200),
                      error: (error, stack) =>
                      const Text('Error', style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Text(
                        'or', style: TextStyle(fontSize: 14, color: Colors.white),
                        textAlign: TextAlign.center),
                    SizedBox(height: screenHeight * 0.02),
                    initializeBalance.when(
                      data: (_) =>
                          totalBalanceInCurrency.when(
                            data: (total) =>
                                Text(
                                  '${total.toStringAsFixed(2)} ${settings
                                      .currency}',
                                  style: TextStyle(fontSize: subtitleFontSize,
                                      color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                            loading: () =>
                            const CardLoading(height: 20, width: 200),
                            error: (error, stack) =>
                                TextButton(onPressed: () =>
                                    ref.refresh(settingsProvider.notifier),
                                    child: const Text('Retry',
                                        style: TextStyle(color: Colors.white))),
                          ),
                      loading: () => const CardLoading(height: 20, width: 200),
                      error: (error, stack) =>
                          const Text('Failed to load',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          initializeBalance.when(
            data: (_) => _buildDiagram(ref, context),
            loading: () => const CardLoading(height: 200, width: 200),
            error: (error, stack) =>
            const Text('Failed to load', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: screenHeight * 0.05),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Accounts()),
              );
            },
            style: _buildElevatedButtonStyle(),
            child: const Text('View Accounts'),
          ),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }

  ButtonStyle _buildElevatedButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        Colors.white,
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      elevation: MaterialStateProperty.all<double>(0.0),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).padding.top + kToolbarHeight + 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircularButton(Icons.add, 'Add Money', () {
            Navigator.pushNamed(context, '/charge');
          }, Colors.white),
          _buildCircularButton(Icons.swap_horizontal_circle, 'Exchange',
                  () {
                Navigator.pushNamed(context, '/exchange');
              }, Colors.white),
          _buildCircularButton(Icons.payments, 'Pay', () {
            Navigator.pushNamed(context, '/pay');
          }, Colors.white),
          _buildCircularButton(
              Icons.arrow_downward_sharp, 'Receive', () {
            Navigator.pushNamed(context, '/receive');
          }, Colors.white),
        ],
      ),
    );
  }



  Widget _buildCircularButton(IconData icon, String subtitle,
      VoidCallback onPressed, Color color) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color],
                ),
                border: Border.all(color: Colors.black.withOpacity(0.7)),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 25,
                child: Icon(
                  icon,
                  color: Colors.black.withOpacity(0.7),
                  size: 25,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle,style: const TextStyle(fontSize: 10, color: Colors.black)),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Clarity.block_solid, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/search_modal');
          },
        ),
        title: FutureBuilder<dynamic>(
          future: getBtcPrice(ref),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CardLoading(
                width: 100,
                height: 20,
              );
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              return Text("${snapshot.data}", style: const TextStyle(color: Colors.black));
            }
          },
        ),
        centerTitle: true,
        actions: [

          IconButton(
            icon: const Icon(Clarity.settings_line, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
