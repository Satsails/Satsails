import 'package:Satsails/providers/currency_conversions_provider.dart';
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
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/sideshift_provider.dart';

class DepositPixNox extends ConsumerStatefulWidget {
  const DepositPixNox({super.key});

  @override
  _DepositPixNoxState createState() => _DepositPixNoxState();
}

class _DepositPixNoxState extends ConsumerState<DepositPixNox> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  SideShift? _shift;
  double? _minDepositBRL;
  double? _maxDepositBRL;
  double? _adjustedMinDepositBRL;
  double? _adjustedMaxDepositBRL;
  double? _valueToReceive;
  double? _cashback;
  Future<SideShift>? _shiftFuture;
  bool _shiftCreated = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateValueToReceiveAndCashback);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_shiftCreated) {
      _shiftFuture = _createShift();
      _shiftCreated = true;
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateValueToReceiveAndCashback);
    _amountController.dispose();
    super.dispose();
  }

  Future<SideShift> _createShift() async {
    final selectedShiftPair = ref.read(
        selectedShiftPairProviderFromFiatPurchases);
    if (selectedShiftPair == null) {
      throw Exception('No shift pair selected');
    }

    setState(() => _isLoading = true);

    try {
      final shift = await ref.read(
          createReceiveSideShiftShiftProviderWithoutSaving(selectedShiftPair)
              .future);
      final brlRate = ref.read(selectedCurrencyProviderFromUSD('BRL'));
      setState(() {
        _shift = shift;
        _minDepositBRL = double.parse(shift.depositMin) * brlRate;
        _maxDepositBRL = double.parse(shift.depositMax) * brlRate;
        _adjustedMinDepositBRL = _minDepositBRL! * 2;
        _adjustedMaxDepositBRL = _maxDepositBRL! - 10;
      });
      return shift;
    } catch (e) {
      showMessageSnackBar(context: context, message: e
          .toString()
          .i18n, error: true);
      rethrow;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateValueToReceiveAndCashback() {
    final currencyModel = ref.read(currencyNotifierProvider);
    final amount = double.tryParse(_amountController.text);
    final selectedShiftPair = ref.read(selectedShiftPairProviderFromFiatPurchases);

    if (amount != null && _shift != null) {
      final netAmountBRL = amount * 0.97;

      double? valueToReceive;
      String settleCurrency = 'BTC'; // Default to BTC

      if (selectedShiftPair == ShiftPair.usdcAvaxToLiquidUsdt) {
        // For USDT receive case, convert BRL to USD (since USDT ≈ USD)
        valueToReceive = netAmountBRL * currencyModel.brlToUsd;
        settleCurrency = 'USDT';
      } else {
        // For BTC receive case
        valueToReceive = netAmountBRL * currencyModel.brlToBtc;
      }

      // Calculate cashback in BTC (0.2% of input amount)
      final cashback = amount * 0.002 * currencyModel.brlToBtc;

      setState(() {
        _valueToReceive = valueToReceive;
        _cashback = cashback;
      });
    } else {
      setState(() {
        _valueToReceive = null;
        _cashback = null;
      });
    }
  }

  Future<void> _handleInput() async {
    final amount = _amountController.text;

    if (amount.isEmpty) {
      showMessageSnackBar(context: context,
          message: 'Amount cannot be empty'.i18n,
          error: true);
      return;
    }

    final double? amountInDouble = double.tryParse(amount);
    if (amountInDouble == null || amountInDouble <= 0) {
      showMessageSnackBar(context: context,
          message: 'Please enter a valid amount.'.i18n,
          error: true);
      return;
    }

    if (_adjustedMinDepositBRL != null &&
        amountInDouble < _adjustedMinDepositBRL!) {
      showMessageSnackBar(
          context: context,
          message: 'Amount is below the minimum deposit of ${_adjustedMinDepositBRL!
              .toStringAsFixed(2)} BRL'.i18n,
          error: true);
      return;
    }

    if (_adjustedMaxDepositBRL != null &&
        amountInDouble > _adjustedMaxDepositBRL!) {
      showMessageSnackBar(
          context: context,
          message: 'Amount is above the maximum deposit of ${_adjustedMaxDepositBRL!
              .toStringAsFixed(2)} BRL'.i18n,
          error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = await ref.read(createNoxTransferRequestProvider(
          (amount: amountInDouble.toInt(), address: _shift!.depositAddress))
          .future);
      if (url.isNotEmpty) {
        ref.read(sideShiftShiftsProvider.notifier).addShift(_shift!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DepositWebViewPage(url: url),
          ),
        );
      }
    } catch (e) {
      showMessageSnackBar(context: context, message: e
          .toString()
          .i18n, error: true);
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
          style: TextStyle(color: Colors.white,
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
        child: FutureBuilder<SideShift>(
          future: _shiftFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  size: 0.1.sh,
                  color: Colors.orange,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}'.i18n,
                  style: TextStyle(color: Colors.red, fontSize: 16.sp),
                ),
              );
            } else if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h,
                              horizontal: 16.w),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _handleInput,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius
                              .circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 16.h,
                              horizontal: 32.w),
                        ),
                        child: Text(
                          'Generate Payment'.i18n,
                          style: TextStyle(color: Colors.black, fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Note: Purchases from NOX are always in USDC and will be automatically converted via smart contract to the asset you want to purchase. The asset you receive is not reported to the goverment automatically.'
                            .i18n,
                        style: TextStyle(color: Colors.red,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      _buildDepositInfoCard(),
                      SizedBox(height: 24.h),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/home'),
                          child: Text(
                            'Back to Home'.i18n,
                            style: TextStyle(
                                fontSize: 16.sp, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDepositInfoCard() {
    return Card(
      color: const Color(0xFF212121),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deposit Information'.i18n,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Minimum Deposit: '.i18n,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '${_adjustedMinDepositBRL?.toStringAsFixed(2) ??
                        'N/A'} BRL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Maximum Deposit: '.i18n,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '${_adjustedMaxDepositBRL?.toStringAsFixed(2) ??
                        'N/A'} BRL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (_valueToReceive != null) ...[
              SizedBox(height: 8.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Value to Receive: '.i18n,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${_valueToReceive!.toStringAsFixed(8)} ${_shift
                          ?.settleCoin ?? 'BTC'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_cashback != null) ...[
              SizedBox(height: 8.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Cashback: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${_cashback!.toStringAsFixed(8)} BTC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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