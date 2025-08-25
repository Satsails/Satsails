import 'dart:async';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SellPixNox extends ConsumerStatefulWidget {
  const SellPixNox({super.key});

  @override
  _SellPixNoxState createState() => _SellPixNoxState();
}

class _SellPixNoxState extends ConsumerState<SellPixNox> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _url;
  late WebViewController _webViewController;
  bool _isWebLoading = false;

  int _currentAmountInSats = 0;
  bool _isUpdatingFromSlider = false;

  Timer? _pollingTimer;
  String? _activeTransferId;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _onAmountChanged() {
    if (_isUpdatingFromSlider || !mounted) return;

    final btcFormat = ref.read(settingsProvider).btcFormat;
    final text = _amountController.text.replaceAll(',', '.');

    if (text.isEmpty) {
      if (_currentAmountInSats != 0) {
        setState(() => _currentAmountInSats = 0);
      }
      return;
    }

    int newAmountInSats;
    if (btcFormat == 'sats') {
      newAmountInSats = int.tryParse(text) ?? 0;
    } else {
      final btcValue = double.tryParse(text) ?? 0.0;
      newAmountInSats = (btcValue * 100000000).toInt();
    }

    if (_currentAmountInSats != newAmountInSats) {
      setState(() {
        _currentAmountInSats = newAmountInSats;
      });
    }
  }

  void _startPollingForAddress(String transferId) {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        ref.invalidate(getNoxTransferDetailsProvider(transferId));
        final transferDetails = await ref.read(getNoxTransferDetailsProvider(transferId).future);

        final address = transferDetails.depositAddress;
        if (address != null && address.isNotEmpty) {
          // Stop polling once address is found to prevent multiple sends
          timer.cancel();

          ref.read(sendTxProvider.notifier).updateAddress(address);
          ref.read(sendTxProvider.notifier).updateAmount(_currentAmountInSats);
          ref.read(sendBitcoinTransactionProvider);
        }
      } catch (e) {
        print('Error polling for transfer details: $e');
      }
    });
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

    try {
      await ref.read(depositInitializerProvider.future);

      final url = await ref.read(createNoxTransferRequestProvider((
      amountCrypto: amount, // Always use the input amount as crypto
      amountFiat: null,
      type: 'offramp_instant'
      )).future);

      final transferId = url.split('/').last;

      if (url.isNotEmpty && mounted) {
        setState(() {
          _activeTransferId = transferId;
        });

        _initializeWebView(url);
        _startPollingForAddress(transferId);
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
          onPageStarted: (String url) => setState(() => _isWebLoading = true),
          onPageFinished: (String url) => setState(() => _isWebLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _url = url;
      _isWebLoading = true;
    });
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _url == null ? 'Sell via Pix'.i18n : 'Sell'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            if (_url == null) {
              context.pop();
            } else {
              setState(() {
                _url = null;
                _pollingTimer?.cancel();
                _activeTransferId = null;
              });
            }
          },
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
                SizedBox(height: 16.h),
                _buildBalanceCardWithSlider(),
                SizedBox(height: 16.h),
                _buildAmountEntryCard(),
                SizedBox(height: 16.h),
                _buildInfoCard(),
                SizedBox(height: 24.h),
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
                        'Generating Sale'.i18n,
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
                    text: 'Generate Sale'.i18n,
                  ),
                ),
              ],
            ),
          ),
        )
            : Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isWebLoading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCardWithSlider() {
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final balanceState = ref.watch(balanceNotifierProvider);
    final currency = ref.watch(settingsProvider).currency;
    final currencyNotifier = ref.watch(currencyNotifierProvider);
    final maxBalance = balanceState.onChainBtcBalance;

    final balanceString = btcInDenominationFormatted(maxBalance, btcFormat);
    final sliderMax = maxBalance > 0 ? maxBalance.toDouble() : 1.0;

    return Card(
      color: const Color(0x00333333).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Bitcoin Balance'.i18n,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                    SizedBox(height: 4.h),
                    AutoSizeText(
                      balanceString,
                      maxLines: 1,
                      minFontSize: 16,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Simplified "Max" button logic
                    _amountController.text = btcInDenominationFormatted(maxBalance.toDouble(), btcFormat);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text(
                    'Max',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6.h,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.white,
                overlayColor: Colors.white.withOpacity(0.2),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
              ),
              child: Slider(
                value: _currentAmountInSats.toDouble().clamp(0.0, sliderMax),
                min: 0,
                max: sliderMax,
                onChanged: maxBalance == 0
                    ? null
                    : (newValue) {
                  final newSats = newValue.toInt();
                  _isUpdatingFromSlider = true;
                  _amountController.text = btcInDenominationFormatted(newSats.toDouble(), btcFormat);
                  setState(() => _currentAmountInSats = newSats);
                  _isUpdatingFromSlider = false;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountEntryCard() {
    final btcFormat = ref.watch(settingsProvider).btcFormat;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency Toggle has been removed
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                btcFormat.toUpperCase(),
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
                    btcFormat == 'sats'
                        ? DecimalTextInputFormatter(decimalRange: 0)
                        : DecimalTextInputFormatter(decimalRange: 8),
                  ],
                  style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: btcFormat == 'sats' ? '0' : '0.00000000',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
}