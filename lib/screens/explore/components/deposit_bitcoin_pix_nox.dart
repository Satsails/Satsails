import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DepositBitcoinPixNox extends ConsumerStatefulWidget {
  const DepositBitcoinPixNox({super.key});

  @override
  _DepositBitcoinPixNoxState createState() => _DepositBitcoinPixNoxState();
}

class _DepositBitcoinPixNoxState extends ConsumerState<DepositBitcoinPixNox> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleInput() async {
    final amount = _amountController.text;

    if (amount.isEmpty) {
      showMessageSnackBar(context: context, message: 'Amount cannot be empty'.i18n, error: true);
      return;
    }

    final int? amountInInt = int.tryParse(amount);
    if (amountInInt == null || amountInInt <= 0) {
      showMessageSnackBar(context: context, message: 'Please enter a valid amount.'.i18n, error: true);
      return;
    }

    if (amountInInt > 5000) {
      showMessageSnackBar(context: context, message: 'The maximum allowed transfer amount is 5000 BRL'.i18n, error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = await ref.read(createNoxTransferRequestProvider(amountInInt).future);
      if (url.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DepositWebViewPage(url: url),
          ),
        );
      }
    } catch (e) {
      showMessageSnackBar(context: context, message: e.toString().i18n, error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Pix'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Amount'.i18n,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF212121),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleInput,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                ),
                child: Text(
                  'Generate Payment'.i18n,
                  style: TextStyle(color: Colors.black, fontSize: 16.sp),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      size: 0.1.sh,
                      color: Colors.orange,
                    ),
                  ),
                ),
              SizedBox(height: 24.h),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Back to Home'.i18n,
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Deposit'.i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
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
                size: 0.1.sh,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}