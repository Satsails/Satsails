import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';

class SearchModal extends ConsumerStatefulWidget {
  SearchModal({super.key});

  @override
  _SearchModalState createState() => _SearchModalState();
}

class _SearchModalState extends ConsumerState<SearchModal> with AutomaticKeepAliveClientMixin {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _loadUrl();
  }

  void _loadUrl() {
    final isLiquid = ref.read(transactionSearchProvider).isLiquid;
    final transactionHash = ref.read(transactionSearchProvider).txid;
    final amount = ref.read(transactionSearchProvider).amount;
    final assetId = ref.read(transactionSearchProvider).assetId;
    final amountBlinder = ref.read(transactionSearchProvider).amountBlinder;
    final assetBlinder = ref.read(transactionSearchProvider).assetBlinder;

    final uri = (isLiquid == null || transactionHash == null)
        ? 'https://mempool.space'
        : (isLiquid
        ? 'https://liquid.network/tx/$transactionHash#blinded=$amount,$assetId,$amountBlinder,$assetBlinder'
        : 'https://mempool.space/tx/$transactionHash');
    controller.loadRequest(Uri.parse(uri));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important to call super.build when using AutomaticKeepAliveClientMixin
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 31, 49, 1.0),
        title: Text(
          'Search the blockchain',
          style: TextStyle(color: Colors.white, fontSize: screenHeight * 0.03), // 3% of screen height
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: screenHeight * 0.03), // 3% of screen height
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
