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
  String _selectedFilter = 'Bitcoin network';

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.9, // Fixed viewport fraction
      initialPage: 0,
    );
    // Listener removed to avoid dynamic viewportFraction changes
  }

  PopupMenuItem<String> _buildMenuItem(String text, String logoPath) {
    return PopupMenuItem<String>(
      value: text,
      child: Row(
        children: [
          Image.asset(logoPath, width: 24, height: 24),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
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
      {'name': 'Bitcoin', 'color': const Color(0xFFFF9800)},
      {'name': 'Depix', 'color': const Color(0xFF009C3B)},
      {'name': 'USDT', 'color': const Color(0xFF008001)},
      {'name': 'EURx', 'color': const Color(0xFF003399)},
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
            child: Container(
              height: 200,
              child: Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: const PopupMenuThemeData(
                        color: Color(0xFF212121),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, color: Colors.white),
                      onSelected: (String value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        _buildMenuItem('Bitcoin network', 'lib/assets/bitcoin-logo.png'),
                        _buildMenuItem('Liquid network', 'lib/assets/l-btc.png'),
                        _buildMenuItem('Lightning network', 'lib/assets/Bitcoin_lightning_logo.png'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BalanceCard(
                      assetName: assets[index]['name'] as String,
                      color: assets[index]['color'] as Color,
                    ),
                  ),
                ],
              ),
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