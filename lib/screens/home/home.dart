import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/balance_model.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/navigation_provider.dart';
import 'package:satsails/screens/accounts/accounts.dart';
import 'package:satsails/screens/shared/bottom_navigation_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:satsails/screens/shared/custom_button.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

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

  Widget _buildDiagram(BuildContext context, Percentage percentage) {
    return percentage.total == 0
        ? PieChart(PieChartData(sections: [PieChartSectionData(value: 1, title: '', radius: 20, color: Colors.grey)], borderData: FlBorderData(show: false)))
        : PieChart(PieChartData(
      sections: [
        PieChartSectionData(value: percentage.btcPercentage + percentage.liquidPercentage, title: '', radius: 20, badgeWidget: const Icon(Icons.currency_bitcoin, color: Colors.white), color: Colors.orange),
        PieChartSectionData(value: percentage.brlPercentage, title: '', radius: 20, badgeWidget: Flag(Flags.brazil, size: 25), color: Colors.deepPurpleAccent),
        PieChartSectionData(value: percentage.eurPercentage, title: '', radius: 20, badgeWidget: Flag(Flags.european_union, size: 25), color: Colors.blue),
        PieChartSectionData(value: percentage.usdPercentage, title: '', radius: 20, badgeWidget: Flag(Flags.united_states_of_america, size: 25), color: Colors.green),
      ],
      borderData: FlBorderData(show: false),
    ));
  }

  Widget _buildMiddleSection(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardMargin = screenWidth * 0.05;
    final cardPadding = screenWidth * 0.04;
    final titleFontSize = screenHeight * 0.03;
    final subtitleFontSize = screenHeight * 0.02;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
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
                    Consumer(builder: (context, watch, child) {
                      final settings = ref.watch(settingsProvider);
                      final initializeBalance = ref.watch(initializeBalanceProvider);
                      final totalInDenominatedCurrency = ref.watch(totalBalanceInDenominationProvider(settings.btcFormat));
                      return initializeBalance.when(
                        data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text('$totalInDenominatedCurrency ${settings.btcFormat}', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                        loading: () =>SizedBox(height: titleFontSize * 1.5,child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                        error: (error, stack) => SizedBox(height: titleFontSize * 1.5,child: TextButton(onPressed: () { ref.refresh(totalBalanceInDenominationProvider(settings.btcFormat)); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize)))),
                      );
                    }),
                    SizedBox(height: screenHeight * 0.01),
                    const Text('or', style: TextStyle(fontSize: 14, color: Colors.white), textAlign: TextAlign.center),
                    SizedBox(height: screenHeight * 0.01),
                    Consumer(builder: (context, watch, child) {
                      final settings = ref.watch(settingsProvider);
                      final initializeBalance = ref.watch(initializeBalanceProvider);
                      final totalBalanceInCurrency = ref.watch(totalBalanceInCurrencyProvider(settings.currency)).toStringAsFixed(2);
                      return initializeBalance.when(
                          data: (_) => SizedBox(height: subtitleFontSize * 1.5, child: Text('$totalBalanceInCurrency ${settings.currency}', style: TextStyle(fontSize: subtitleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                          loading: () => SizedBox(height: subtitleFontSize * 1.5, child:LoadingAnimationWidget.prograssiveDots(size: subtitleFontSize, color: Colors.white)),
                          error: (error, stack) => SizedBox(height: subtitleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(totalBalanceInCurrencyProvider(settings.currency)); },child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: subtitleFontSize))),
                          ));
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: Consumer(builder: (context, watch, child) {
            final initializeBalance = ref.watch(initializeBalanceProvider);
            final percentageOfEachCurrency = ref.watch(percentageChangeProvider);
            return initializeBalance.when(
              data: (_) => _buildDiagram(context, percentageOfEachCurrency),
              loading: () => LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange),
              error: (error, stack) => LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange),
            );
          }),
        ),
        SizedBox(height: screenHeight * 0.05),
        SizedBox(
            height:screenWidth * 0.15,
            width: screenWidth * 0.6,
            child: CustomButton(text: 'View Accounts', onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const Accounts())); },)
        )
      ],
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
    final value = ref.watch(currentBitcoinPriceInCurrencyProvider(CurrencyParams(ref.watch(settingsProvider).currency, 100000000))).toStringAsFixed(2);
    final settings = ref.read(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    void toggleOnlineStatus() {
      settingsNotifier.setOnline(true);
    }

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
        title: Text(
          '$value ${settings.currency}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: <Shadow>[
              Shadow(
                offset: const Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Clarity.settings_line, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.fiber_manual_record,
              color: settings.online ? Colors.green : Colors.red,
            ),
            onPressed: () {
              toggleOnlineStatus();
            },
          ),
        ],
      ),
    );
  }
}
