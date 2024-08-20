import 'package:Satsails/screens/creation/components/logo.dart';
import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/accounts/accounts.dart';
import 'package:Satsails/screens/shared/bottom_navigation_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/build_balance_card.dart';
import 'package:Satsails/screens/shared/circular_button.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/pie_chart.dart';
import 'package:Satsails/translations/translations.dart';


class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(context, ref),
        body: SafeArea(child: _buildBody(context, ref)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(child: _buildMiddleSection(context, ref)),
        buildActionButtons(context, ref),
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

  Widget _buildMiddleSection(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const BackupWarning(),
        buildBalanceCard(context, ref, 'totalBalanceInDenominationProvider', 'totalBalanceInFiatProvider'),
        Flexible(
          child: SizedBox(
            height: screenHeight * 0.24,
            child: Consumer(builder: (context, watch, child) {
              final initializeBalance = ref.watch(initializeBalanceProvider);
              final percentageOfEachCurrency = ref.watch(percentageChangeProvider);
              return initializeBalance.when(
                data: (balance) =>
                balance.isEmpty
                    ? emptyBalance(ref, context)
                    : buildDiagram(context, percentageOfEachCurrency),
                loading: () =>
                    LoadingAnimationWidget.threeArchedCircle(
                        size: 200, color: Colors.orange),
                error: (error, stack) =>
                    LoadingAnimationWidget.threeArchedCircle(
                        size: 200, color: Colors.orange),
              );
            }),
          ),
        ),
        SizedBox(height: screenHeight * 0.05),
        SizedBox(
          height: screenWidth * 0.17,
          width: screenWidth * 0.6,
          child: CustomButton(
            text: 'View Accounts'.i18n(ref),
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => const Accounts()));
            },
          ),
        )
      ],
    );
  }

  Widget emptyBalance(WidgetRef ref, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Your wallet is empty'.i18n(ref),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
        Icon(Iconsax.security_safe_bold, size: screenHeight * 0.2,
            color: Colors.blueAccent),
      ],
    );
  }


  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final settingsNotifier = ref.read(settingsProvider.notifier);

    void toggleOnlineStatus() {
      settingsNotifier.setOnline(true);
      ref.read(backgroundSyncNotifierProvider).performSync();
    }

    return AppBar(
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Logo(widthFactor: 0.03, heightFactor: 0.03),
          // Slightly larger size
          SizedBox(width: screenWidth * 0.02),
          // 2% of screen width
          const Text(
            'Satsails',
            style: TextStyle(
              color: Colors.orange,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Clarity.settings_line, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
        ref.watch(backgroundSyncInProgressProvider)
            ? LoadingAnimationWidget.bouncingBall(
            color: Colors.orange, size: 40) // Slightly larger size
            : IconButton(
          icon: Icon(
            Icons.sync,
            color: settings.online ? Colors.green : Colors.red,
          ),
          onPressed: () {
            toggleOnlineStatus();
          },
        ),
      ],
    );
  }
}



