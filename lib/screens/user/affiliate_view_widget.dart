import 'package:Satsails/models/affiliate_model.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/error_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final loadingProvider = StateProvider.autoDispose<bool>((ref) => false);

Future<Map<String, dynamic>> fetchAllData(AutoDisposeFutureProviderRef ref) async {
  final user = ref.read(userProvider);
  final hasCreatedAffiliate = user.hasCreatedAffiliate;
  final hasInsertedAffiliate = user.hasInsertedAffiliate;

  Map<String, dynamic> data = {
    'hasCreatedAffiliate': hasCreatedAffiliate,
    'hasInsertedAffiliate': hasInsertedAffiliate,
    'affiliateData': ref.watch(affiliateProvider),
  };

  if (hasCreatedAffiliate) {
    final totalValuePurchasedFuture = ref.read(getTotalValuePurchasedByAffiliateUsersProvider.future);
    final earningsFuture = ref.read(affiliateEarningsProvider.future);
    final numberOfInstallFuture = ref.read(numberOfAffiliateInstallsProvider.future);
    final allTransfersFuture = ref.read(getAllTransfersFromAffiliateUsersProvider.future);

    final results = await Future.wait([
      totalValuePurchasedFuture,
      earningsFuture,
      numberOfInstallFuture,
      allTransfersFuture,
    ]);

    data.addAll({
      'totalValuePurchased': results[0],
      'earnings': results[1],
      'numberOfInstall': results[2],
      'allTransfers': results[3],
    });
  }

  return data;
}

final affiliateDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return await fetchAllData(ref);
});

