import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/models/sideswap_peg_model.dart';
import 'package:satsails/providers/sideswap_provider.dart';

class SwapDetails extends ConsumerWidget {
  final SideswapPegStatus swap;

  SwapDetails({required this.swap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(sideswapStatusDetailsItemProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: status.when(
        data: (status) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                _buildListTile("Order ID", status.orderId ?? "Error", Icons.swap_calls_rounded),
                _buildListTile("Received at", status.addrRecv ?? "Error", Icons.account_balance_wallet_rounded),
                ...(status.list?.map((SideswapPegStatusTransaction e) {
                  return Column(
                    children: [
                      _buildListTile("Send Transaction", e.txHash ?? "Error", Icons.send_and_archive_rounded),
                      _buildListTile("Received Transaction", e.payoutTxid ?? "No Information", Icons.call_received),
                      _buildListTile("Amount sent", e.amount.toString(), Icons.schedule_send_rounded),
                      _buildListTile("Amount received", e.payout?.toString() ?? "0", Icons.receipt_long),
                      _buildTxStatusTile(e),
                    ],
                  );
                }).toList() ?? [const Text('No transactions found. Check back later.', style: TextStyle(fontSize: 18))]),
              ],
            ),
          );
        },
        loading: () => Center(child: LoadingAnimationWidget.threeArchedCircle(size: 200, color: Colors.orange)),
        error: (error, stackTrace) => Center(child: Text('Error: $error', style: TextStyle(fontSize: 18, color: Colors.red))),
      ),
    );
  }

  ListTile _buildListTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 16)),
      onTap: () {
        Clipboard.setData(ClipboardData(text: subtitle));
      },
    );
  }

  ListTile _buildTxStatusTile(SideswapPegStatusTransaction status) {
    switch (status.txState) {
      case 'InsufficientAmount':
        return _buildListTile("Status", "Insufficient Amount", Icons.error);
      case 'Detected':
        return ListTile(
          leading: Icon(Icons.search, color: Colors.black),
          title: const Text("Confirmations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text("${status.detectedConfs} Detected", style: TextStyle(fontSize: 16)),
          trailing: Text("${status.totalConfs} Needed", style: TextStyle(fontSize: 16)),
        );
      case 'Processing':
        return _buildListTile("Status", "Processing", Icons.hourglass_empty);
      case 'Done':
        return _buildListTile("Status", "Done", Icons.check_circle);
      default:
        return _buildListTile("Status", "Unknown", Icons.help);
    }
  }
}