import 'package:flutter/material.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/balance_model.dart';
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
    final currency = ref.watch(settingsProvider).currency;
    final fx = Forex();
    final result = await fx.getCurrencyConverted(sourceCurrency: 'BTC', destinationCurrency: currency, sourceAmount: 1);
    final error = fx.getErrorNotifier.value;

    if (error != null){
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
    final initializedBalance = ref.watch(initializeBalanceProvider);
    return initializedBalance.when(
      data: (balance) {
        final balanceProvider = ref.watch(balanceNotifierProvider.notifier);
        return Column(
          children: [
            _buildMiddleSection(context, ref, balanceProvider),
            _buildActionButtons(context),
            CustomBottomNavigationBar(
              currentIndex: ref.watch(navigationProvider),
              context: context,
              onTap: (int index) {
                ref.read(navigationProvider.notifier).state = index;
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('Error')),
    );
  }

  Widget _buildDiagram(WidgetRef ref, BuildContext context, BalanceModel balance) {
    if (balance.state.btcBalance == 0) {
      return Expanded(
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: 1,
                title: '',
                radius: 20,
                color: Colors.grey,
              ),
            ],
            borderData: FlBorderData(
              show: false,
            ),
          ),
        ),
      );
    } else{
      return Expanded(
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: balance.state.btcBalance + balance.state.liquidBalance.toDouble(),
                title: '',
                radius: 20,
                badgeWidget: const Icon(Icons.currency_bitcoin, color: Colors.white),
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
  }



  Widget _buildMiddleSection(BuildContext context, WidgetRef ref, BalanceModel balance) {
    final totalBalanceInCurrency = ref.watch(totalBalanceInCurrencyProvider);
    return totalBalanceInCurrency.when(
      data: (total) {
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  color: Colors.orange,
                  margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  elevation: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Text(
                        '${balance.state.btcBalance} BTC',
                        style: const TextStyle(fontSize: 30, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      const Text('or', style: TextStyle(fontSize: 12, color: Colors.white), textAlign: TextAlign.center),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                      Text(
                        '${total} ${ref.watch(settingsProvider).currency}',
                        style: const TextStyle(fontSize: 15, color:  Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.07),
              _buildDiagram(ref, context, balance),
              SizedBox(height: MediaQuery.of(context).size.height * 0.07),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        );
      },
      loading: () => const CardLoading(width: 100, height: 20),
      error: (error, stack) => const Text('Error'),
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
