import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';

class SearchModal extends ConsumerStatefulWidget {
  const SearchModal({super.key});

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
    final unblindedUrl = ref.read(transactionSearchProvider).unblindedUrl;

    final uri = (isLiquid == null || transactionHash == null)
        ? 'https://mempool.space'
        : (isLiquid
        ? (unblindedUrl == null
        ? 'https://liquid.network/tx/$transactionHash'
        : 'https://liquid.network/$unblindedUrl')
        : 'https://mempool.space/tx/$transactionHash');

    controller.loadRequest(Uri.parse(uri));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(29, 31, 49, 1.0),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(29, 31, 49, 1.0),
          title: Text(
            'Search the blockchain'.i18n,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
