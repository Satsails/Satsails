import 'package:Satsails/models/firebase_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:shimmer/shimmer.dart';

class ReceiveLightningWidget extends ConsumerStatefulWidget {
  const ReceiveLightningWidget({super.key});

  @override
  ConsumerState<ReceiveLightningWidget> createState() =>
      _ReceiveLightningWidgetState();
}

class _ReceiveLightningWidgetState extends ConsumerState<ReceiveLightningWidget> {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  bool? _notificationsAllowed;
  ReceivePaymentResponse? _paymentResponse;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _checkNotificationPermissions());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _checkNotificationPermissions() async {
    final allowed = await FirebaseService.checkNotificationPermissionStatus();
    setState(() {
      _notificationsAllowed = allowed;
    });
  }

  Future<void> _createInvoice() async {
    FocusScope.of(context).unfocus();

    ref.read(inputAmountProvider.notifier).state =
    _amountController.text.isEmpty ? '0.0' : _amountController.text;
    final amountSat = ref.read(lnAmountProvider);

    if (amountSat <= 0) {
      showMessageSnackBar(
        context: context,
        message: 'Please enter a valid amount'.i18n,
        error: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prepareResponse = await ref.read(prepareReceiveProvider(BigInt.from(amountSat)).future);
      ref.read(prepareReceiveResponseProvider.notifier).state = prepareResponse;

      final response = await ref.read(receivePaymentProvider(null).future);
      setState(() {
        _paymentResponse = response;
      });
    } catch (e) {
      showMessageSnackBar(
        context: context,
        message: 'An error occurred: $e'.i18n,
        error: true,
      );
      setState(() {
        _paymentResponse = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24.h),
        _isLoading
            ? _buildShimmerEffect()
            : (_paymentResponse != null
            ? _buildQrDisplay(_paymentResponse!.destination)
            : (_notificationsAllowed == null
            ? const Center(child: CircularProgressIndicator())
            : (_notificationsAllowed!
            ? Consumer(
          builder: (context, ref, child) {
            final setupLnAddressAsync = ref.watch(recoverLnurlProvider);
            return setupLnAddressAsync.when(
              data: (result) {
                if (result.isSuccess) {
                  final address = result.data?.lightningAddress;
                  if (address != null) {
                    return _buildQrDisplay(address);
                  } else {
                    return _buildErrorDisplay('Failed to get address');
                  }
                } else {
                  return _buildErrorDisplay(result.error?.toString() ?? 'Unknown error');
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorDisplay(error.toString()),
            );
          },
        )
            : _buildNotificationPrompt()))),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: AmountInput(controller: _amountController),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: CustomButton(
            onPressed: _createInvoice,
            text: 'Generate Invoice'.i18n,
            primaryColor: Colors.green,
            secondaryColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    final qrSize = 250.w;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Center(
        child: Column(
          children: [
            Container(
              width: qrSize,
              height: qrSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrDisplay(String content) {
    return Center(
      child: Column(
        children: [
          buildQrCode(content, context),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: buildAddressText(content, context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPrompt() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final buttonColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              'You have to allow notifications to receive payments via LNURL.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: textColor,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () async {
              await FirebaseService.requestNotificationPermissions();
              final allowed = await FirebaseService.checkNotificationPermissionStatus();
              if (!allowed) {
                await AppSettings.openAppSettings(type: AppSettingsType.notification);
              } else {
                setState(() {
                  _notificationsAllowed = true;
                });
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: buttonColor,
              textStyle: TextStyle(fontSize: 12.sp),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            ),
            child: const Text('Allow Notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.red, fontSize: 16.sp),
      ),
    );
  }
}