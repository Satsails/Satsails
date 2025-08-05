import 'package:Satsails/models/breez/lnurl_webhook_manager.dart';
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
import 'package:i18n_extension/i18n_extension.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

class ReceiveLightningWidget extends ConsumerStatefulWidget {
  const ReceiveLightningWidget({super.key});

  @override
  ConsumerState<ReceiveLightningWidget> createState() =>
      _ReceiveLightningWidgetState();
}

class _ReceiveLightningWidgetState extends ConsumerState<ReceiveLightningWidget> {
  final _amountController = TextEditingController();
  bool _isInvoiceLoading = false;
  bool _isCheckingPermissions = false;
  ReceivePaymentResponse? _paymentResponse;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

    setState(() => _isInvoiceLoading = true);

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
        message: 'An error occurred: %s'.i18n.fill([e.toString()]),
        error: true,
      );
      setState(() {
        _paymentResponse = null;
      });
    } finally {
      if(mounted) {
        setState(() => _isInvoiceLoading = false);
      }
    }
  }

  void _showEditUsernameModal(String currentUsername) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Set the background color to match the BumpFeeModalSheet's dark theme
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => EditUsernameModalSheet(currentUsername: currentUsername),
    );
  }

  @override
  Widget build(BuildContext context) {
    final setupLnAddressAsync = ref.watch(setupLnAddressProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24.h),
        _isInvoiceLoading || _isCheckingPermissions
            ? _buildShimmerEffect()
            : (_paymentResponse != null
            ? _buildQrDisplay(_paymentResponse!.destination, isInvoice: true)
            : setupLnAddressAsync.when(
          data: (result) {
            final address = result.lightningAddress;
            if (address != null) {
              return _buildQrDisplay(address, isInvoice: false);
            }
            return _buildErrorDisplay('Failed to get a Lightning Address.'.i18n);
          },
          error: (error, stackTrace) {
            if (error is NotificationPermissionException) {
              return _buildNotificationPrompt();
            }
            return _buildErrorDisplay('Error: %s'.i18n.fill([error.toString()]));
          },
          loading: () => _buildShimmerEffect(),
        )),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: AmountInput(controller: _amountController),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: CustomButton(
            onPressed: _createInvoice,
            text: 'Generate One-Time Invoice'.i18n,
            primaryColor: Colors.green,
            secondaryColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[800]!, highlightColor: Colors.grey[700]!, child: Center(child: Column(children: [Container(width: 250.w, height: 250.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r))), SizedBox(height: 16.h), Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: Container(height: 24.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r))))]))
    );
  }

  Widget _buildQrDisplay(String content, {required bool isInvoice}) {
    return Center(
      child: Column(
        children: [
          buildQrCode(content, context),
          if (!isInvoice)
            TextButton(
              onPressed: () {
                final username = content.split('@').first;
                _showEditUsernameModal(username);
              },
              child: Text(
                'Change address'.i18n,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14.sp,
                ),
              ),
            ),
          SizedBox(height: 2.sp),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: buildAddressText(content, context, ref),
          ),
          // Replaced the icon with a TextButton below the address
        ],
      ),
    );
  }

  Widget _buildNotificationPrompt() {
    return Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 24.w), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.notifications_off_outlined, size: 48.sp, color: Colors.grey), SizedBox(height: 16.h), Text('Enable notifications to get a permanent Lightning Address.'.i18n, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)), SizedBox(height: 8.h), Text('You can still generate one-time invoices to receive payments while the app is open.'.i18n, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])), SizedBox(height: 16.h), TextButton(onPressed: () async { setState(() => _isCheckingPermissions = true); await FirebaseService.requestNotificationPermissions(); final bool granted = await FirebaseService.checkNotificationPermissionStatus(); if (!granted && mounted) { await AppSettings.openAppSettings(type: AppSettingsType.notification); } ref.invalidate(setupLnAddressProvider); }, style: TextButton.styleFrom(foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), child: Text('Allow Notifications'.i18n))])));
  }

  Widget _buildErrorDisplay(String message) {
    return Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 24.w), child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 16.sp))));
  }
}

class EditUsernameModalSheet extends ConsumerStatefulWidget {
  final String currentUsername;
  const EditUsernameModalSheet({super.key, required this.currentUsername});

  @override
  ConsumerState<EditUsernameModalSheet> createState() => _EditUsernameModalSheetState();
}

class _EditUsernameModalSheetState extends ConsumerState<EditUsernameModalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submitEditUsername() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final newUsername = _usernameController.text;
      try {
        await ref.read(createOrEditLnurlProvider(newUsername).future);
        if (mounted) {
          ref.invalidate(setupLnAddressProvider);
          showMessageSnackBar(
            message: "Username updated successfully!".i18n,
            error: false,
            context: context,
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          showMessageSnackBar(
            message: e.toString().i18n,
            error: true,
            context: context,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 20.h,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Edit Lightning Address".i18n,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Username".i18n,
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                  suffixText: '@ln.satsails.com',
                  suffixStyle: TextStyle(color: Colors.grey[500]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a username.".i18n;
                  }
                  if (RegExp(r'[^a-z0-9._-]').hasMatch(value)) {
                    return 'Only lowercase letters, numbers, and "._-" are allowed.'.i18n;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _isLoading ? null : _submitEditUsername,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    // Changed color to green and removed border radius
                    color: Colors.green,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Center(
                    child: _isLoading
                        ? LoadingAnimationWidget.fourRotatingDots(size: 24.h, color: Colors.white)
                        : Text(
                      "Save Changes".i18n,
                      style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}