import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/creation/set_pin.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';

// Add this line to define the loadingProvider
final loadingProvider = StateProvider<bool>((ref) => false);

class ConfirmPin extends ConsumerStatefulWidget {
  const ConfirmPin({Key? key}) : super(key: key);

  @override
  _ConfirmPinState createState() => _ConfirmPinState();
}

class _ConfirmPinState extends ConsumerState<ConfirmPin> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController confirmPinController = TextEditingController();

  @override
  void dispose() {
    confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read the original PIN from pinProvider
    final originalPin = ref.read(pinProvider);

    // Watch the loading state
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Confirm PIN'.i18n(ref),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Confirm your 6-digit PIN'.i18n(ref),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscureText: true,
                        controller: confirmPinController,
                        keyboardType: TextInputType.number,
                        textStyle: const TextStyle(color: Colors.white),
                        pinTheme: PinTheme(
                          inactiveColor: Colors.white,
                          selectedColor: Colors.red,
                          activeColor: Colors.orange,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length != 6) {
                            return '';
                          }
                          if (value != originalPin) {
                            return 'PINs do not match'.i18n(ref);
                          }
                          return null;
                        },
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 106),
                      child: CustomButton(
                        text: 'Set PIN'.i18n(ref),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            // Set the loading state to true
                            ref.read(loadingProvider.notifier).state = true;

                            try {
                              final authModel = ref.read(authModelProvider);

                              // Set the PIN (using the stored original PIN)
                              await authModel.setPin(originalPin);

                              // Optionally handle mnemonic
                              final mnemonic = await authModel.getMnemonic();
                              if (mnemonic == null || mnemonic.isEmpty) {
                                await authModel.setMnemonic(await authModel.generateMnemonic());
                              }

                              ref.read(pinProvider.notifier).state = '';

                              try {
                                // Await the registerProvider future
                                await ref.read(registerProvider.future);
                              } catch (e) {
                                // Ignore errors because we will have a chance to set Lightning later
                              }

                              // Navigate to the home screen
                              if (mounted) {
                                context.go('/home');
                              }
                            } catch (e) {

                              showMessageSnackBar(
                                message: 'An error occurred'.i18n(ref),
                                error: true,
                                context: context,
                              );
                            } finally {
                              // Set the loading state back to false
                              ref.read(loadingProvider.notifier).state = false;
                            }
                          } else {
                            showMessageSnackBar(
                              message: 'PINs do not match'.i18n(ref),
                              error: true,
                              context: context,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Display the loading indicator when isLoading is true
          if (isLoading)
            Container(
              color: Colors.black54, // Optional: semi-transparent background
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
