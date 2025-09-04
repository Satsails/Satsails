import 'dart:ui';
import 'package:Satsails/models/breez/lnurl_model.dart';
import 'package:Satsails/models/breez/lnurl_webhook_manager.dart';
import 'package:Satsails/notifications/firebase.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/screens/shared/address_display_widget.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/qr_code.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

// Assuming EditUsernameModalSheet is in the same file or imported.

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
      final prepareResponse = await ref
          .read(prepareReceiveProvider(BigInt.from(amountSat)).future);
      ref.read(prepareReceiveResponseProvider.notifier).state = prepareResponse;

      final response = await ref.read(receivePaymentProvider(null).future);
      setState(() {
        _paymentResponse = response;
      });
    } catch (e) {
      showMessageSnackBar(
        context: context,
        message: e.toString().i18n,
        error: true,
      );
      setState(() {
        _paymentResponse = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isInvoiceLoading = false);
      }
    }
  }

  void _showEditUsernameModal(String currentUsername) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make modal background transparent
      builder: (context) =>
          EditUsernameModalSheet(currentUsername: currentUsername),
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
            ? _buildQrDisplay(_paymentResponse!.destination,
            isInvoice: true)
            : setupLnAddressAsync.when(
          data: (result) {
            final address = result.lightningAddress;
            if (address != null) {
              return _buildQrDisplay(address, isInvoice: false);
            }
            return _buildErrorDisplay(
                'Failed to get a Lightning Address.'.i18n);
          },
          error: (error, stackTrace) {
            if (error is NotificationPermissionException) {
              return _buildNotificationPrompt(
                context,
                ref,
                    (isLoading) {
                  setState(() => _isCheckingPermissions = isLoading);
                },
              );
            }
            return _buildErrorDisplay(error.toString().i18n);
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
            primaryColor: Colors.green.withOpacity(0.8),
            secondaryColor: Colors.green.withOpacity(0.6),
            textColor: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        child: Center(
            child: Column(children: [
              Container(
                  width: 250.w,
                  height: 250.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r))),
              SizedBox(height: 16.h),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Container(
                      height: 24.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r))))
            ])));
  }

  Widget _buildQrDisplay(String content, {required bool isInvoice}) {
    return Center(
      child: Column(
        children: [
          buildQrCode(content, context),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AddressDisplayWidget(
              address: content,
              isEditable: !isInvoice,
              isLnurl: !isInvoice,
              onEditPressed: isInvoice
                  ? null
                  : () {
                final username = content.split('@').first;
                _showEditUsernameModal(username);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPrompt(
      BuildContext context,
      WidgetRef ref,
      Function(bool) setIsLoading,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 48.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Enable Notifications'.i18n,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Get a permanent Lightning Address and receive payments anytime.'
                        .i18n,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    text: 'Allow Notifications'.i18n,
                    onPressed: () async {
                      setIsLoading(true);
                      try {
                        await FirebaseService.requestNotificationPermissions();
                        final bool granted = await FirebaseService
                            .checkNotificationPermissionStatus();
                        if (!granted && context.mounted) {
                          await AppSettings.openAppSettings(
                              type: AppSettingsType.notification);
                        }
                        ref.invalidate(setupLnAddressProvider);
                      } finally {
                        if (context.mounted) {
                          setIsLoading(false);
                        }
                      }
                    },
                    primaryColor: Colors.white.withOpacity(0.2),
                    secondaryColor: Colors.white.withOpacity(0.15),
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(String message) {
    return Center(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 16.sp))));
  }
}

class EditUsernameModalSheet extends ConsumerStatefulWidget {
  final String currentUsername;
  const EditUsernameModalSheet({super.key, required this.currentUsername});

  @override
  ConsumerState<EditUsernameModalSheet> createState() =>
      _EditUsernameModalSheetState();
}

class _EditUsernameModalSheetState
    extends ConsumerState<EditUsernameModalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  bool _isLoading = false;
  String? _errorMessage;

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
        setState(() {
          if (e is UsernameConflictException) {
            _errorMessage = "Username already exists".i18n;
          } else {
            _errorMessage = "An error occurred. Please try again.".i18n;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF212121), // Solid dark grey color
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24.w,
              right: 24.w,
              top: 20.h,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      size: 40.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Edit Lightning Address".i18n,
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        labelText: "Username".i18n,
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                          const BorderSide(color: Colors.orange),
                        ),
                        suffixText: '@ln.satsails.com',
                        suffixStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a username.".i18n;
                        }
                        if (RegExp(r'[^a-z0-9._-]').hasMatch(value)) {
                          return 'Only lowercase letters, numbers, and "._-" are allowed.'
                              .i18n;
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding:
                        EdgeInsets.only(top: 12.h, bottom: 4.h),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: 14.sp),
                        ),
                      ),
                    SizedBox(height: 20.h),
                    _isLoading
                        ? Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                          size: 40.h, color: Colors.white),
                    )
                        : CustomButton(
                      text: "Save Changes".i18n,
                      onPressed: _submitEditUsername,
                      primaryColor: Colors.white.withOpacity(0.2),
                      secondaryColor:
                      Colors.white.withOpacity(0.15),
                      textColor: Colors.white,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
