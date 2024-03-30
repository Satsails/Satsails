import 'package:flutter/material.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/providers/navigation_provider.dart';
import 'package:satsails/screens/accounts/accounts.dart';
import 'package:satsails/screens/shared/bottom_navigation_bar.dart';
import 'package:card_loading/card_loading.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:satsails/providers/settings_provider.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  Future<dynamic> getBtcPrice(WidgetRef ref) async {
    final currency = ref.watch(settingsProvider).currency;
    final fx = Forex();
    return await fx.getCurrencyConverted(sourceCurrency: 'BTC', destinationCurrency: currency, sourceAmount: 1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, ref),
      body: SafeArea(child: _buildBody(context, ref)),
    );
  }

  Widget _buildBody(BuildContext context, ref) {
    return Column(
      children: [
        _buildTopSection(context),
        _buildActionButtons(context),
        // re add this on mvpv2 when a service is available
        CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          context: context,
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
      ],
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery
            .of(context)
            .padding
            .top + kToolbarHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Text(
              '0.00000000 BTC', // Replace with the actual balance
              style: TextStyle(fontSize: 30, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text('or',
                style: TextStyle(fontSize: 12, color: Colors.black)),
            const SizedBox(height: 10),
            const Text(
              '0.00000000 USD', // Replace with the actual riverpod
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const Accounts(),
                  ),
                );
              },
              style: _buildElevatedButtonStyle(),
              child: const Text('View Accounts'),
            ),
          ],
        ),
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
      height: MediaQuery
          .of(context)
          .padding
          .top + kToolbarHeight + 30,
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
        Text(subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.black)),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Clarity.settings_line, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
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
              return Text("${snapshot.data} ${ref.watch(settingsProvider).currency}", style: const TextStyle(color: Colors.black));
            }
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Clarity.block_solid, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/search_modal');
            },
          ),
        ],
      ),
    );
  }
}
