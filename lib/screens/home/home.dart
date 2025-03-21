import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/shared/build_balance_card.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.95,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = [
      {'name': 'BTC', 'color': Colors.orange},
      {'name': 'LBTC', 'color': Colors.green},
      {'name': 'USD', 'color': Colors.green[800]!},
      {'name': 'EUR', 'color': Colors.blue},
    ];

    return Padding(
      padding: EdgeInsets.all(16.0.sp),
      child: PageView.builder(
        itemCount: assets.length,
        controller: _controller,
        clipBehavior: Clip.none,
        padEnds: false,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.sp),
            child: BalanceCard(
              assetName: assets[index]['name'] as String,
              color: assets[index]['color'] as Color,
            ),
          );
        },
      ),
    );
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              const BackupWarning(), // Takes its intrinsic height
              Expanded(
                flex: 4, // 30% of remaining space for BalanceScreen
                child: const BalanceScreen(),
              ),
              Expanded(
                flex: 7, // 70% of remaining space for TransactionList
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    color: Colors.black,
                    child: const TransactionList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}