class AffiliateViewWidget extends ConsumerWidget {
  const AffiliateViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Affiliate Section'.i18n(ref), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: ref.watch(affiliateDataProvider).when(
          data: (data) {
            final affiliateData = data['affiliateData'] as Affiliate;
            final hasInsertedAffiliate = data['hasInsertedAffiliate'] as bool;
            final hasCreatedAffiliate = data['hasCreatedAffiliate'] as bool;

            final numberOfInstall = hasCreatedAffiliate ? data['numberOfInstall'] : null;
            final earnings = hasCreatedAffiliate ? data['earnings'] : null;
            final allTransfers = hasCreatedAffiliate ? data['allTransfers'] : null;
            final totalValuePurchased = hasCreatedAffiliate ? data['totalValuePurchased'] : null;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (hasCreatedAffiliate) ...[
                      if (totalValuePurchased != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTierIcon(context, 'Bronze'.i18n(ref), Icons.vpn_key, Decimal.parse(totalValuePurchased.toString()), Decimal.parse('0'), width, height, ref),
                            _buildTierIcon(context, 'Silver'.i18n(ref), Icons.military_tech, Decimal.parse(totalValuePurchased.toString()), Decimal.parse('2500'), width, height, ref),
                            _buildTierIcon(context, 'Gold'.i18n(ref), Icons.emoji_events, Decimal.parse(totalValuePurchased.toString()), Decimal.parse('5000'), width, height, ref),
                            _buildTierIcon(context, 'Diamond'.i18n(ref), Icons.diamond, Decimal.parse(totalValuePurchased.toString()), Decimal.parse('20000'), width, height, ref),
                          ],
                        ),
                      ],
                      SizedBox(height: height * 0.01),
                      _buildAffiliateInfo(affiliateData, width, height, ref),
                      SizedBox(height: height * 0.01),
                      if (earnings != null) ...[
                        _buildEarningsInfo(Decimal.parse(earnings.toString()), width, height, ref),
                      ],
                      SizedBox(height: height * 0.02),
                      if (numberOfInstall != null) ...[
                        _buildInstallationsInfo(numberOfInstall, width, height, ref),
                      ],
                      SizedBox(height: height * 0.02),
                      CustomElevatedButton(
                        text: "Show Earnings Over Time".i18n(ref),
                        onPressed: () => _showGraphBottomModal(context, ref, allTransfers!),
                      ),
                    ] else if (!hasCreatedAffiliate && hasInsertedAffiliate) ...[
                      _buildInsertedAffiliateSection(affiliateData, width, height, ref),
                      const SizedBox(height: 20),
                      Text('Would you like to become an affiliate?'.i18n(ref), style: const TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 10),
                      if (ref.watch(loadingProvider.notifier).state)
                        Align(
                          alignment: Alignment.topCenter,
                          child: LoadingAnimationWidget.threeArchedCircle(
                            color: Colors.orange,
                            size: 50,
                          ),
                        ),
                      CustomElevatedButton(
                        text: 'Become an Affiliate'.i18n(ref),
                        onPressed: () => _showCreateBottomModal(context, 'Create Affiliate Code'.i18n(ref), ref),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => Center(
            child: LoadingAnimationWidget.threeArchedCircle(size: height * 0.1, color: Colors.orange),
          ),
          error: (error, stackTrace) => _errorWidget(error, ref),
        ),
      ),
    );
  }

  Widget _loadingWidget(BuildContext context, double height) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(size: height * 0.1, color: Colors.orange),
    );
  }

  Widget _errorWidget(Object error, WidgetRef ref) {
    return Center(
      child: ErrorDisplay(message: error.toString(), isCard: true),
    );
  }

  Widget _buildAffiliateInfo(Affiliate affiliateData, double width, double height, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.03),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.orange.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Your Affiliate Code to Share'.i18n(ref), style: TextStyle(color: Colors.black, fontSize: width * 0.03)),
          SizedBox(height: height * 0.01),
          Text(affiliateData.createdAffiliateCode, style: TextStyle(color: Colors.black, fontSize: width * 0.06)),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Registered:'.i18n(ref), style: TextStyle(color: Colors.black, fontSize: width * 0.03)),
              const SizedBox(width: 2),
              Text(_formatLiquidAddress(affiliateData.createdAffiliateLiquidAddress), style: TextStyle(color: Colors.black, fontSize: width * 0.03)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsInfo(Decimal earningsDecimal, double width, double height, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(height: height * 0.02),
        if (earningsDecimal > Decimal.parse('20000'))
          Text('You earn 1% per referral in perpetuity'.i18n(ref), style: TextStyle(color: Colors.white, fontSize: width * 0.03)),
        if (earningsDecimal <= Decimal.parse('20000'))
          Text('You earn 0.2% per referral in perpetuity'.i18n(ref), style: TextStyle(color: Colors.white, fontSize: width * 0.03)),
        SizedBox(height: height * 0.01),
        Text('Total Earnings'.i18n(ref), style: TextStyle(color: Colors.white, fontSize: width * 0.04)),
        SizedBox(height: height * 0.01),
        Text('$earningsDecimal DEPIX', style: TextStyle(color: Colors.white, fontSize: width * 0.06, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInstallationsInfo(int installs, double width, double height, WidgetRef ref) {
    return Column(
      children: [
        Text('Number of Referrals'.i18n(ref), style: TextStyle(color: Colors.white, fontSize: width * 0.04)),
        SizedBox(height: height * 0.02),
        Text(installs.toString(), style: TextStyle(color: Colors.white, fontSize: width * 0.06, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInsertedAffiliateSection(Affiliate affiliateData, double width, double height, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.orange.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('You were referred by'.i18n(ref), style: TextStyle(color: Colors.black, fontSize: width * 0.03)),
          SizedBox(height: height * 0.01),
          Text(affiliateData.insertedAffiliateCode, style: TextStyle(color: Colors.black, fontSize: width * 0.06)),
        ],
      ),
    );
  }

  void _showGraphBottomModal(BuildContext context, WidgetRef ref, List<ParsedTransfer> allTransfers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return SingleChildScrollView( // Ensure scrollability in modal
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Earnings Over Time'.i18n(ref),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (allTransfers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'No earnings data available'.i18n(ref),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                if (allTransfers.isNotEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5, // Set a fixed height for the chart
                    child: _buildFlChart(allTransfers, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height, ref),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildFlChart(List<ParsedTransfer> transfersData, double width, double height, WidgetRef ref) {
    List<FlSpot> flSpots = transfersData.map((transfer) {
      final timestamp = DateTime.parse(transfer.timestamp);
      final xValue = timestamp.millisecondsSinceEpoch.toDouble();
      final yValue = double.parse(transfer.amount_payed_to_affiliate);
      return FlSpot(xValue, yValue);
    }).toList();

    // Sort the spots by x value (time)
    flSpots.sort((a, b) => a.x.compareTo(b.x));

    // Calculate min and max dates for X axis
    final minX = flSpots.isNotEmpty ? flSpots.first.x : DateTime.now().millisecondsSinceEpoch.toDouble();
    final maxX = flSpots.isNotEmpty ? flSpots.last.x : DateTime.now().millisecondsSinceEpoch.toDouble();

    // Calculate minY and maxY for proper scaling and padding
    double maxY = 0;
    double minY = 0;

    if (flSpots.isNotEmpty) {
      maxY = flSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      minY = flSpots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);

      // Add padding to maxY and minY
      final double yRange = maxY - minY;
      maxY += yRange * 0.1; // 10% padding at the top
      minY -= yRange * 0.1; // 10% padding at the bottom
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          clipData: FlClipData.all(), // Ensures lines do not exit the chart area
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.orangeAccent,
              tooltipRoundedRadius: 8,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                  final value = spot.y;
                  final valueString = value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2);

                  return LineTooltipItem(
                    '$formattedDate\n$valueString',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                getTitlesWidget: (value, meta) {
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  String formattedDate = DateFormat('dd/MM').format(date);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                },
                reservedSize: 50,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: flSpots,
              isCurved: false, // Lines are direct, not rounded
              color: Colors.orangeAccent,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.orangeAccent.withOpacity(0.3),
                    Colors.orangeAccent.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _formatLiquidAddress(String address) {
    if (address.isEmpty) return 'N/A';
    final start = address.substring(0, 6);
    final end = address.substring(address.length - 6);
    return '$start...$end';
  }

  Widget _buildTierIcon(BuildContext context, String label, IconData icon, Decimal totalValue, Decimal threshold, double width, double height, WidgetRef ref) {
    final isUnlocked = totalValue >= threshold;
    final iconColor = isUnlocked ? Colors.orange : Colors.grey;

    return GestureDetector(
      onTap: () {
        _showTierInfoModal(context, label, totalValue, threshold, isUnlocked, width, height, ref);
      },
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: iconColor, child: Icon(icon, color: Colors.black, size: width * 0.06)),
          SizedBox(height: height * 0.01),
          Text(label, style: TextStyle(color: iconColor, fontSize: width * 0.03)),
        ],
      ),
    );
  }

  void _showCreateBottomModal(BuildContext context, String title, WidgetRef ref) {
    final TextEditingController liquidAddressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.orange,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                TextField(
                  controller: liquidAddressController,
                  decoration: InputDecoration(labelText: 'Liquid Address to receive commission'.i18n(ref), labelStyle: const TextStyle(color: Colors.black), border: const OutlineInputBorder(), fillColor: Colors.orange, filled: true),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomElevatedButton(
                    text: 'Submit'.i18n(ref),
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      Affiliate affiliate = Affiliate(
                        createdAffiliateCode: "",
                        createdAffiliateLiquidAddress: liquidAddressController.text,
                        insertedAffiliateCode: ref.watch(affiliateProvider).insertedAffiliateCode,
                      );
                      try {
                        context.pop();
                        ref.read(loadingProvider.notifier).state = true;
                        await ref.read(createAffiliateCodeProvider(affiliate).future);
                        Fluttertoast.showToast(
                          msg: 'Affiliate code created successfully'.i18n(ref),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        ref.read(loadingProvider.notifier).state = false;
                      } catch (e) {
                        ref.read(loadingProvider.notifier).state = false;
                        Fluttertoast.showToast(
                          msg: e.toString(),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTierInfoModal(BuildContext context, String label, Decimal totalValue, Decimal threshold, bool isUnlocked, double width, double height, WidgetRef ref) {
    String diamondSpecialCode = 'Contact our support to get a custom affiliate code'.i18n(ref);
    String feeInfo = isUnlocked
        ? (totalValue >= Decimal.parse('20000')
        ? "Current fee is 1% per affiliate in perpetuity.".i18n(ref)
        : "Current fee is 0.2% per affiliate in perpetuity until you reach 20K in value purchased by your referrals.".i18n(ref))
        : "You have not unlocked the $label tier yet. Unlock it by reaching ${threshold.toString()} in value purchased by your referrals.".i18n(ref);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(width * 0.05),
          decoration: const BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info, size: width * 0.1, color: Colors.black),
              SizedBox(height: height * 0.02),
              Text(isUnlocked ? 'You are $label!'.i18n(ref) : 'Tier Locked'.i18n(ref),
                  style: TextStyle(fontSize: width * 0.06, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: height * 0.02),
              if (label == 'Diamond'.i18n(ref) && isUnlocked) Text(diamondSpecialCode, style: TextStyle(fontSize: width * 0.03, color: Colors.black), textAlign: TextAlign.center),
              SizedBox(height: height * 0.02),
              Text(
                isUnlocked
                    ? 'With '.i18n(ref) + totalValue.toString() + ' DEPIX, you have reached the '.i18n(ref) + label
                    : 'You need ${threshold.toString()} DEPIX to unlock the $label tier.'.i18n(ref),
                style: const TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.02),
              Text(feeInfo, style: TextStyle(fontSize: width * 0.03, color: Colors.black), textAlign: TextAlign.center),
              SizedBox(height: height * 0.02),
              TextButton(onPressed: () => context.pop(), child: Text('Close'.i18n(ref), style: TextStyle(color: Colors.black, fontSize: width * 0.04))),
            ],
          ),
        );
      },
    );
  }
}

class ChartData {
  final DateTime x;
  final Decimal y;
  ChartData(this.x, this.y);
}
