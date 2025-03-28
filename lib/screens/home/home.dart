import 'package:Satsails/screens/shared/backup_warning.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/shared/balance_card.dart';

// Assuming ScreenUtil is used for .sp units

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  late PageController _controller;
  late List<Map<String, dynamic>> _assets;
  late List<String> _selectedFilters;
  int currentPage = 0;

  // Map of network names to their icon paths
  final Map<String, String> _networkImages = {
    'Bitcoin network': 'lib/assets/bitcoin-logo.png',
    'Liquid network': 'lib/assets/l-btc.png',
    'Lightning network': 'lib/assets/Bitcoin_lightning_logo.png',
  };

  @override
  void initState() {
    super.initState();
    _assets = [
      {'name': 'Bitcoin', 'color': const Color(0xFFFF9800)},
      {'name': 'Depix', 'color': const Color(0xFF009C3B)},
      {'name': 'USDT', 'color': const Color(0xFF008001)},
      {'name': 'EURx', 'color': const Color(0xFF003399)},
    ];
    // Set "Bitcoin network" for Bitcoin, "Liquid network" for others
    _selectedFilters = _assets.map((asset) => asset['name'] == 'Bitcoin' ? 'Bitcoin network' : 'Liquid network').toList();
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

  void _updateController(int page) {
    if (page == _assets.length - 1) {
      if (_controller.viewportFraction != 0.95) {
        _controller.dispose(); // Dispose of the old controller
        _controller = PageController(
          viewportFraction: 0.98,
          initialPage: page,
        );
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.hasClients) {
            _controller.animateToPage(
              page,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        });
      }
    } else {
      if (_controller.viewportFraction != 0.9) {
        _controller.dispose(); // Dispose of the old controller
        _controller = PageController(
          viewportFraction: 0.9,
          initialPage: page,
        );
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.hasClients) {
            _controller.animateToPage(
              page,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        });
      }
    }
  }

  /// Builds a Row with the network icon and text
  Widget _buildNetworkRow(String network) {
    return Row(
      children: [
        Image.asset(
          _networkImages[network]!,
          width: 24.sp,
          height: 24.sp,
        ),
        SizedBox(width: 10.sp),
        Text(
          network,
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: _assets.length,
      controller: _controller,
      clipBehavior: Clip.none,
      padEnds: false,
      onPageChanged: (int page) {
        setState(() {
          currentPage = page;
        });
        _updateController(page);
      },
      itemBuilder: (context, index) {
        // Define the dropdown widget based on the asset
        Widget dropdown;
        if (_assets[index]['name'] == 'Bitcoin') {
          dropdown = DropdownButton<String>(
            value: _selectedFilters[index],
            items: [
              'Bitcoin network',
              'Liquid network',
              'Lightning network',
            ].map((network) {
              return DropdownMenuItem<String>(
                value: network,
                child: _buildNetworkRow(network),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFilters[index] = newValue;
                });
              }
            },
            dropdownColor: const Color(0xFF212121),
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            padding: EdgeInsets.zero,
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
            underline: const SizedBox(),
          );
        } else {
          dropdown = DropdownButton<String>(
            value: _selectedFilters[index],
            items: [
              DropdownMenuItem<String>(
                value: 'Liquid network',
                child: _buildNetworkRow('Liquid network'),
              ),
            ],
            onChanged: null, // Disable interaction
            padding: EdgeInsets.zero,
            dropdownColor: const Color(0xFF212121),
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
            underline: const SizedBox(),
          );
        }

        return Padding(
          padding: EdgeInsets.only(left: 16.sp),
          child: SizedBox(
            height: 200.sp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0.sp),
                      child: dropdown,
                    ),
                  ],
                ),
                SizedBox(
                  height: 0.23.sh,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.sp),
                    child: BalanceCard(
                      assetName: _assets[index]['name'] as String,
                      color: _assets[index]['color'] as Color,
                      networkFilter: _selectedFilters[index],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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