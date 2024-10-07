import 'package:Satsails/screens/creation/components/logo.dart';
import 'package:Satsails/screens/home/components/bitcoin_price_history_graph.dart';
import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:Satsails/screens/shared/depix_convert_warning.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/shared/bottom_navigation_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/build_balance_card.dart';
import 'package:Satsails/screens/shared/circular_button.dart';
import 'package:Satsails/screens/shared/pie_chart.dart';


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
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const BackupWarning(),
        buildBalanceCard(context, ref, 'totalBalanceInDenominationProvider', 'totalBalanceInFiatProvider'),
        const DepixConvertWarning(),
        SizedBox(height: screenHeight * 0.01),
        buildActionButtons(context, ref),
        SizedBox(height: screenHeight * 0.01),
        Flexible(
          child: SizedBox(
            height: double.infinity,
            child: Consumer(builder: (context, watch, child) {
              final initializeBalance = ref.watch(initializeBalanceProvider);
              final percentageOfEachCurrency = ref.watch(percentageChangeProvider);
              return initializeBalance.when(
                data: (balance) => balance.isEmpty
                    ? const BitcoinPriceHistoryGraph()
                    : walletWidget(ref, context, percentageOfEachCurrency),
                loading: () =>Center(child: LoadingAnimationWidget.threeArchedCircle(size: 100, color: Colors.orange)),
                error: (error, stack) =>
                    Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                          size: 100, color: Colors.orange),
                    ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget walletWidget(WidgetRef ref, BuildContext context, percentageOfEachCurrency) {

    return ImageSlideshow(
      initialPage: 0,
      indicatorColor: Colors.orangeAccent,
      indicatorBottomPadding: 0,
      indicatorBackgroundColor: Colors.grey,
      children: [
        Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
          child: buildDiagram(context, percentageOfEachCurrency),
        ),
        const BitcoinPriceHistoryGraph(),
      ],
    );
  }



  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final settingsNotifier = ref.read(settingsProvider.notifier);

    void toggleOnlineStatus() {
      settingsNotifier.setOnline(true);
      ref.read(backgroundSyncNotifierProvider.notifier).performSync();
    }

    return AppBar(
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Logo(widthFactor: 0.03, heightFactor: 0.03),
          SizedBox(width: screenWidth * 0.02),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Satsails',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5),
              Transform.translate(
                offset: const Offset(0, -2),
                child: const Text(
                  'BETA',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Clarity.settings_line, color: Colors.white),
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
            color: settings.online ? Colors.white : Colors.red,
          ),
          onPressed: () {
            toggleOnlineStatus();
          },
        ),
      ],
    );
  }
}



