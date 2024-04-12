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
import 'package:satsails/screens/shared/build_balance_card.dart';
import 'package:satsails/screens/shared/circulat_button.dart';
import 'package:satsails/screens/shared/custom_button.dart';
import 'package:satsails/screens/shared/offline_transaction_warning.dart';
import 'package:satsails/screens/shared/pie_chart.dart';

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
        buildActionButtons(context),
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

  Widget _buildMiddleSection(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final online = ref.watch(settingsProvider).online;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        OfflineTransactionWarning(online: online),
        buildBalanceCard(context, ref),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.24,
          child: Consumer(builder: (context, watch, child) {
            final initializeBalance = ref.watch(initializeBalanceProvider);
            final percentageOfEachCurrency = ref.watch(percentageChangeProvider);
            return initializeBalance.when(
              data: (_) => buildDiagram(context, percentageOfEachCurrency),
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
