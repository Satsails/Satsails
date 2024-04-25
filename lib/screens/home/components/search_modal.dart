import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/providers/transaction_search_provider.dart';

class SearchModal extends ConsumerWidget {
  SearchModal({super.key});

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiquid = ref.watch(transactionSearchProvider).isLiquid;
    final transactionHash = ref.watch(transactionSearchProvider).txid;
    final amount = ref.watch(transactionSearchProvider).amount;
    final assetId = ref.watch(transactionSearchProvider).assetId;
    final amountBlinder = ref.watch(transactionSearchProvider).amountBlinder;
    final assetBlinder = ref.watch(transactionSearchProvider).assetBlinder;

    final uri = (isLiquid == null || transactionHash == null) ? 'https://mempool.space' : (isLiquid! ? 'https://liquid.network/tx/$transactionHash#blinded=$amount,$assetId,$amountBlinder,$assetBlinder' : 'https://mempool.space/tx/$transactionHash');
    controller.loadRequest(Uri.parse(uri));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29,31,49,1.0),
        title: const Text('Search the blockchain', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}