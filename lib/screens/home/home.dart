import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:flutter/material.dart';
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
      viewportFraction: 0.9, // Default viewport fraction
      initialPage: 0,
    );

    // Add listener to dynamically adjust viewportFraction based on page
    _controller.addListener(() {
      if (_controller.page != null) {
        const assetsLength = 4; // Or make this dynamic based on your assets list
        final currentPage = _controller.page!.round();
        // If it's the last item, set viewportFraction to 0.95
        if (currentPage == assetsLength - 1) {
          if (_controller.viewportFraction != 0.98) {
            setState(() {
              _controller = PageController(
                viewportFraction: 0.98,
                initialPage: currentPage,
              );
            });
          }
        } else {
          if (_controller.viewportFraction != 0.9) {
            setState(() {
              _controller = PageController(
                viewportFraction: 0.9,
                initialPage: currentPage,
              );
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = [
      {'name': 'Bitcoin', 'color': Color(0xFFFF9800)},
      {'name': 'Depix', 'color': Color(0xFF009C3B)},
      {'name': 'USDT', 'color': Color(0xFF008001)},
      {'name': 'EURx', 'color': Color(0xFF003399)},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: PageView.builder(
        itemCount: assets.length,
        controller: _controller,
        clipBehavior: Clip.none,
        padEnds: false,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: 16.0.sp),
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
                flex: 4,
                child: const BalanceScreen(),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
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