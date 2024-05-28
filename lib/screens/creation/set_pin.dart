import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SetPin extends ConsumerWidget {
  const SetPin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    // Get the screen size using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Set PIN'.i18n(ref), style: TextStyle(fontSize: screenWidth * 0.05)), // 5% of screen width
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  autoFocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 6) {
                      return '';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ref.read(authModelProvider).setPin(value);
                  },
                  textStyle: TextStyle(fontSize: screenWidth * 0.04), // 4% of screen width
                ),
                SizedBox(height: screenHeight * 0.01), // 1% of screen height
                SizedBox(
                  width: screenWidth * 0.8, // 80% of screen width
                  height: screenHeight * 0.09, // 9% of screen height
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
                            fontSize: screenWidth * 0.04, // 4% of screen width
                          );
                        }
                      }
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