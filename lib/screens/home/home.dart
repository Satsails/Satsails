import 'dart:io';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:upgrader/upgrader.dart';

// This provider holds the state for the selected asset.
final selectedAssetProvider = StateProvider<String>((ref) => 'Bitcoin');

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.read(settingsProvider).language;
    final dialogStyle = Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material;

    return UpgradeAlert(
      dialogStyle: dialogStyle,
      upgrader: Upgrader(
        languageCode: language,
        durationUntilAlertAgain: const Duration(days: 3),
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          body: SafeArea(
            child: Column(
              children: [
                const Expanded(
                  // Changed back to 4 to make the card smaller
                  flex: 4,
                  child: BalanceScreen(),
                ),
                Expanded(
                  // Changed back to 6
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sp),
                    child: Container(
                      color: Colors.black,
                      child: const TransactionList(showAll: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 18),
      child: BalanceCard(),
    );
  }
}
