import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Enum to manage the selected input currency type
enum InputCurrency { brl, btc }

class DepositPixNox extends ConsumerStatefulWidget {
  const DepositPixNox({super.key});

  @override
  _DepositPixNoxState createState() => _DepositPixNoxState();
}

class _DepositPixNoxState extends ConsumerState<DepositPixNox> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  InputCurrency _selectedCurrency = InputCurrency.brl;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleInput() async {
    //
    if (_selectedCurrency == InputCurrency.btc) {
      showMessageSnackBar(context: context, message: 'BTC input is not yet supported for this method.'.i18n, error: true);
      return;
    }

    final amount = _amountController.text.replaceAll(',', '.');

    if (amount.isEmpty) {
      showMessageSnackBar(context: context, message: 'Amount cannot be empty'.i18n, error: true);
      return;
    }

    final double? amountInDouble = double.tryParse(amount);
    if (amountInDouble == null || amountInDouble <= 0) {
      showMessageSnackBar(context: context, message: 'Please enter a valid amount.'.i18n, error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bitcoinAddress = ref.read(addressProvider).bitcoinAddress;
      final url = await ref.read(createNoxTransferRequestProvider((amount: amountInDouble.toInt(), address: bitcoinAddress)).future);

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
        showMessageSnackBar(context: context, message: e.toString().i18n, error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Deposit via Pix'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: KeyboardDismissOnTap(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),
                _buildAmountEntryCard(),
                SizedBox(height: 24.h),
                SizedBox(
                  height: 56.h,
                  child: _isLoading
                      ? Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      size: 40.w,
                      color: Colors.green,
                    ),
                  )
                      : CustomButton(
                    onPressed: _handleInput,
                    primaryColor: Colors.green.withOpacity(0.8),
                    secondaryColor: Colors.green.withOpacity(0.6),
                    textColor: Colors.white,
                    text: 'Generate Payment'.i18n,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The main card for entering the amount, including the currency toggle.
  Widget _buildAmountEntryCard() {
    final isBrl = _selectedCurrency == InputCurrency.brl;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrencyToggle(),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isBrl ? 'R\$' : 'BTC',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    CommaTextInputFormatter(),
                    DecimalTextInputFormatter(decimalRange: isBrl ? 2 : 8)
                  ],
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: isBrl ? '0,00' : '0,00000000',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// A segmented control to switch between BRL and BTC input.
  Widget _buildCurrencyToggle() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(4.sp),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption(InputCurrency.brl, 'BRL'),
            SizedBox(width: 6.w),
            _buildCurrencyOption(InputCurrency.btc, 'Bitcoin'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(InputCurrency currency, String label) {
    final isSelected = _selectedCurrency == currency;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCurrency = currency;
          _amountController.clear();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2C2C) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// --- The WebView Page remains unchanged ---

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

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(color: Colors.black),
    );
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
          if (_isLoading) _buildShimmerEffect(),
        ],
      ),
    );
  }
}