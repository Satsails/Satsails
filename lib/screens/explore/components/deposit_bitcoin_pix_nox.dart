import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DepositBitcoinPixNox extends ConsumerStatefulWidget {
  const DepositBitcoinPixNox({super.key});

  @override
  _DepositBitcoinPixNoxState createState() => _DepositBitcoinPixNoxState();
}

class _DepositBitcoinPixNoxState extends ConsumerState<DepositBitcoinPixNox> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Method to handle the input.
  void _handleInput() async {
    final amount = _amountController.text;
    // Retrieve the URL from your provider.
    final url = await ref.read(createNoxTransferRequestProvider(amount).future);
    if (url.isNotEmpty) {
      // Open the URL in a full-screen web view.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DepositWebViewPage(url: url),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Pix'.i18n,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Amount entry field.
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.transparent, width: 2.0),
                    ),
                    labelText: 'Insert amount'.i18n,
                    labelStyle: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              // Button to handle the input.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.2.sw),
                child: CustomButton(
                  onPressed: _handleInput,
                  primaryColor: Colors.orange,
                  secondaryColor: Colors.orange,
                  text: 'Purchase'.i18n,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DepositWebViewPage extends StatefulWidget {
  final String url;
  const DepositWebViewPage({super.key, required this.url});

  @override
  _DepositWebViewPageState createState() => _DepositWebViewPageState();
}

class _DepositWebViewPageState extends State<DepositWebViewPage> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Deposit'.i18n, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _webViewController.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                size: 100,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}
