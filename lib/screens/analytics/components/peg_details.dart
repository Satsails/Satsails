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

  const PegDetails({super.key, required this.swap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final status = ref.watch(sideswapStatusDetailsItemProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Details'.i18n, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: status.when(
        data: (status) {
          return Padding(
            padding: EdgeInsets.all(screenWidth * 0.02), // 2% of screen width
            child: ListView(
              children: [
                _buildListTile("Order ID".i18n, status.orderId ?? "Error".i18n, Icons.swap_calls_rounded, screenWidth),
                _buildListTile("Received at".i18n, status.addrRecv ?? "Error".i18n, Icons.account_balance_wallet_rounded, screenWidth),
                ...(status.list?.map((SideswapPegStatusTransaction e) {
                  return Column(
                    children: [
                      _buildListTile("Send Transaction".i18n, e.txHash ?? "Error".i18n, Icons.send_and_archive_rounded, screenWidth),
                      _buildListTile("Received Transaction".i18n, e.payoutTxid ?? "No Information".i18n, Icons.call_received, screenWidth),
                      _buildListTile("Amount sent".i18n, btcInDenominationFormatted(e.amount!.toDouble(), btcFormat), Icons.schedule_send_rounded, screenWidth),
                      _buildListTile("Amount received".i18n, btcInDenominationFormatted(e.payout!.toDouble() ?? 0, btcFormat), Icons.receipt_long, screenWidth),
                      _buildTxStatusTile(e, ref, screenWidth),
                    ],
                  );
                }).toList() ?? [Text('No transactions found. Check back later.'.i18n, style: TextStyle(fontSize: screenWidth * 0.05))]),
              ],
            ),
          );
        },
        loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: screenWidth * 0.5, color: Colors.orange)),
        error: (error, stackTrace) => Center(child: Text('Error: $error Contact the developer (in the settings) about this', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.red))),
      ),
    );
  }

  ListTile _buildListTile(String title, String subtitle, IconData icon, double screenWidth) {
    return ListTile(
      leading: Icon(icon, color: Colors.orangeAccent),
      title: Text(title, style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white)),
      onTap: () {
        Clipboard.setData(ClipboardData(text: subtitle));
      },
    );
  }

  ListTile _buildTxStatusTile(SideswapPegStatusTransaction status, WidgetRef ref, double screenWidth) {
    switch (status.txState) {
      case 'InsufficientAmount':
        return _buildListTile("Status".i18n, "Insufficient Amount".i18n, Icons.error, screenWidth);
      case 'Detected':
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.orange),
          title: Text("Confirmations".i18n, style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.white)),
          subtitle: Text("${status.detectedConfs ?? 0} ${"Detected".i18n}", style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white)),
          trailing: Text("${status.totalConfs ?? 0} ${"Needed".i18n}", style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white)),
        );
      case 'Processing':
        return _buildListTile("Status", "Processing".i18n, Icons.hourglass_empty, screenWidth);
      case 'Done':
        return _buildListTile("Status", "Done".i18n, Icons.check_circle, screenWidth);
      default:
        return _buildListTile("Status", "Unknown".i18n, Icons.help, screenWidth);
    }
  }
}
