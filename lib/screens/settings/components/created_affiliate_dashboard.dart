import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CreatedAffiliateWidget extends ConsumerWidget {
  const CreatedAffiliateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affiliateData = ref.watch(affiliateProvider);
    final numberOfInstall = ref.watch(numberOfAffiliateInstallsProvider);
    final earnings = ref.watch(affiliateEarningsProvider);
    final totalValuePurchased = ref.watch(getTotalValuePurchasedByAffiliateUsersProvider);
    final allTransfers = ref.watch(getAllTransfersFromAffiliateUsersProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Affiliate Section', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                totalValuePurchased.when(
                  data: (totalValue) {
                    final totalValueDecimal = Decimal.parse(totalValue.toString());
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTierIcon(context, 'Bronze', Icons.vpn_key, totalValueDecimal, Decimal.parse('0')),
                        _buildTierIcon(context, 'Silver', Icons.military_tech, totalValueDecimal, Decimal.parse('2500')),
                        _buildTierIcon(context, 'Gold', Icons.emoji_events, totalValueDecimal, Decimal.parse('5000')),
                        _buildTierIcon(context, 'Diamond', Icons.diamond, totalValueDecimal, Decimal.parse('20000')),
                      ],
                    );
                  },
                  loading: () => LoadingAnimationWidget.threeArchedCircle(
                    size: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.orange,
                  ),
                  error: (error, stackTrace) {
                    return Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Affiliate Code Section - Full-width card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade300, Colors.orange.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Affiliate Code',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        affiliateData.code,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Only show the beginning and end of liquid address
                      Text(
                        _formatLiquidAddress(affiliateData.liquidAddress),
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                earnings.when(
                  data: (data) {
                    final earningsDecimal = Decimal.parse(data.toString());
                    return Column(
                      children: [
                        const Text(
                          'Earnings',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$earningsDecimal DPIX',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                  loading: () => LoadingAnimationWidget.threeArchedCircle(
                    size: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.orange,
                  ),
                  error: (error, stackTrace) {
                    return Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    );
                  },
                ),
                const SizedBox(height: 20),
                numberOfInstall.when(
                  data: (installs) {
                    return Column(
                      children: [
                        const Text(
                          'Number of Installations',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          installs.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => LoadingAnimationWidget.threeArchedCircle(
                    size: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.orange,
                  ),
                  error: (error, stackTrace) {
                    return Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    );
                  },
                ),
                const SizedBox(height: 20),
                allTransfers.when(
                  data: (transfersData) {
                    return _buildSyncfusionChart(transfersData);
                  },
                  loading: () => LoadingAnimationWidget.threeArchedCircle(
                    size: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.orange,
                  ),
                  error: (error, stackTrace) {
                    return Text(
                      'Error: $error',
                      style: const TextStyle(color: Colors.red),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to format the liquid address
  String _formatLiquidAddress(String address) {
    if (address.isEmpty) return 'N/A';
    final start = address.substring(0, 6);
    final end = address.substring(address.length - 6);
    return '$start...$end';
  }

  Widget _buildTierIcon(BuildContext context, String label, IconData icon, Decimal totalValue, Decimal threshold) {
    final isUnlocked = totalValue >= threshold;
    final iconColor = isUnlocked ? Colors.orange : Colors.grey;

    return GestureDetector(
      onTap: () {
        _showTierInfoModal(context, label, totalValue, threshold, isUnlocked);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.black, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: iconColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showTierInfoModal(BuildContext context, String label, Decimal totalValue, Decimal threshold, bool isUnlocked) {
    String feeInfo = isUnlocked
        ? (totalValue >= Decimal.parse('20000')
        ? "Current fee is 1% per affiliate in perpetuity."
        : "Current fee is 0.2% per affiliate in perpetuity until you reach 20K in value transacted, then it goes to 1%.")
        : "You have not unlocked the $label tier yet. Unlock it by reaching ${threshold.toString()} in value transacted.";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info, size: 50, color: Colors.black),
              const SizedBox(height: 16),
              Text(
                isUnlocked ? 'You are $label!' : 'Tier Locked',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isUnlocked
                    ? 'With $totalValue DPIX, you have reached the $label tier.'
                    : 'You need ${threshold.toString()} DPIX to unlock the $label tier.',
                style: const TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                feeInfo,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSyncfusionChart(List<ParsedTransfer> transfersData) {
    List<ChartData> chartData = transfersData
        .map((transfer) {
      final timestamp = DateTime.parse(transfer.timestamp);
      final amount = double.parse(transfer.amount_payed_to_affiliate);
      return ChartData(
        timestamp,  // DateTime here
        amount,
      );
    })
        .toList();

    if (transfersData.isEmpty) {
      return Container();
    }

    return SfCartesianChart(
      backgroundColor: Colors.transparent,
      title: ChartTitle(
        text: 'Your Earnings Over Time',
        textStyle: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      primaryXAxis: DateTimeAxis( // Use DateTimeAxis for proper date display
        isVisible: true,
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 0),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      primaryYAxis: NumericAxis(
        isVisible: true,
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 0),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        tooltipSettings: const InteractiveTooltip(
          enable: true,
          color: Colors.orangeAccent,
          textStyle: TextStyle(color: Colors.white),
        ),
      ),
      series: <LineSeries<ChartData, DateTime>>[ // Use DateTime for xValueMapper
        LineSeries<ChartData, DateTime>(
          dataSource: chartData,
          xValueMapper: (ChartData sales, _) => sales.x,  // DateTime here
          yValueMapper: (ChartData sales, _) => sales.y,
          color: Colors.orange,
          name: 'Affiliate Earnings',
        ),
      ],
    );
  }
}

class ChartData {
  final DateTime x;  // Change this to DateTime
  final double y;

  ChartData(this.x, this.y);
}
