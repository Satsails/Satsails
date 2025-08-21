// lib/screens/analytics/components/pie_chart.dart

import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:intl/intl.dart';

class AssetAllocationChart extends ConsumerStatefulWidget {
  // The data structure remains the same, but the legend that used it is now removed.
  final Map<String, ({double fiatValue, int originalBalance})> allocationData;

  const AssetAllocationChart({super.key, required this.allocationData});

  @override
  ConsumerState<AssetAllocationChart> createState() => _AssetAllocationChartState();
}

// FIX: Removed 'TickerProviderStateMixin' as it's no longer needed.
class _AssetAllocationChartState extends ConsumerState<AssetAllocationChart> {
  int touchedIndex = -1;

  final Map<String, Color> _colorMap = {
    'BTC': const Color(0xFFF7931A),
    'L-BTC': const Color(0xFF00A3FF),
    'Depix': const Color(0xFF26A17B),
    'USDT': const Color(0xFF50AF95),
    'EURx': const Color(0xFF6F42C1),
  };

  final Map<String, String> _displayNameMap = {
    'BTC': 'Bitcoin',
    'L-BTC': 'Liquid Bitcoin',
  };

  @override
  Widget build(BuildContext context) {
    if (widget.allocationData.isEmpty) {
      return Center(child: Text("No assets to display".i18n, style: TextStyle(color: Colors.white70)));
    }

    final totalValue = widget.allocationData.values.fold(0.0, (sum, item) => sum + item.fiatValue);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            centerSpaceRadius: 80.r,
            sections: showingSections(totalValue),
          ),
          swapAnimationDuration: const Duration(milliseconds: 400),
          swapAnimationCurve: Curves.easeInOut,
        ),
        _buildCenterText(totalValue),
      ],
    );
  }

  /// Builds the text shown in the center of the pie chart.
  Widget _buildCenterText(double totalValue) {
    final settings = ref.watch(settingsProvider);
    final currencyFormatter = NumberFormat.simpleCurrency(name: settings.currency, decimalDigits: 2);

    String title;
    String value;
    String? subtitle;

    final entries = widget.allocationData.entries.toList();

    if (touchedIndex != -1 && touchedIndex < entries.length) {
      final entry = entries[touchedIndex];
      final assetName = entry.key;
      final assetData = entry.value;

      title = _displayNameMap[assetName] ?? assetName;
      value = currencyFormatter.format(assetData.fiatValue);

      // FIX: Add subtitle with the balance in the asset's native unit.
      final isBitcoinAsset = ['BTC', 'L-BTC'].contains(assetName);
      if (isBitcoinAsset) {
        subtitle = '${btcInDenominationFormatted(assetData.originalBalance, settings.btcFormat)} ${settings.btcFormat.toUpperCase()}';
      } else {
        subtitle = '${fiatInDenominationFormatted(assetData.originalBalance)} $assetName';
      }

    } else {
      title = "Total Value".i18n;
      value = currencyFormatter.format(totalValue);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey('$title-$subtitle'), // Use a composite key to ensure animation triggers correctly
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12.sp,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }


  /// Generates the data for each section of the pie chart.
  List<PieChartSectionData> showingSections(double totalValue) {
    return widget.allocationData.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final isTouched = index == touchedIndex;

      // FIX: The chart radius is no longer conditional, simplifying the logic.
      final double baseRadius = 65.r;
      final radius = isTouched ? baseRadius + 10.r : baseRadius;
      final fontSize = isTouched ? 18.0.sp : 14.0.sp;

      final assetName = entry.value.key;
      final assetValue = entry.value.value.fiatValue;
      final percentage = totalValue > 0 ? (assetValue / totalValue) * 100 : 0;

      return PieChartSectionData(
        color: _colorMap[assetName] ?? Colors.grey,
        value: assetValue,
        title: percentage > 7 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: radius,
        borderSide: isTouched ? BorderSide(color: (_colorMap[assetName] ?? Colors.grey).withOpacity(0.7), width: 6) : BorderSide.none,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
        ),
      );
    }).toList();
  }
}