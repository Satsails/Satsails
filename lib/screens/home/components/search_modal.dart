import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchModal extends StatelessWidget {
  final bool isLiquid;
  final String transactionHash;
  SearchModal({Key? key, required this.isLiquid, required this.transactionHash}) : super(key: key);


  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted);

  @override
  Widget build(BuildContext context) {
    final uri = isLiquid ? 'https://liquid.network/tx/$transactionHash' : 'https://mempool.space/tx/$transactionHash';
    controller.loadRequest(Uri.parse(uri));
    return DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController scrollController) {
          return WebViewWidget(
            controller: controller,
          );
        });
  }
}
