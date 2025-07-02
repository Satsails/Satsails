import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_config_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/screens/creation/set_pin.dart'; // Contains pinProvider
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Define the loading provider for this screen
final confirmPinLoadingProvider = StateProvider<bool>((ref) => false);

class ConfirmPin extends ConsumerStatefulWidget {
  const ConfirmPin({super.key});

  @override
  _ConfirmPinState createState() => _ConfirmPinState();
}

class _ConfirmPinState extends ConsumerState<ConfirmPin> with SingleTickerProviderStateMixin {
  String confirmPin = '';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
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

  // Asynchronous method to handle setting the PIN (only called when PINs match)
  Future<void> _handleSetPin(String originalPin) async {
    ref.read(confirmPinLoadingProvider.notifier).state = true;
    try {
      final authModel = ref.read(authModelProvider);
      await authModel.setPin(originalPin);
      final mnemonic = await authModel.getMnemonic();
      if (mnemonic == null || mnemonic.isEmpty) {
        await authModel.setMnemonic(await authModel.generateMnemonic());
      }
      ref.read(pinProvider.notifier).state = '';
      if (mounted) {
        // Assuming appLockedProvider exists from your previous code
        // ref.read(appLockedProvider.notifier).state = false;
        ref.invalidate(bitcoinConfigProvider);
        ref.invalidate(liquidConfigProvider);
        context.go('/home');
      }
    } catch (e) {
      if(mounted) {
        showMessageSnackBar(
          message: 'An error occurred'.i18n,
          error: true,
          context: context,
        );
      }
    } finally {
      if(mounted) {
        ref.read(confirmPinLoadingProvider.notifier).state = false;
      }
    }
  }

  void _handlePinMismatch() {
    _animationController.forward(from: 0.0);
    HapticFeedback.heavyImpact();
    showMessageSnackBar(
      message: 'PINs do not match'.i18n,
      error: true,
      context: context,
    );
    setState(() => confirmPin = '');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final originalPin = ref.watch(pinProvider);
    final isLoading = ref.watch(confirmPinLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    'Confirm Your PIN'.i18n,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Enter the same PIN again to verify'.i18n,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.sp,
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_animation.value, 0),
                        child: child,
                      );
                    },
                    child: PinProgressIndicator(currentLength: confirmPin.length),
                  ),
                  const Spacer(flex: 2),
                  CustomKeypad(
                    onDigitPressed: (digit) {
                      if (confirmPin.length < 6) {
                        HapticFeedback.lightImpact();
                        setState(() => confirmPin += digit);
                      }
                    },
                    onBackspacePressed: () {
                      if (confirmPin.isNotEmpty) {
                        HapticFeedback.lightImpact();
                        setState(() => confirmPin =
                            confirmPin.substring(0, confirmPin.length - 1));
                      }
                    },
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: confirmPin.length == 6 ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: CustomButton(
                      text: 'Set PIN'.i18n,
                      onPressed: confirmPin.length == 6
                          ? () {
                        if (confirmPin == originalPin) {
                          _handleSetPin(originalPin);
                        } else {
                          _handlePinMismatch();
                        }
                      }
                          : () {},
                      primaryColor: Colors.green,
                      secondaryColor: Colors.green,
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
    );
  }
}

