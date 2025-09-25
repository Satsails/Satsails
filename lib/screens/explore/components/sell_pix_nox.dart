import 'dart:async';

import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart'; // Using your provider context
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
  bool _isCalculatingMax = false;
  bool _isSyncingController = false;

  Timer? _pollingTimer;
  String? _activeTransferId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendTxProvider.notifier).resetToDefault();
      _syncControllerWithProvider(ref.read(sendTxProvider).amount);
    });
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _syncControllerWithProvider(int amountInSats) {
    _isSyncingController = true;
    if (amountInSats == 0) {
      _amountController.clear();
    } else {
      final formattedAmount = btcInDenominationFormatted(amountInSats.toDouble(), 'BTC');
      if (_amountController.text != formattedAmount) {
        _amountController.text = formattedAmount;
      }
    }
    _isSyncingController = false;
  }

  void _onAmountChanged() {
    if (_isSyncingController) return;

    ref.read(sendTxProvider.notifier).updateDrain(false);
    final text = _amountController.text;

    if (text.isEmpty) {
      ref.read(sendTxProvider.notifier).updateAmount(0);
      return;
    }
    final btcValue = double.tryParse(text) ?? 0.0;
    final newAmountInSats = (btcValue * 100000000).round();
    ref.read(sendTxProvider.notifier).updateAmount(newAmountInSats);
  }

  Future<void> _calculateAndSetMaxSellableAmount() async {
    if (_isCalculatingMax) return;
    setState(() => _isCalculatingMax = true);

    try {
      ref.read(sendTxProvider.notifier).updateAddress(ref.read(addressProvider).bitcoinAddress);
      final balance = ref.read(balanceNotifierProvider).onChainBtcBalance;
      if (balance == 0) {
        showMessageSnackBar(context: context, message: 'Zero balance'.i18n, error: true);
        return;
      }

      final transactionBuilder = await ref.watch(bitcoinTransactionBuilderProvider(0).future);
      final transaction = await ref.watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilder).future);

      final fee = (transaction.$1.feeAmount() ?? BigInt.zero).toInt();
      final amountToSet = balance - fee;

      if (amountToSet <= 0) {
        showMessageSnackBar(context: context, message: 'Balance too low to cover network fees'.i18n, error: true);
        return;
      }

      ref.read(sendTxProvider.notifier).updateAmount(amountToSet);
      ref.read(sendTxProvider.notifier).updateDrain(true);
    } catch (e) {
      if (mounted) {
        showMessageSnackBar(context: context, message: e.toString().i18n, error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isCalculatingMax = false);
      }
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
          timer.cancel();
          try {
            ref.read(sendTxProvider.notifier).updateAddress(address);
            await ref.read(sendBitcoinTransactionProvider.future);
            ref.read(sendTxProvider.notifier).resetToDefault();
          } catch (e) {
            ref.read(sendTxProvider.notifier).resetToDefault();
            if (mounted) {
              showMessageSnackBar(
                  context: context, message: "Transaction failed: ${e.toString()}".i18n, error: true);
              setState(() {
                _url = null;
                _activeTransferId = null;
              });
            }
          }
        }
      } catch (e) {
        ref.read(sendTxProvider.notifier).resetToDefault();
        print('Error polling for transfer details: $e');
      }
    });
  }


  Future<void> _handleInput() async {
    final sendTxState = ref.read(sendTxProvider);
    final availableBalance = ref.read(balanceNotifierProvider).onChainBtcBalance;

    if (sendTxState.amount <= 0) {
      showMessageSnackBar(context: context, message: 'Please enter a valid amount'.i18n, error: true);
      return;
    }

    if (!sendTxState.drain && sendTxState.amount > availableBalance) {
      showMessageSnackBar(context: context, message: 'Amount exceeds available balance'.i18n, error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(depositInitializerProvider.future);
      final amountForApi = btcInDenominationFormatted(sendTxState.amount.toDouble(), 'BTC');

      final url = await ref.read(createNoxTransferRequestProvider((
      amountCrypto: amountForApi,
      amountFiat: null,
      type: 'offramp_instant'
      )).future);

      final transferId = url.split('/').last;

      if (url.isNotEmpty && mounted) {
        setState(() => _activeTransferId = transferId);
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
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(sendTxProvider.select((s) => s.amount), (previous, next) {
      if (previous != next) {
        _syncControllerWithProvider(next);
      }
    });

    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          Future(() {
            ref.read(sendTxProvider.notifier).resetToDefault();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: false,
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
                _pollingTimer?.cancel();
                Future(() {
                  ref.read(sendTxProvider.notifier).resetToDefault();
                });
                context.go('/home');
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
                  _buildBalanceCard(),
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
                            color: Colors.black,
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
                      textColor: Colors.black,
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
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balanceState = ref.watch(balanceNotifierProvider);
    final maxBalance = balanceState.onChainBtcBalance;
    final balanceString = btcInDenominationFormatted(maxBalance.toDouble(), 'BTC');
    final currentAmount = ref.watch(sendTxProvider).amount;

    final sliderMax = maxBalance > 0 ? maxBalance.toDouble() : 1.0;
    final percentage = maxBalance > 0 ? (currentAmount / maxBalance * 100) : 0.0;

    return Card(
      color: const Color(0x00333333).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
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
                ),
                TextButton(
                  onPressed: _isCalculatingMax ? null : _calculateAndSetMaxSellableAmount,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: _isCalculatingMax
                      ? SizedBox(
                    height: 20.sp,
                    width: 20.sp,
                    child: const CircularProgressIndicator(strokeWidth: 2.0, color: Colors.black),
                  )
                      : Text(
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
                value: currentAmount.toDouble().clamp(0.0, sliderMax),
                min: 0,
                max: sliderMax,
                label: '${percentage.toStringAsFixed(0)}%',
                onChanged: maxBalance == 0
                    ? null
                    : (newValue) {
                  ref.read(sendTxProvider.notifier).updateDrain(false);
                  ref.read(sendTxProvider.notifier).updateAmount(newValue.toInt());
                },
                onChangeEnd: (finalValue) {
                  if (maxBalance > 0 && finalValue.round() >= maxBalance) {
                    _calculateAndSetMaxSellableAmount();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAmountEntryCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'BTC',
                style: TextStyle(
                    fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5)),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    CommaTextInputFormatter(),
                    DecimalTextInputFormatter(decimalRange: 8),
                  ],
                  style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00000000',
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
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.price_change_outlined,
            label: Text(
              'Generate a sale to see how many BRL you will receive'.i18n,
              style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.info_outline,
            label: Text(
              'Small amounts may incur higher relative costs due to Bitcoin network fees.'.i18n,
              style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.info_outline,
            label: Text(
              'The total sent amount will cover bitcoin blockchain transaction fee'.i18n,
              style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
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