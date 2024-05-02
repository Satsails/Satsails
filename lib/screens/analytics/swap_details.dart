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
                _buildListTile("Order ID", status.orderId ?? "Error"),
                _buildListTile("Received at", status.addrRecv ?? "Error"),
                ...(status.list?.map((SideswapPegStatusTransaction e) {
                  return Column(
                    children: [
                      _buildListTile("Send Transaction", e.txHash ?? "Error"),
                      _buildListTile("Received Transaction", e.payoutTxid ?? "Error"),
                      _buildListTile("Amount sent", e.amount.toString()),
                      _buildListTile("Amount received", e.payout.toString()),
                      _buildListTile("Status", e.status ?? "Error"),
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

  ListTile _buildListTile(String title, String subtitle) {
    return ListTile(
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
        return _buildListTile("Status", "Insufficient Amount");
      case 'Detected':
        return ListTile(
          title: const Text("Confirmations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text("${status.detectedConfs} Detected", style: TextStyle(fontSize: 16)),
          trailing: Text("${status.totalConfs} Total needed", style: TextStyle(fontSize: 16)),
        );
      case 'Processing':
        return _buildListTile("Status", "Processing");
      case 'Done':
        return _buildListTile("Status", "Done");
      default:
        return _buildListTile("Status", "Unknown");
    }
  }
}