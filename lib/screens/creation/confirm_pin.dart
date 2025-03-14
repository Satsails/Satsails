import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_config_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/screens/creation/set_pin.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:Satsails/screens/shared/custom_button.dart';

// Define the loading provider
final loadingProvider = StateProvider<bool>((ref) => false);

class ConfirmPin extends ConsumerStatefulWidget {
  const ConfirmPin({Key? key}) : super(key: key);

  @override
  _ConfirmPinState createState() => _ConfirmPinState();
}

class _ConfirmPinState extends ConsumerState<ConfirmPin> {
  String confirmPin = '';

  // Asynchronous method to handle setting the PIN (only called when PINs match)
  Future<void> _handleSetPin(String originalPin) async {
    ref.read(loadingProvider.notifier).state = true;
    try {
      final authModel = ref.read(authModelProvider);
      await authModel.setPin(originalPin);
      final mnemonic = await authModel.getMnemonic();
      if (mnemonic == null || mnemonic.isEmpty) {
        await authModel.setMnemonic(await authModel.generateMnemonic());
      }
      ref.read(pinProvider.notifier).state = '';
      try {
        await ref.read(registerProvider.future);
      } catch (e) {
        // Ignore errors
      }
      if (mounted) {
        ref.read(appLockedProvider.notifier).state = false;
        ref.invalidate(bitcoinConfigProvider);
        ref.invalidate(liquidConfigProvider);
        context.go('/home');
      }
    } catch (e) {
      showMessageSnackBar(
        message: 'An error occurred'.i18n,
        error: true,
        context: context,
      );
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalPin = ref.read(pinProvider);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Confirm PIN'.i18n,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm your 6-digit PIN'.i18n,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  PinProgressIndicator(currentLength: confirmPin.length, totalDigits: 6),
                  const SizedBox(height: 40),
                  CustomKeypad(
                    onDigitPressed: (digit) {
                      if (confirmPin.length < 6) {
                        setState(() => confirmPin += digit);
                      }
                    },
                    onBackspacePressed: () {
                      if (confirmPin.isNotEmpty) {
                        setState(() => confirmPin = confirmPin.substring(0, confirmPin.length - 1));
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Set PIN'.i18n,
                    onPressed: () {
                      // Check PIN match synchronously
                      if (confirmPin.length == 6 && confirmPin == originalPin) {
                        _handleSetPin(originalPin); // Proceed with async PIN setting
                      } else {
                        FocusScope.of(context).unfocus();
                        showMessageSnackBar(
                          message: 'PINs do not match'.i18n,
                          error: true,
                          context: context,
                          top: true,
                        );
                      }
                    },
                    primaryColor: Colors.green,
                    secondaryColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                  color: Colors.orange,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Updated PinProgressIndicator to match SetPin
class PinProgressIndicator extends StatelessWidget {
  final int currentLength;
  final int totalDigits;

  const PinProgressIndicator({required this.currentLength, required this.totalDigits});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDigits, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentLength ? Colors.white : Colors.grey[600],
          ),
        );
      }),
    );
  }
}