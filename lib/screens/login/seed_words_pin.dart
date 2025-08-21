import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_alert_dialog.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeedWordsPin extends ConsumerStatefulWidget {
  const SeedWordsPin({super.key});

  @override
  _SeedWordsPinState createState() => _SeedWordsPinState();
}

class _SeedWordsPinState extends ConsumerState<SeedWordsPin> with SingleTickerProviderStateMixin {
  String pin = '';
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;

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
    setState(() => _isLoading = true);
    final authModel = ref.read(authModelProvider);
    final storedPin = await authModel.getPin();

    if (storedPin == pin) {
      context.push('/seed_words');
    } else {
      _animationController.forward(from: 0.0);
      HapticFeedback.heavyImpact();
      showMessageSnackBar(
        context: context,
        message: 'Invalid PIN'.i18n,
        error: true,
      );
      setState(() => pin = '');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBiometrics(BuildContext context, WidgetRef ref) async {
    final biometricsEnabled = ref.read(settingsProvider).biometricsEnabled;
    if (!biometricsEnabled) return;

    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to view seed words'.i18n,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        if (authenticated && mounted) {
          context.push('/seed_words');
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final biometricsEnabled = ref.watch(settingsProvider.select((s) => s.biometricsEnabled));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Enter PIN'.i18n,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Enter your PIN to view seed words'.i18n,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_animation.value, 0),
                          child: child,
                        );
                      },
                      child: PinProgressIndicator(currentLength: pin.length),
                    ),
                    SizedBox(height: 60.h),
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
                          setState(() => pin = pin.substring(0, pin.length - 1));
                        }
                      },
                      onBiometricPressed: biometricsEnabled
                          ? () => _checkBiometrics(context, ref)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
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
