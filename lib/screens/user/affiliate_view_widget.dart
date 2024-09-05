import 'package:Satsails/models/affiliate_model.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AffiliateViewWidget extends ConsumerWidget {
  const AffiliateViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affiliateData = ref.watch(affiliateProvider);
    final user = ref.watch(userProvider);
    final hasInsertedAffiliate = user.hasInsertedAffiliate;
    final hasCreatedAffiliate = user.hasCreatedAffiliate;
    final numberOfInstall = ref.watch(numberOfAffiliateInstallsProvider);
    final earnings = ref.watch(affiliateEarningsProvider);
    final totalValuePurchased = ref.watch(getTotalValuePurchasedByAffiliateUsersProvider);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child:Scaffold(
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
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hasCreatedAffiliate) ...[
                    totalValuePurchased.when(
                      data: (totalValue) {
                        final totalValueDecimal = Decimal.parse(totalValue.toString());
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTierIcon(context, 'Bronze', Icons.vpn_key, totalValueDecimal, Decimal.parse('0'), width, height),
                            _buildTierIcon(context, 'Silver', Icons.military_tech, totalValueDecimal, Decimal.parse('2500'), width, height),
                            _buildTierIcon(context, 'Gold', Icons.emoji_events, totalValueDecimal, Decimal.parse('5000'), width, height),
                            _buildTierIcon(context, 'Diamond', Icons.diamond, totalValueDecimal, Decimal.parse('20000'), width, height),
                          ],
                        );
                      },
                      loading: () => _loadingWidget(context, height),
                      error: (error, stackTrace) => _errorWidget(error),
                    ),
                    SizedBox(height: height * 0.01),
                    _buildAffiliateInfo(affiliateData, width, height),
                    SizedBox(height: height * 0.01),
                    earnings.when(
                      data: (data) => _buildEarningsInfo(Decimal.parse(data.toString()), width, height),
                      loading: () => _loadingWidget(context, height),
                      error: (error, stackTrace) => _errorWidget(error),
                    ),
                    SizedBox(height: height * 0.02),
                    numberOfInstall.when(
                      data: (installs) => _buildInstallationsInfo(installs, width, height),
                      loading: () => _loadingWidget(context, height),
                      error: (error, stackTrace) => _errorWidget(error),
                    ),
                    SizedBox(height: height * 0.02),
                    CustomElevatedButton(
                      text: "Show Earnings Over Time",
                      onPressed: () => _showGraphBottomModal(context, ref),
                    ),
                  ] else if (!hasCreatedAffiliate && hasInsertedAffiliate) ...[
                    _buildInsertedAffiliateSection(affiliateData, width, height),
                    const SizedBox(height: 20),
                    const Text('Would you like to become an affiliate?', style: TextStyle(color: Colors.white, fontSize: 18)),
                    const SizedBox(height: 10),
                    CustomElevatedButton(
                      text: 'Create Affiliate Code',
                      onPressed: () => _showCreateBottomModal(context, 'Create Affiliate Code', ref),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingWidget(BuildContext context, double height) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(size: height * 0.1, color: Colors.orange),
    );
  }

  Widget _errorWidget(Object error) {
    return Center(
      child: Text('There was an error, please contact support: $error', style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildAffiliateInfo(Affiliate affiliateData, double width, double height) {
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
          Text('Your Affiliate Code to Share', style: TextStyle(color: Colors.black, fontSize: width * 0.03)),
          SizedBox(height: height * 0.01),
          Text(affiliateData.createdAffiliateCode, style: TextStyle(color: Colors.black, fontSize: width * 0.06)),
          SizedBox(height: height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Registered:', style: TextStyle(color: Colors.black, fontSize: width * 0.03)),
              const SizedBox(width: 2),
              Text(_formatLiquidAddress(affiliateData.createdAffiliateLiquidAddress), style: TextStyle(color: Colors.black, fontSize: width * 0.03)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsInfo(Decimal earningsDecimal, double width, double height) {
    return Column(
      children: [
        Text('Total Earnings', style: TextStyle(color: Colors.white, fontSize: width * 0.04)),
        SizedBox(height: height * 0.01),
        Text('$earningsDecimal DEPIX', style: TextStyle(color: Colors.white, fontSize: width * 0.06, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInstallationsInfo(int installs, double width, double height) {
    return Column(
      children: [
        Text('Number of Installations', style: TextStyle(color: Colors.white, fontSize: width * 0.04)),
        SizedBox(height: height * 0.02),
        Text(installs.toString(), style: TextStyle(color: Colors.white, fontSize: width * 0.06, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInsertedAffiliateSection(Affiliate affiliateData, double width, double height) {
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
          Text('You were referred by', style: TextStyle(color: Colors.black, fontSize: width * 0.03)),
          SizedBox(height: height * 0.01),
          Text(affiliateData.insertedAffiliateCode, style: TextStyle(color: Colors.black, fontSize: width * 0.06)),
        ],
      ),
    );
  }

  void _showGraphBottomModal(BuildContext context, WidgetRef ref) {
    final allTransfers = ref.watch(getAllTransfersFromAffiliateUsersProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black, // Set the modal background to black
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Earnings Over Time', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              allTransfers.when(
                data: (transfersData) => _buildSyncfusionChart(transfersData, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                loading: () => _loadingWidget(context, MediaQuery.of(context).size.height * 0.1),
                error: (error, stackTrace) => _errorWidget(error),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSyncfusionChart(List<ParsedTransfer> transfersData, double width, double height) {
    List<ChartData> chartData = transfersData.map((transfer) {
      final timestamp = DateTime.parse(transfer.timestamp);
      final amount = double.parse(transfer.amount_payed_to_affiliate);
      return ChartData(timestamp, amount);
    }).toList();

    return SfCartesianChart(
      backgroundColor: Colors.transparent,
      primaryXAxis: DateTimeAxis(isVisible: true, majorGridLines: MajorGridLines(width: 0), axisLine: AxisLine(width: 0), labelStyle: TextStyle(color: Colors.white)),
      primaryYAxis: NumericAxis(isVisible: true, majorGridLines: MajorGridLines(width: 0), axisLine: AxisLine(width: 0), labelStyle: TextStyle(color: Colors.white)),
      series: <LineSeries<ChartData, DateTime>>[
        LineSeries<ChartData, DateTime>(
          dataSource: chartData,
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.y,
          color: Colors.orange,
          name: 'Affiliate Earnings',
        ),
      ],
    );
  }

  String _formatLiquidAddress(String address) {
    if (address.isEmpty) return 'N/A';
    final start = address.substring(0, 6);
    final end = address.substring(address.length - 6);
    return '$start...$end';
  }

  Widget _buildTierIcon(BuildContext context, String label, IconData icon, Decimal totalValue, Decimal threshold, double width, double height) {
    final isUnlocked = totalValue >= threshold;
    final iconColor = isUnlocked ? Colors.orange : Colors.grey;

    return GestureDetector(
      onTap: () {
        _showTierInfoModal(context, label, totalValue, threshold, isUnlocked, width, height);
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
    final TextEditingController _affiliateController = TextEditingController();
    final TextEditingController _liquidAddressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.orange, // Set the modal background to orange
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
                  controller: _liquidAddressController,
                  decoration: const InputDecoration(labelText: 'Liquid Address', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder(), fillColor: Colors.orange, filled: true),
                  style: const TextStyle(color: Colors.black),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                TextField(
                  controller: _affiliateController,
                  decoration: const InputDecoration(labelText: 'Affiliate Code', labelStyle: TextStyle(color: Colors.black), border: OutlineInputBorder(), fillColor: Colors.orange, filled: true),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomElevatedButton(
                    text: 'Submit',
                    textColor: Colors.white,
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      final hasInserted = ref.watch(affiliateProvider).insertedAffiliateCode.isNotEmpty;
                      Affiliate affiliate = Affiliate(
                        createdAffiliateCode: _affiliateController.text,
                        createdAffiliateLiquidAddress: _liquidAddressController.text,
                        insertedAffiliateCode: hasInserted ? ref.watch(affiliateProvider).insertedAffiliateCode : _affiliateController.text,
                      );
                      try {
                        await ref.read(createAffiliateCodeProvider(affiliate).future);
                        Fluttertoast.showToast(msg: 'Affiliate code created successfully', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                        Navigator.pop(context);
                      } catch (e) {
                        Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
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

  void _showTierInfoModal(BuildContext context, String label, Decimal totalValue, Decimal threshold, bool isUnlocked, double width, double height) {
    String feeInfo = isUnlocked
        ? (totalValue >= Decimal.parse('20000') ? "Current fee is 1% per affiliate in perpetuity." : "Current fee is 0.2% per affiliate in perpetuity until you reach 20K in value transacted, then it goes to 1%.")
        : "You have not unlocked the $label tier yet. Unlock it by reaching ${threshold.toString()} in value transacted.";

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
              Text(isUnlocked ? 'You are $label!' : 'Tier Locked', style: TextStyle(fontSize: width * 0.06, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: height * 0.02),
              Text(isUnlocked ? 'With $totalValue DEPIX, you have reached the $label tier.' : 'You need ${threshold.toString()} DEPIX to unlock the $label tier.', style: const TextStyle(fontSize: 16, color: Colors.black), textAlign: TextAlign.center),
              SizedBox(height: height * 0.02),
              Text(feeInfo, style: TextStyle(fontSize: width * 0.03, color: Colors.black), textAlign: TextAlign.center),
              SizedBox(height: height * 0.02),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: TextStyle(color: Colors.black, fontSize: width * 0.04))),
            ],
          ),
        );
      },
    );
  }
}

class ChartData {
  final DateTime x;
  final double y;
  ChartData(this.x, this.y);
}
