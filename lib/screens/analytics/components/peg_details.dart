import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/providers/sideswap_provider.dart';

class PegDetails extends ConsumerWidget {
  final SideswapPegStatus swap;

  const PegDetails({Key? key, required this.swap}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final status = ref.watch(sideswapStatusDetailsItemProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Details'.i18n(ref), style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.05)), // 5% of screen width
        backgroundColor: Colors.white,
      ),
      body: status.when(
        data: (status) {
          return Padding(
            padding: EdgeInsets.all(screenWidth * 0.02), // 2% of screen width
            child: ListView(
              children: [
                _buildListTile("Order ID".i18n(ref), status.orderId ?? "Error".i18n(ref), Icons.swap_calls_rounded, screenWidth),
                _buildListTile("Received at".i18n(ref), status.addrRecv ?? "Error".i18n(ref), Icons.account_balance_wallet_rounded, screenWidth),
                ...(status.list?.map((SideswapPegStatusTransaction e) {
                  return Column(
                    children: [
                      _buildListTile("Send Transaction".i18n(ref), e.txHash ?? "Error".i18n(ref), Icons.send_and_archive_rounded, screenWidth),
                      _buildListTile("Received Transaction".i18n(ref), e.payoutTxid ?? "No Information".i18n(ref), Icons.call_received, screenWidth),
                      _buildListTile("Amount sent".i18n(ref), btcInDenominationFormatted(e.amount!.toDouble(), btcFormat), Icons.schedule_send_rounded, screenWidth),
                      _buildListTile("Amount received".i18n(ref), btcInDenominationFormatted(e.payout!.toDouble() ?? 0, btcFormat), Icons.receipt_long, screenWidth),
                      _buildTxStatusTile(e, ref, screenWidth),
                    ],
                  );
                }).toList() ?? [Text('No transactions found. Check back later.'.i18n(ref), style: TextStyle(fontSize: screenWidth * 0.05))]), // 5% of screen width
              ],
            ),
          );
        },
        loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: screenWidth * 0.5, color: Colors.orange)), // 50% of screen width
        error: (error, stackTrace) => Center(child: Text('Error: $error Contact the developer (in the settings) about this', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.red))), // 5% of screen width
      ),
    );
  }

  ListTile _buildListTile(String title, String subtitle, IconData icon, double screenWidth) {
    return ListTile(
      leading: Icon(icon, color: Colors.orangeAccent),
      title: Text(title, style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)), // 5% of screen width
      subtitle: Text(subtitle, style: TextStyle(fontSize: screenWidth * 0.04)), // 4% of screen width
      onTap: () {
        Clipboard.setData(ClipboardData(text: subtitle));
      },
    );
  }

  ListTile _buildTxStatusTile(SideswapPegStatusTransaction status, WidgetRef ref, double screenWidth) {
    switch (status.txState) {
      case 'InsufficientAmount':
        return _buildListTile("Status".i18n(ref), "Insufficient Amount".i18n(ref), Icons.error, screenWidth);
      case 'Detected':
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.black),
          title: Text("Confirmations".i18n(ref), style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)), // 5% of screen width
          subtitle: Text("${status.detectedConfs} ${"Detected".i18n(ref)}", style: TextStyle(fontSize: screenWidth * 0.04)), // 4% of screen width
          trailing: Text("${status.totalConfs} ${"Needed".i18n(ref)}", style: TextStyle(fontSize: screenWidth * 0.04)), // 4% of screen width
        );
      case 'Processing':
        return _buildListTile("Status", "Processing".i18n(ref), Icons.hourglass_empty, screenWidth);
      case 'Done':
        return _buildListTile("Status", "Done".i18n(ref), Icons.check_circle, screenWidth);
      default:
        return _buildListTile("Status", "Unknown".i18n(ref), Icons.help, screenWidth);
    }
  }
}