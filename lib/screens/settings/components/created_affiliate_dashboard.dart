import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import for Syncfusion charts

class CreatedAffiliateWidget extends ConsumerWidget {
  const CreatedAffiliateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affiliateData = ref.watch(affiliateProvider);
    final user = ref.watch(userProvider);
    final numberOfInstall = ref.watch(numberOfAffiliateInstallsProvider);
    final earnings = ref.watch(affiliateEarningsProvider);
    final totalValuePurchased = ref.watch(getTotalValuePurchasedByAffiliateUsersProvider);
    final allTransfers = ref.watch(getAllTransfersFromAffiliateUsersProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              totalValuePurchased.when(
                data: (totalValue) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTierIcon(context, 'Bronze', Icons.vpn_key, double.parse(totalValue), 1000.0),
                      _buildTierIcon(context, 'Silver', Icons.military_tech, double.parse(totalValue), 2000.0),
                      _buildTierIcon(context, 'Gold', Icons.emoji_events, double.parse(totalValue), 5000.0),
                      _buildTierIcon(context, 'Diamond', Icons.diamond, double.parse(totalValue), 10000.0),
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
              Container(
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
                  children: [
                    const Text(
                      'Your Affiliate Code',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      affiliateData.code ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Linked to: ${affiliateData.liquidAddress.isEmpty ? 'N/A' : affiliateData.liquidAddress.substring(0, 10) + '...'}',
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              earnings.when(
                data: (data) {
                  return Column(
                    children: [
                      const Text(
                        'Earnings',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$data DPIX',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierIcon(BuildContext context, String label, IconData icon, double totalValue, double threshold) {
    final isUnlocked = totalValue >= threshold;
    final iconColor = isUnlocked ? Colors.orange : Colors.grey;

    return GestureDetector(
      onTap: isUnlocked
          ? () {
        _showTierInfoModal(context, label, totalValue, threshold);
      }
          : null,
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

  void _showTierInfoModal(BuildContext context, String label, double totalValue, double threshold) {
    String feeInfo = totalValue >= 20000
        ? "Current fee is 1% per affiliate in perpetuity."
        : "Current fee is 0.2% per affiliate in perpetuity until you reach 20K in value transacted, then it goes to 1%.";

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
                'You are $label!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'With $totalValue DPIX, you have reached the $label tier.',
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

  Widget _buildSyncfusionChart(List<dynamic> transfersData) {
    List<ChartData> chartData = transfersData
        .map((entry) => ChartData(double.parse(entry.key), entry.value.toDouble()))
        .toList();

    return SizedBox(
      height: 200,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <LineSeries<ChartData, double>>[
          LineSeries<ChartData, double>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final double x;
  final double y;

  ChartData(this.x, this.y);
}
