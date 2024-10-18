import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SetPin extends ConsumerWidget {
  const SetPin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String pin = '';
    String confirmPin = '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Set PIN'.i18n(ref), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Instruction for choosing a PIN
                Text(
                  'Choose a 6-digit PIN'.i18n(ref),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: true,
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
                      return null;
                    },
                    onChanged: (value) {
                      pin = value; // Store the entered PIN
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Instruction for confirming the PIN
                Text(
                  'Confirm PIN'.i18n(ref),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: true,
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
                      if (value != pin) {
                        return 'PINs do not match'.i18n(ref); // Custom error message
                      }
                      return null;
                    },
                    onChanged: (value) {
                      confirmPin = value; // Store the confirmation PIN
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 106),
                  child: CustomButton(
                    text: 'Set PIN'.i18n(ref),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final authModel = ref.read(authModelProvider);

                        // Set the PIN
                        await authModel.setPin(pin);

                        // Optionally handle mnemonic
                        final mnemonic = await authModel.getMnemonic();
                        if (mnemonic == null || mnemonic.isEmpty) {
                          await authModel.setMnemonic(await authModel.generateMnemonic());
                        }
                        context.go('/home');
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Please enter a 6 digit PIN'.i18n(ref),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
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
    );
  }
}
