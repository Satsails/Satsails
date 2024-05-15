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
    final status = ref.watch(sideswapStatusDetailsItemProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Details'.i18n(ref), style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: status.when(
        data: (status) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                _buildListTile("Order ID".i18n(ref), status.orderId ?? "Error".i18n(ref), Icons.swap_calls_rounded),
                _buildListTile("Received at".i18n(ref), status.addrRecv ?? "Error".i18n(ref), Icons.account_balance_wallet_rounded),
                ...(status.list?.map((SideswapPegStatusTransaction e) {
                  return Column(
                    children: [
                      _buildListTile("Send Transaction".i18n(ref), e.txHash ?? "Error".i18n(ref), Icons.send_and_archive_rounded),
                      _buildListTile("Received Transaction".i18n(ref), e.payoutTxid ?? "No Information".i18n(ref), Icons.call_received),
                      _buildListTile("Amount sent".i18n(ref), e.amount.toString(), Icons.schedule_send_rounded),
                      _buildListTile("Amount received".i18n(ref), e.payout?.toString() ?? "0", Icons.receipt_long),
                      _buildTxStatusTile(e, ref),
                    ],
                  );
                }).toList() ?? [Text('No transactions found. Check back later.'.i18n(ref), style: TextStyle(fontSize: 18))]),
              ],
            ),
          );
        },
        loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange)),
        error: (error, stackTrace) => Center(child: Text('Error: $error', style: const TextStyle(fontSize: 18, color: Colors.red))),
      ),
    );
  }

  ListTile _buildListTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orangeAccent),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Clipboard.setData(ClipboardData(text: subtitle));
      },
    );
  }

  ListTile _buildTxStatusTile(SideswapPegStatusTransaction status, WidgetRef ref) {
    switch (status.txState) {
      case 'InsufficientAmount':
        return _buildListTile("Status".i18n(ref), "Insufficient Amount".i18n(ref), Icons.error);
      case 'Detected':
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.black),
          title: Text("Confirmations".i18n(ref), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text("${status.detectedConfs} ${"Detected".i18n(ref)}", style: const TextStyle(fontSize: 16)),
          trailing: Text("${status.totalConfs} ${"Needed".i18n(ref)}", style: const TextStyle(fontSize: 16)),
        );
      case 'Processing':
        return _buildListTile("Status", "Processing".i18n(ref), Icons.hourglass_empty);
      case 'Done':
        return _buildListTile("Status", "Done".i18n(ref), Icons.check_circle);
      default:
        return _buildListTile("Status", "Unknown".i18n(ref), Icons.help);
    }
  }
}