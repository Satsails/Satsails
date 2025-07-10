import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DepositPixNox extends ConsumerStatefulWidget {
  const DepositPixNox({super.key});

  @override
  _DepositPixNoxState createState() => _DepositPixNoxState();
}

class _DepositPixNoxState extends ConsumerState<DepositPixNox> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleInput() async {
    final amount = _amountController.text;

    if (amount.isEmpty) {
      showMessageSnackBar(
          context: context,
          message: 'Amount cannot be empty'.i18n,
          error: true);
      return;
    }

    final double? amountInDouble = double.tryParse(amount);
    if (amountInDouble == null || amountInDouble <= 0) {
      showMessageSnackBar(
          context: context,
          message: 'Please enter a valid amount.'.i18n,
          error: true);
      return;
    }

    try {
      final bitcoinAddress = ref.read(addressProvider).bitcoinAddress;
      final url = await ref.read(createNoxTransferRequestProvider(
          (amount: amountInDouble.toInt(), address: bitcoinAddress)).future);
      if (url.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DepositWebViewPage(url: url),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showMessageSnackBar(
            context: context, message: e.toString().i18n, error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Pix'.i18n,
          style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: KeyboardDismissOnTap(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Amount in Brazilian Real (BRL):'.i18n,
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 16.h, horizontal: 16.w),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _handleInput,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(
                            vertical: 16.h, horizontal: 32.w),
                      ),
                      child: Text(
                        'Generate Payment'.i18n,
                        style: TextStyle(color: Colors.black, fontSize: 18.sp),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/home'),
                        child: Text(
                          'Back to Home'.i18n,
                          style:
                          TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        title: Text('Deposit'.i18n,
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold)),
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