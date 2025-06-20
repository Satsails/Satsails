import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_config_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:local_auth/local_auth.dart';
import 'package:quickalert/quickalert.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Define the loading provider
final loadingProvider = StateProvider<bool>((ref) => false);

class OpenPin extends ConsumerStatefulWidget {
  const OpenPin({super.key});

  @override
  _OpenPinState createState() => _OpenPinState();
}

class _OpenPinState extends ConsumerState<OpenPin> {
  String pin = '';
  final LocalAuthentication _localAuth = LocalAuthentication();
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkPin(BuildContext context, WidgetRef ref) async {
    try {
      final authModel = AuthModel();
      final pinText = await authModel.getPin();

      if (pinText == pin) {
        ref.read(loadingProvider.notifier).state = true;
        try {
          _attempts = 0;
          ref.read(appLockedProvider.notifier).state = false;
        } finally {
          ref.read(loadingProvider.notifier).state = false;
        }
        context.go('/home');
      } else {
        _attempts++;
        if (_attempts >= 6) {
          await _forgotPin(context, ref);
        } else {
          int remainingAttempts = 6 - _attempts;
          showMessageSnackBar(
            context: context,
            message:
            '${'Invalid PIN'.i18n} $remainingAttempts ${'attempts remaining'.i18n}',
            error: true,
          );
          setState(() => pin = '');
        }
      }
    } catch (e) {
      showMessageSnackBar(
        context: context,
        message: 'An error occurred: $e'.i18n,
        error: true,
      );
    }
  }

  Future<void> _checkBiometrics(BuildContext context, WidgetRef ref) async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to open the app'.i18n,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (authenticated) {
          ref.read(loadingProvider.notifier).state = true;
          try {
            ref.read(appLockedProvider.notifier).state = false;
          } finally {
            ref.read(loadingProvider.notifier).state = false;
          }
          context.go('/home');
        }
      }
    } catch (e) {
      // Silently handle errors (e.g., biometric unavailable or user cancels)
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, WidgetRef ref) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Delete Account?'.i18n,
      text: 'All information will be permanently deleted.'.i18n,
      titleColor: Colors.redAccent,
      textColor: Colors.white70,
      backgroundColor: Colors.black87,
      headerBackgroundColor: Colors.black87,
      showCancelBtn: false,
      showConfirmBtn: false,
      widget: Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: CustomElevatedButton(
          onPressed: () async {
            context.pop();
            await _forgotPin(context, ref);
          },
          text: 'Delete wallet'.i18n,
          backgroundColor: Colors.redAccent,
        ),
      ),
    );
  }

  Future<void> _forgotPin(BuildContext context, WidgetRef ref) async {
    final authModel = ref.read(authModelProvider);
    await authModel.deleteAuthentication();
    ref.read(appLockedProvider.notifier).state = true;
    ref.invalidate(bitcoinConfigProvider);
    ref.invalidate(liquidConfigProvider);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Center(
            child: Text(
              'Enter PIN'.i18n,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PinProgressIndicator(
                          currentLength: pin.length, totalDigits: 6),
                      SizedBox(height: 40.h),
                      CustomKeypad(
                        onDigitPressed: (digit) {
                          if (pin.length < 6) {
                            setState(() => pin += digit);
                          }
                        },
                        onBackspacePressed: () {
                          if (pin.isNotEmpty) {
                            setState(
                                    () => pin = pin.substring(0, pin.length - 1));
                          }
                        },
                      ),
                      SizedBox(height: 20.h),
                      CustomButton(
                        text: 'Unlock'.i18n,
                        onPressed: pin.length == 6
                            ? () => _checkPin(context, ref)
                            : () {},
                        primaryColor: Colors.green,
                        secondaryColor: Colors.green,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () =>
                                _showConfirmationDialog(context, ref),
                            child: Text(
                              'Forgot PIN'.i18n,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _checkBiometrics(context, ref),
                            icon: Icon(
                              Icons.fingerprint,
                              color: Colors.orange,
                              size: 28.w,
                            ),
                            label: Text(
                              'Open with biometrics'.i18n,
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.orange,
                    size: 50.w,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PinProgressIndicator extends StatelessWidget {
  final int currentLength;
  final int totalDigits;

  const PinProgressIndicator(
      {super.key, required this.currentLength, required this.totalDigits});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDigits, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentLength ? Colors.white : Colors.grey[600],
          ),
        );
      }),
    );
  }
}