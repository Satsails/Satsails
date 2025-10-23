import 'dart:async';

import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/notifications/firebase.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/address_display_widget.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';

class DepositDepixPixEulen extends ConsumerStatefulWidget {
  const DepositDepixPixEulen({super.key});

  @override
  _DepositPixState createState() => _DepositPixState();
}

class _DepositPixState extends ConsumerState<DepositDepixPixEulen>
    with TickerProviderStateMixin {
  // Input and transaction state
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  String _pixQRCode = '';
  String? _transactionId;
  Timer? _pollingTimer;

  bool _isLoading = false;
  bool _isPaid = false;

  double _amountToReceive = 0;
  double feePercentage = 0;

  bool _isWhitelistActive = true;

  bool isMerchantModeActive = false;

  double _currentAmountPurchasedInUSD = 0.0;
  double? _merchantModeThreshold;

  // This is null until the fee is fetched
  double? _userFeePercentage;

  late final AnimationController _successAnimationController;
  late final Animation<double> _successScaleAnimation;
  bool _successCheckmarkValue = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();

    _successAnimationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _successScaleAnimation =
        CurvedAnimation(parent: _successAnimationController, curve: Curves.easeOutBack);

    _cpfCnpjController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cpfCnpjController.dispose();
    _pollingTimer?.cancel();
    _successAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    final userFeeFuture = _fetchUserFee();

    bool isWhitelisted;
    try {
      isWhitelisted = await ref.read(getWhitelistStatusProvider.future);
    } catch (e) {
      print("Could not fetch whitelist status, defaulting to true: $e");
      isWhitelisted = false;
    }

    if (!mounted) return;
    setState(() {
      _isWhitelistActive = isWhitelisted;
    });

    try {
      if (isWhitelisted) {
        await _fetchMerchantModeThreshold();
        await _fetchAmountPurchasedByAccount();
      }

      await userFeeFuture;

    } catch (e) {
      print("Failed to fetch initial page data (merchant or fee): $e");
      if (mounted) {
        showMessageSnackBar(
            context: context,
            message: 'Failed to load page data. Please go back and try again.'.i18n,
            error: true,
            top: true,
        );
      }
    }
  }

  Future<void> _fetchMerchantModeThreshold() async {
    try {
      final result = await ref.read(getWhitelistAmountProvider.future);
      final double threshold = (result as num).toDouble();
      if (mounted) {
        setState(() {
          _merchantModeThreshold = threshold;
        });
      }
    } catch (e) {
      print("Could not fetch merchant mode threshold: $e");
    }
  }

  Future<void> _fetchAmountPurchasedByAccount() async {
    if (_merchantModeThreshold == null) return;
    try {
      final resultInUSD = await ref.read(getAmountPurchasedProvider.future);
      final amountValue = double.tryParse(resultInUSD.toString().replaceAll(',', '.')) ?? 0.0;
      if (mounted) {
        setState(() {
          _currentAmountPurchasedInUSD = amountValue;
          isMerchantModeActive = amountValue > _merchantModeThreshold!;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAmountPurchasedInUSD = 0;
          isMerchantModeActive = false;
        });
      }
    }
  }

  Future<void> _fetchUserFee() async {
    try {
      final fee = await ref.read(getUserEulenFeeAmount.future);
      if (mounted) {
        setState(() {
          _userFeePercentage = (fee as num).toDouble();
        });
      }
    } catch (e) {
      print("Could not fetch user fee: $e");
    }
  }

  void _startPolling(String transactionId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Don't use watch here, refresh is better for periodic checks
      ref.refresh(getEulenPixPaymentStateProvider(transactionId));
    });
  }

  void _resetToInputView() {
    _pollingTimer?.cancel();
    setState(() {
      _transactionId = null;
      _pixQRCode = '';
      _isPaid = false;
      _isLoading = false;
      _amountController.clear();
      _cpfCnpjController.clear();
      _successCheckmarkValue = false;
      _successAnimationController.reset();
    });
  }

  Future<void> _generateQRCode() async {
    // We can now be certain _userFeePercentage is not null here,
    // because the button to call this function was disabled.

    final amount = _amountController.text.replaceAll(',', '.');
    final cpfCnpj = _cpfCnpjController.text;

    if (amount.isEmpty) {
      showMessageSnackBar(
          context: context, message: 'Amount cannot be empty'.i18n, error: true, top: true);
      return;
    }
    final double? amountInDouble = double.tryParse(amount);
    if (amountInDouble == null || amountInDouble <= 0) {
      showMessageSnackBar(
          context: context, message: 'Please enter a valid amount.'.i18n, error: true, top: true);
      return;
    }
    if (amountInDouble < 5) {
      showMessageSnackBar(
          context: context,
          message: 'The minimum deposit amount is 5 BRL'.i18n,
          error: true,
          top: true);
      return;
    }

    final maxAmount = cpfCnpj.isNotEmpty ? 6000 : 3000;
    final maxAmountString = cpfCnpj.isNotEmpty ? '6000' : '3000';

    if (amountInDouble > maxAmount) {
      showMessageSnackBar(
          context: context,
          message: 'The maximum value per transaction is $maxAmountString BRL'.i18n,
          error: true,
          top: true);
      return;
    }

    if (amountInDouble > 3000 && cpfCnpj.isEmpty) {
      showMessageSnackBar(
          context: context,
          message: 'CPF/CNPJ is required for amounts over R\$ 3000'.i18n,
          error: true,
          top: true);
      return; // Stop execution if validation fails
    }

    setState(() {
      _isLoading = true;
      _isPaid = false; // Reset paid status
      _successCheckmarkValue = false; // Reset checkmark
      _successAnimationController.reset(); // Reset animation
    });

    try {
      await FirebaseService.requestNotificationPermissions();
      await ref.read(depositInitializerProvider.future);

      final purchaseRequestData = {
        'amount': amountInDouble,
        'taxId': cpfCnpj.isNotEmpty ? cpfCnpj : null,
      };

      final purchase = await ref.read(createEulenTransferRequestProvider(purchaseRequestData).future);

      if (mounted) {
        setState(() {
          _pixQRCode = purchase.pixKey;
          _isLoading = false;
          _amountToReceive = purchase.receivedAmount;
          feePercentage = _userFeePercentage! * 100;
          _transactionId = purchase.transactionId;
        });
        _startPolling(_transactionId!);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showMessageSnackBar(
            context: context, message: e.toString().i18n, error: true, top: true);
      }
    }
  }

  void _onPaymentConfirmed() {
    _pollingTimer?.cancel();
    if (!_isPaid) { // Only update state and vibrate if not already marked as paid
      setState(() {
        _isPaid = true;
        _successCheckmarkValue = true;
      });
      _successAnimationController.forward();
      Vibration.hasVibrator().then((bool? hasVibrator) {
        if (hasVibrator == true) Vibration.vibrate(duration: 100);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_transactionId != null) {
      ref.listen<AsyncValue<bool>>(getEulenPixPaymentStateProvider(_transactionId!),
              (previous, next) {
            final isPaidNow = next.valueOrNull ?? false;
            if (isPaidNow && !_isPaid) {
              _onPaymentConfirmed();
            }
          });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Deposit via Pix'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              // Handle back press: go back if inputting, reset if showing QR/Success
              if (_transactionId == null) {
                context.pop();
              } else {
                _resetToInputView();
              }
            }),
      ),
      body: SafeArea(
        child: KeyboardDismissOnTap(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isLoading
                ? _buildShimmerEffect() // Show shimmer when loading API request
                : _transactionId == null
                ? _buildAmountInputView() // Show input view if no transaction yet
                : SingleChildScrollView( // Use SingleChildScrollView for QR/Success views
              key: ValueKey(_isPaid ? 'successView' : 'qrView'), // Key for animation
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              child: _isPaid ? _buildPaymentSuccessView() : _buildQRCodeView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInputView() {
    final bool isButtonEnabled = _userFeePercentage != null && !_isLoading;

    final String buttonText = _userFeePercentage == null
        ? 'Loading fee...'.i18n
        : 'Generate Payment'.i18n;

    return Padding(
      key: const ValueKey('amountInput'), // Key for AnimatedSwitcher
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView( // Make content scrollable
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  _buildAmountEntryCard(), // Amount and CPF/CNPJ input
                  SizedBox(height: 24.h),
                  _buildInfoCard(), // Merchant mode and info rows
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          CustomButton( // Generate payment button
            onPressed: _generateQRCode, // Disable if not ready
            primaryColor: isButtonEnabled
                ? Colors.green.withOpacity(0.8)
                : Colors.grey[800]!, // Grey out if disabled
            secondaryColor: Colors.green.withOpacity(0.6),
            textColor: isButtonEnabled ? Colors.black : Colors.grey[400]!,
            text: buttonText, // Use dynamic text
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantModeInfoSection() {
    // Show shimmer if threshold hasn't loaded yet
    if (_merchantModeThreshold == null) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        child: Container( /* Shimmer placeholder layout */
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Container( width: 22.sp, height: 22.sp, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
              SizedBox(width: 12.w),
              Container( height: 18.h, width: 120.w, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4.r))),
              const Spacer(),
              Container( height: 18.h, width: 60.w, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4.r))),
              SizedBox(width: 8.w),
              Container( width: 24.sp, height: 24.sp, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
            ],
          ),
        ),
      );
    }

    // Determine status text and progress
    final statusText = isMerchantModeActive ? 'Active'.i18n : 'Inactive'.i18n;
    final progress = _merchantModeThreshold! > 0
        ? (_currentAmountPurchasedInUSD / _merchantModeThreshold!).clamp(0.0, 1.0) // Clamp value between 0 and 1
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile( // Collapsible section for details
          iconColor: Colors.white.withOpacity(0.7),
          collapsedIconColor: Colors.white.withOpacity(0.7),
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          title: Row( // Header row: Title and Status
            children: [
              Text(
                'Merchant Mode'.i18n,
                style: TextStyle(
                    color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                statusText,
                style: TextStyle(
                    color: isMerchantModeActive ? Colors.green : Colors.red, fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8.w),
              // Icon is automatically added by ExpansionTile
            ],
          ),
          children: <Widget>[ // Content shown when expanded
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.white.withOpacity(0.1), height: 16.h),
                  Text(
                    'What is Merchant Mode?'.i18n,
                    style: TextStyle(
                        color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'When active, you can receive payments up to R\$6000 per transaction from any CPF/CNPJ, even those with no prior history.'
                        .i18n,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Any MED or bank request for transaction refunds will cancel the Merchant mode'.i18n, // Removed extra .i18n
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  if (!isMerchantModeActive) ...[
                    Text(
                      'How to activate it:'.i18n,
                      style: TextStyle(
                          color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    RichText( // Use RichText to style the amount
                      text: TextSpan(
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14.sp, fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily), // Ensure consistent font
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Merchant Mode is activated automatically once your total deposit volume exceeds '.i18n,
                          ),
                          TextSpan(
                            text: '\$${_merchantModeThreshold!.toStringAsFixed(0)} USD',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Your Progress:'.i18n,
                      style: TextStyle(
                          color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.h),
                    ClipRRect( // Progress bar
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progress, // Use clamped progress value
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        minHeight: 6.h,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text( // Progress text
                      '\$${_currentAmountPurchasedInUSD.toStringAsFixed(2)} / \$${_merchantModeThreshold!.toStringAsFixed(0)} USD',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Contains Merchant Mode section and general info rows
  Widget _buildInfoCard() {
    return Column(
      children: [
        if (_isWhitelistActive) ...[
          _buildMerchantModeInfoSection(),
          SizedBox(height: 24.h),
        ],
        Container( // Container for general info rows
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
              color: const Color(0xFF333333).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            children: [
              if (!isMerchantModeActive) ...[
                _buildInfoRow( // Added SizedBox for spacing consistency
                  icon: Icons.info_outline,
                  child: Text('CPF/CNPJ without purchase history: Max R\$ 500 in first 24h'.i18n, style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                ),
                SizedBox(height: 12.h),
              ],
              _buildInfoRow(
                icon: Icons.calendar_today,
                child: Text('Limit per 24h per CPF/CNPJ: R\$ 6000'.i18n,
                    style: TextStyle(
                        fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
              SizedBox(height: 12.h),
              _buildInfoRow(
                icon: Icons.history_toggle_off,
                child: Text(
                    'Sending more than 2 transactions in 30 mins from the same CPF/CNPJ can result in chargebacks'
                        .i18n,
                    style: TextStyle(
                        fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(color: Colors.white.withOpacity(0.1)),
              ),
              _buildInfoRow(
                icon: Icons.warning_amber_rounded,
                child: Text("Transfers that don't follow these rules will be returned".i18n,
                    style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // Card for entering BRL amount and optional CPF/CNPJ
  Widget _buildAmountEntryCard() {
    // Parse the current amount to check the condition
    final currentAmountText = _amountController.text.replaceAll(',', '.');
    final currentAmount = double.tryParse(currentAmountText) ?? 0.0;
    final isCpfCnpjMandatory = currentAmount > 3000;

    // Determine label and hint based on whether CPF/CNPJ is mandatory
    final cpfCnpjLabel = isCpfCnpjMandatory
        ? 'Payee CPF/CNPJ (Mandatory)'.i18n
        : 'Payee CPF/CNPJ (Optional)'.i18n;

    final cpfCnpjHint = isCpfCnpjMandatory
        ? 'Required for amounts over R\$ 3000'.i18n
        : 'Enter to raise limit to R\$ 6000 per transaction'.i18n;

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
            color: const Color(0xFF333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(20.r)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // BRL Amount Input
          Text('Amount to deposit in BRL'.i18n,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 12.h),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text('R\$',
                style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.5))),
            SizedBox(width: 10.w),
            Expanded(
                child: TextField(
                    controller: _amountController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [ // Formatters for BRL input
                      CommaTextInputFormatter(), // Allows comma as decimal separator
                      DecimalTextInputFormatter(decimalRange: 2) // Limits to 2 decimal places
                    ],
                    style: TextStyle(
                        fontSize: 40.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0,00', // Hint uses comma
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)))))
          ]),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: Colors.white.withOpacity(0.1)),
          ),
          // CPF/CNPJ Input
          Text(cpfCnpjLabel, // Dynamic label
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 8.h),
          TextField(
            controller: _cpfCnpjController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only allow digits
            ],
            style: TextStyle(fontSize: 18.sp, color: Colors.white),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: cpfCnpjHint, // Dynamic hint text
                hintStyle: TextStyle(fontSize: 15.sp, color: Colors.white.withOpacity(0.3))),
          ),
        ]));
  }

  // View shown while waiting for payment (displays QR code)
  Widget _buildQRCodeView() {
    // Get the current payment status from the provider
    final paymentStatus = ref.watch(getEulenPixPaymentStateProvider(_transactionId!));
    final originalAmount = _amountController.text; // Amount user entered

    return Column(
      key: const ValueKey('qrCodeDisplay'), // Key for AnimatedSwitcher
      children: [
        SizedBox(height: 16.h),
        Center(child: buildQrCode(_pixQRCode, context)), // Display the QR code
        SizedBox(height: 24.h),
        AddressDisplayWidget(address: _pixQRCode, isEditable: false, onEditPressed: null), // Display Pix key text
        SizedBox(height: 24.h),
        _buildPaymentDetailsCard(originalAmount, paymentStatus), // Show amount/fee/status
        SizedBox(height: 24.h),
        Center( // Button to cancel and go back to input
          child: TextButton(
            onPressed: _resetToInputView,
            child: Text(
              'Start Over'.i18n,
              style: TextStyle(fontSize: 16.sp, color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ),
      ],
    );
  }

  // View shown after payment is confirmed
  Widget _buildPaymentSuccessView() {
    final paymentStatus = ref.watch(getEulenPixPaymentStateProvider(_transactionId!));
    final originalAmount = _amountController.text; // Use original amount for display consistency

    return Column(
      key: const ValueKey('paymentSuccess'), // Key for AnimatedSwitcher
      children: [
        SizedBox(height: 48.h),
        ScaleTransition( // Animated checkmark
          scale: _successScaleAnimation,
          child: MSHCheckbox(
            size: 90.sp,
            value: _successCheckmarkValue,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(checkedColor: Colors.green),
            style: MSHCheckboxStyle.stroke,
            onChanged: (_) {}, // Read-only checkbox
          ),
        ),
        SizedBox(height: 16.h),
        Text( // Success message
          'Payment Received'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24.h),
        _buildPaymentDetailsCard(originalAmount, paymentStatus), // Show final details
        SizedBox(height: 24.h),
        CustomButton( // Finish button to navigate home
          text: 'Finish'.i18n,
          onPressed: () => context.go('/home'),
          primaryColor: Colors.green.withOpacity(0.8),
          secondaryColor: Colors.green.withOpacity(0.6),
          textColor: Colors.white, // Changed text color for better contrast
        ),
      ],
    );
  }

  // Card displaying final amounts, fees, and payment status
  Widget _buildPaymentDetailsCard(String originalAmount, AsyncValue<bool> paymentStatus) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
          color: const Color(0xFF333333).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You will receive'.i18n,
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          // Display amount to receive (Depix)
          Text('${_amountToReceive.toStringAsFixed(2)} Depix', // Ensure 2 decimal places for Depix
              style:
              TextStyle(fontSize: 28.sp, color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          // Display original BRL amount paid
          Text('From your R\$'.i18n + originalAmount,
              style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500)),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Divider(color: Colors.white.withOpacity(0.1))),
          // Fee details
          _buildDetailRow('Fixed fee'.i18n, '0.99 BRL'),
          SizedBox(height: 12.h),
          _buildDetailRow('Satsails fee'.i18n, '${feePercentage.toStringAsFixed(2)} %'),
          Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Divider(color: Colors.white.withOpacity(0.1))),
          // Payment status row (dynamic based on polling)
          _buildPaymentStatusRow(paymentStatus),
        ],
      ),
    );
  }

  // Builds the dynamic status row within the details card
  Widget _buildPaymentStatusRow(AsyncValue<bool> status) {
    // Helper to build the row content
    Widget buildRow(String text, IconData icon, Color color, {bool showSpinner = false}) {
      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Status'.i18n,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15.sp)),
            Row(children: [
              if (showSpinner) // Show spinner if loading
                SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(color)))
              else // Show icon otherwise
                Icon(icon, color: color, size: 18.sp),
              SizedBox(width: 8.w),
              Text(text,
                  style: TextStyle(color: color, fontSize: 15.sp, fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      );
    }

    // Use AsyncValue.when to handle different states
    return status.when(
      data: (isPaid) => isPaid
          ? buildRow('Confirmed'.i18n, Icons.check_circle, Colors.green) // Confirmed state
          : buildRow('Awaiting Payment'.i18n, Icons.hourglass_bottom, Colors.orange), // Waiting state
      loading: () => buildRow('Checking...'.i18n, Icons.sync, Colors.orange, showSpinner: true), // Loading state
      error: (e, st) => buildRow('Unable to Verify'.i18n, Icons.error, Colors.red), // Error state
    );
  }

  // Helper for building rows in the info card
  Widget _buildInfoRow({required IconData icon, required Widget child}) {
    return Row(children: [
      Icon(icon, color: Colors.white.withOpacity(0.7), size: 20.sp),
      SizedBox(width: 12.w),
      Expanded(child: child),
    ]);
  }

  // Helper for building detail rows (label/value) in cards
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(fontSize: 15.sp, color: Colors.grey[400], fontWeight: FontWeight.w500)),
      Text(value,
          style: TextStyle(
              fontSize: 15.sp, color: valueColor ?? Colors.white, fontWeight: FontWeight.bold))
    ]);
  }

  // Builds the shimmer loading effect for the QR code view
  Widget _buildShimmerEffect() {
    final baseColor = Colors.grey[900]!;
    final highlightColor = Colors.grey[800]!;
    // Helper to create a shimmer placeholder box
    Widget shimmerBox({double? width, required double height, double radius = 16.0}) {
      return Container(
          width: width,
          height: height,
          decoration:
          BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(radius.r)));
    }

    return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(children: [
            SizedBox(height: 16.h),
            shimmerBox(width: 250.w, height: 250.w), // QR Code placeholder
            SizedBox(height: 24.h),
            shimmerBox(height: 56.h, radius: 12), // Address display placeholder
            SizedBox(height: 24.h),
            shimmerBox(height: 220.h, radius: 20) // Details card placeholder
          ]),
        ));
  }
}