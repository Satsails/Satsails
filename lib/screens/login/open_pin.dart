import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_config_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/screens/shared/custom_alert_dialog.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/services/background_sync_service.dart'; // Import the service
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:local_auth/local_auth.dart';

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
        await _unlockApp(context, ref); // Changed to await
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
    setState(() {
      _attempts++;
      pin = '';
    });

    if (_attempts >= 6) {
      _showForgotPinConfirmation(context, ref); // Changed to show dialog before deleting
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
          await _unlockApp(context, ref); // Changed to await
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  Future<void> _unlockApp(BuildContext context, WidgetRef ref) async {
    ref.read(loadingProvider.notifier).state = true;
    try {
      _attempts = 0;

      // *** CHANGE: Start the background service on successful unlock ***
      final container = ProviderScope.containerOf(context);
      BackgroundSyncService().start(container);

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
    // *** CHANGE: Stop the background service before deleting wallet ***
    BackgroundSyncService().stop();

    final authModel = ref.read(authModelProvider);
    await authModel.deleteAuthentication();
    ref.read(appLockedProvider.notifier).state = true;
    ref.invalidate(bitcoinConfigProvider);
    ref.invalidate(liquidConfigProvider);
    RestartWidget.restartApp(context);
  }

  Future<void> _showForgotPinConfirmation(
      BuildContext context, WidgetRef ref) async {
    showCustomAlertDialog(
      context: context,
      title: 'Delete Account?'.i18n,
      content: 'All information will be permanently deleted. This action is irreversible.'.i18n,
      actions: [
        CustomButton(
          onPressed: () => Navigator.of(context).pop(),
          text: 'Cancel'.i18n,
          primaryColor: Colors.grey.withOpacity(0.2),
          secondaryColor: Colors.grey.withOpacity(0.2),
          textColor: Colors.white,
        ),
        CustomButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _forgotPin(context, ref);
          },
          text: 'Delete Wallet'.i18n,
          primaryColor: Colors.redAccent,
          secondaryColor: Colors.red,
          textColor: Colors.white,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI code is the same, no changes needed here) ...
    final isLoading = ref.watch(loadingProvider);
    final biometricsEnabled = ref.watch(settingsProvider.select((s) => s.biometricsEnabled));

    String attemptsMessage = '';
    if (_attempts > 0) {
      int remainingAttempts = 6 - _attempts;
      if (remainingAttempts == 1) {
        attemptsMessage = 'Last attempt. If incorrect, the wallet will be deleted.'.i18n;
      } else {
        attemptsMessage = '$remainingAttempts attempts remaining'.i18n;
      }
    }

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
                    if (_attempts > 0)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Text(
                          attemptsMessage,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
                      onBiometricPressed: biometricsEnabled
                          ? () => _checkBiometrics(context, ref)
                          : null,
                    ),
                    SizedBox(height: 20.h),
                    TextButton(
                      onPressed: () => _showForgotPinConfirmation(context, ref),
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