import 'dart:io';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BalanceScreen extends ConsumerStatefulWidget {
  const BalanceScreen({super.key});

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends ConsumerState<BalanceScreen> {
  late PageController _controller;
  late List<Map<String, dynamic>> _assets;
  late List<String> _selectedFilters;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _assets = [
      {
        'name': 'Bitcoin Network',
        'color': const Color(0xFFFF9800),
        'logo': 'lib/assets/bitcoin-logo.svg',
        'assets': [
          {'name': 'Bitcoin (Mainnet)', 'icon': 'lib/assets/bitcoin-logo.png'}
        ]
      },
      {
        'name': 'Spark Network',
        'color': const Color(0xFF212121),
        'logo': 'lib/assets/logo-spark.svg',
        'assets': [
          {'name': 'Lightning Bitcoin', 'icon': 'lib/assets/Bitcoin_lightning_logo.png'}
        ]
      },
      {
        'name': 'Liquid Network',
        'color': const Color(0xFFFFFFFF),
        'logo': 'lib/assets/liquid-logo.png',
        'assets': [
          {'name': 'Liquid Bitcoin', 'icon': 'lib/assets/l-btc.png'},
          {'name': 'USDT', 'icon': 'lib/assets/tether.png'},
          {'name': 'EURx', 'icon': 'lib/assets/eurx.png'},
          {'name': 'Depix', 'icon': 'lib/assets/depix.png'}
        ]
      },
    ];
    _selectedFilters = _assets.map((asset) => asset['assets'][0]['name'] as String).toList();
    _controller = PageController(viewportFraction: 0.9, initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDropdown(int index) {
    final networkAssets = _assets[index]['assets'] as List<Map<String, String>>;
    return Container(
      width: 220.sp,
      height: 40.sp,
      child: DropdownButton<String>(
        value: _selectedFilters[index],
        items: networkAssets.map((asset) {
          return DropdownMenuItem<String>(
            value: asset['name'],
            child: Row(
              children: [
                if (asset['icon']!.endsWith('.svg'))
                  SvgPicture.asset(
                    asset['icon']!,
                    width: 24.sp,
                    height: 24.sp,
                  )
                else
                  Image.asset(
                    asset['icon']!,
                    width: 24.sp,
                    height: 24.sp,
                  ),
                SizedBox(width: 10.sp),
                Text(
                  asset['name']!,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
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
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.sp),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
        underline: const SizedBox(),
        isExpanded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSyncing = ref.watch(backgroundSyncInProgressProvider);
    final isOnline = ref.watch(settingsProvider).online;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 8.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: isSyncing
                    ? null
                    : () {
                  ref.read(backgroundSyncNotifierProvider.notifier).performSync();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10.sp,
                        height: 10.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSyncing
                              ? Colors.orange
                              : isOnline
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      SizedBox(width: 4.sp),
                      Text(
                        isSyncing ? 'Syncing'.i18n : isOnline ? 'Online' : 'Offline',
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
              _buildDropdown(currentPage),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            itemCount: _assets.length,
            controller: _controller,
            clipBehavior: Clip.none,
            padEnds: false,
            onPageChanged: (int page) {
              setState(() {
                currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final selectedAssetName = _selectedFilters[index];
              return Padding(
                padding: EdgeInsets.only(left: 18.sp),
                child: SizedBox(
                  height: 200.sp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 0.25.sh,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10.sp),
                          child: BalanceCard(
                            network: _assets[index]['name'] as String,
                            selectedAsset: selectedAssetName,
                            iconPath: _assets[index]['logo'] as String,
                            color: _assets[index]['color'] as Color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.microtask(() => ref.read(shouldUpdateMemoryProvider.notifier).state = true);

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
      ),
    );
  }
}