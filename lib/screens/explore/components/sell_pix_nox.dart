import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum InputCurrency { brl, btc }

class SellPixNox extends ConsumerStatefulWidget {
  const SellPixNox({super.key});

  @override
  _SellPixNoxState createState() => _SellPixNoxState();
}

class _SellPixNoxState extends ConsumerState<SellPixNox> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  InputCurrency _selectedCurrency = InputCurrency.brl;
  String? _url;
  late WebViewController _webViewController;
  bool _isWebLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleInput() async {
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

    String? amountFiat;
    String? amountCrypto;

    if (_selectedCurrency == InputCurrency.brl) {
      amountFiat = amount;
      amountCrypto = null;
    } else {
      amountFiat = null;
      amountCrypto = amount;
    }

    try {
      // Assuming depositInitializerProvider is a generic initializer
      await ref.read(depositInitializerProvider.future);
      final url = await ref.read(createNoxTransferRequestProvider(
          (amountCrypto: amountCrypto, amountFiat: amountFiat, type: 'offramp_instant')).future);

      if (url.isNotEmpty && mounted) {
        _initializeWebView(url);
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

  void _initializeWebView(String url) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isWebLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isWebLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _url = url;
      _isWebLoading = true;
    });
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
        centerTitle: true,
        title: Text(
          _url == null ? 'Sell via Pix'.i18n : 'Sell'.i18n, // Changed title
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => _url == null ? context.pop() : setState(() { _url = null; }),
        ),
        actions: _url != null
            ? [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _webViewController.reload(),
          ),
        ]
            : null,
      ),
      body: SafeArea(
        child: _url == null
            ? KeyboardDismissOnTap(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h),
                _buildAmountEntryCard(),
                SizedBox(height: 16.h),
                // =========== INFO CARD ADDED HERE ===========
                _buildInfoCard(),
                SizedBox(height: 24.h),
                // ==========================================
                SizedBox(
                  height: 56.h,
                  child: _isLoading
                      ? Shimmer.fromColors(
                    baseColor: Colors.green.withOpacity(0.6),
                    highlightColor: Colors.green.withOpacity(0.9),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Generating Sale'.i18n, // Changed loading text
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      : CustomButton(
                    onPressed: _handleInput,
                    primaryColor: Colors.green.withOpacity(0.8),
                    secondaryColor: Colors.green.withOpacity(0.6),
                    textColor: Colors.white,
                    text: 'Generate Sale'.i18n, // Changed button text
                  ),
                ),
              ],
            ),
          ),
        )
            : Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isWebLoading) _buildShimmerEffect(),
          ],
        ),
      ),
    );
  }

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

  // =========== NEW WIDGETS ADDED HERE ===========
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: _buildInfoRow(
        icon: Icons.info_outline,
        label: Text(
          'Small amounts may incur higher relative costs due to Bitcoin network fees.'.i18n,
          style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required Widget label, Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Colors.white.withOpacity(0.7), size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: label,
        ),
      ],
    );
  }
  // ============================================

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