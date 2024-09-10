import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SetPin extends ConsumerWidget {
  const SetPin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Set PIN'.i18n(ref), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
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
                      ref.read(authModelProvider).setPin(value);
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
                        final mnemonic = await authModel.getMnemonic();
                        if (mnemonic == null || mnemonic.isEmpty) {
                          await authModel.setMnemonic(await authModel.generateMnemonic());
                        }
                        Navigator.pushReplacementNamed(context, '/home');
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
