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
  late List<Map<String, dynamic>> _assets;
  late List<String> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _assets = [
      {'name': 'Bitcoin', 'color': const Color(0xFFFF9800)},
      {'name': 'Depix', 'color': const Color(0xFF009C3B)},
      {'name': 'USDT', 'color': const Color(0xFF008001)},
      {'name': 'EURx', 'color': const Color(0xFF003399)},
    ];
    _selectedFilters = List.filled(_assets.length, 'Bitcoin network');
    _controller = PageController(
      viewportFraction: 0.9,
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: PageView.builder(
        itemCount: _assets.length,
        controller: _controller,
        clipBehavior: Clip.none,
        padEnds: false,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: 16.sp),
            child: Container(
              height: 200.sp, // Using .sp for responsiveness
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Changed for consistency
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          popupMenuTheme: const PopupMenuThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0)),
                            ),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedFilters[index],
                          items: [
                            DropdownMenuItem(
                              value: 'Bitcoin network',
                              child: Row(
                                children: [
                                  Image.asset(
                                    'lib/assets/bitcoin-logo.png',
                                    width: 24.sp,
                                    height: 24.sp,
                                  ),
                                  SizedBox(width: 10.sp),
                                  Text(
                                    'Bitcoin network',
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  ),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Liquid network',
                              child: Row(
                                children: [
                                  Image.asset(
                                    'lib/assets/l-btc.png',
                                    width: 24.sp,
                                    height: 24.sp,
                                  ),
                                  SizedBox(width: 10.sp),
                                  Text(
                                    'Liquid network',
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  ),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Lightning network',
                              child: Row(
                                children: [
                                  Image.asset(
                                    'lib/assets/Bitcoin_lightning_logo.png',
                                    width: 24.sp,
                                    height: 24.sp,
                                  ),
                                  SizedBox(width: 10.sp),
                                  Text(
                                    'Lightning network',
                                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedFilters[index] = newValue;
                              });
                            }
                          },
                          dropdownColor: const Color(0xFF212121),
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
                          underline: const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp), // Added spacing
                  Expanded(
                    child: BalanceCard(
                      assetName: _assets[index]['name'] as String,
                      color: _assets[index]['color'] as Color,
                      networkFilter: _selectedFilters[index],
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
              const Expanded(
                flex: 4,
                child: BalanceScreen(),
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