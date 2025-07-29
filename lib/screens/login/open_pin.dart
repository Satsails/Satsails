import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_config_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:local_auth/local_auth.dart';
import 'package:quickalert/quickalert.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';

// Define the loading provider
final loadingProvider = StateProvider<bool>((ref) => false);

class OpenPin extends ConsumerStatefulWidget {
  const OpenPin({super.key});

  @override
  _OpenPinState createState() => _OpenPinState();
}

class _OpenPinState extends ConsumerState<OpenPin>
    with SingleTickerProviderStateMixin {
  String pin = '';
  final LocalAuthentication _localAuth = LocalAuthentication();
  int _attempts = 0;

  // Animation controller for the shake animation on incorrect PIN
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  Future<void> _checkPin(BuildContext context, WidgetRef ref) async {
    try {
      final authModel = AuthModel();
      final storedPin = await authModel.getPin();

      if (storedPin == pin) {
        _unlockApp(context, ref);
      } else {
        _handleIncorrectPin();
      }
    } catch (e) {
      if (mounted) {
        showMessageSnackBar(
          context: context,
          message: 'An error occurred: $e'.i18n,
          error: true,
        );
      }
    }
  }

  void _handleIncorrectPin() {
    _animationController.forward(from: 0.0);
    HapticFeedback.heavyImpact();
    _attempts++;
    // If attempts are exhausted, show the delete wallet dialog.
    if (_attempts >= 6) {
      _showConfirmationDialog(context, ref);
      setState(() => pin = '');
    } else {
      int remainingAttempts = 6 - _attempts;
      showMessageSnackBar(
        context: context,
        message:
        '${'Invalid PIN'.i18n}. $remainingAttempts ${'attempts remaining'.i18n}',
        error: true,
      );
      setState(() => pin = '');
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

        if (authenticated && mounted) {
          _unlockApp(context, ref);
        }
      }
    } catch (e) {
      // Silently handle errors (e.g., biometric unavailable or user cancels)
      // The user can still use their PIN.
    }
  }

  void _unlockApp(BuildContext context, WidgetRef ref) {
    ref.read(loadingProvider.notifier).state = true;
    try {
      _attempts = 0;
      ref.read(appLockedProvider.notifier).state = false;
      ref.read(sendTxProvider.notifier).resetToDefault();
      ref.read(sendBlocksProvider.notifier).state = 1;
      ref.read(addressProvider);
      context.go('/home');
    } finally {
      if (mounted) {
        ref.read(loadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _forgotPin(BuildContext context, WidgetRef ref) async {
    final authModel = ref.read(authModelProvider);
    await authModel.deleteAuthentication();
    ref.read(appLockedProvider.notifier).state = true;
    ref.invalidate(bitcoinConfigProvider);
    ref.invalidate(liquidConfigProvider);
    RestartWidget.restartApp(context);
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    // Watch the settings provider to get the biometrics state
    final biometricsEnabled = ref.watch(settingsProvider.select((s) => s.biometricsEnabled));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  children: [
                    SizedBox(height: 60.h),
                    Text(
                      'Welcome Back'.i18n,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Enter your PIN to unlock'.i18n,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                    const Spacer(),
                    // Animated PIN indicator for shake effect
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_animation.value, 0),
                          child: child,
                        );
                      },
                      child: PinProgressIndicator(
                        currentLength: pin.length,
                      ),
                    ),
                    const Spacer(flex: 2),
                    CustomKeypad(
                      onDigitPressed: (digit) {
                        if (pin.length < 6) {
                          HapticFeedback.lightImpact();
                          setState(() => pin += digit);
                          if (pin.length == 6) {
                            _checkPin(context, ref);
                          }
                        }
                      },
                      onBackspacePressed: () {
                        if (pin.isNotEmpty) {
                          HapticFeedback.lightImpact();
                          setState(
                                  () => pin = pin.substring(0, pin.length - 1));
                        }
                      },
                      // Conditionally provide the callback based on the setting
                      onBiometricPressed: biometricsEnabled
                          ? () => _checkBiometrics(context, ref)
                          : null,
                    ),
                    SizedBox(height: 20.h),
                    // Use the new TextButton to trigger the dialog
                    TextButton(
                      onPressed: () => _showConfirmationDialog(context, ref),
                      child: Text(
                        'Forgot PIN?'.i18n,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
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
      ),
    );
  }
}