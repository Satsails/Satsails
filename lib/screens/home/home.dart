import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/creation/components/logo.dart';
import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/build_balance_card.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
        // appBar: _buildAppBar(context, ref),
        body: SafeArea(
          child: _buildBody(context, ref),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(child: _buildMiddleSection(context, ref)),
      ],
    );
  }

  Widget _buildMiddleSection(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const BackupWarning(),
        buildBalanceCard(context, ref, 'totalBalanceInDenominationProvider', 'totalBalanceInFiatProvider'),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16.0.sp),
            child: Container(
              color: Colors.black,
              child: const TransactionList(),
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    void toggleOnlineStatus() {
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
              const SizedBox(width: 5),
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
        GestureDetector(
          onTap: () {
            ref.invalidate(initializeUserProvider);
            context.push('/home/settings');
          },
          child: const Icon(Clarity.settings_line, color: Colors.white),
        ),
        const SizedBox(width: 10),
        ref.watch(backgroundSyncInProgressProvider)
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: LoadingAnimationWidget.beat(
            color: Colors.green,
            size: 20,
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () {
              toggleOnlineStatus();
            },
            child: LoadingAnimationWidget.beat(
              color: settings.online ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}