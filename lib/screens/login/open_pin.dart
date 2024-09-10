import 'package:Satsails/screens/settings/settings.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:local_auth/local_auth.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OpenPin extends ConsumerWidget {
  final TextEditingController _pinController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  OpenPin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometrics(context, ref));
    final openSeed = ref.watch(sendToSeed);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Center(child: Text('Enter PIN'.i18n(ref), style: const TextStyle(color: Colors.white))),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: openSeed ? true : false,
          leading: openSeed ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ) : null,
        ),
        body: Center(
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
                    onChanged: (value) {
                      _pinController.text = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a PIN'.i18n(ref);
                      } else if (value.length != 6) {
                        return 'PIN must be exactly 6 digits'.i18n(ref);
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
                  child: CustomButton(text: 'Unlock'.i18n(ref), onPressed: () => _checkPin(context, ref)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => _showConfirmationDialog(context, ref),
                  child: Text(
                    'Forgot PIN'.i18n(ref),
                    style: const TextStyle(fontSize: 20.0, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkPin(BuildContext context, WidgetRef ref) async {
    final authModel = ref.read(authModelProvider);
    final pinText = await authModel.getPin();
    final openSeed = ref.watch(sendToSeed);

    if (pinText == _pinController.text) {
     openSeed ? Navigator.pushReplacementNamed(context, '/seed_words') : Navigator.pushReplacementNamed(context, '/home');
    } else {
      Fluttertoast.showToast(
          msg: 'Invalid PIN'.i18n(ref),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<void> _checkBiometrics(BuildContext context, WidgetRef ref) async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final openSeed = ref.watch(sendToSeed);
    if (canCheckBiometrics) {
      bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to open the app'.i18n(ref),
          options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true
          )
      );
      if (authenticated) {
        openSeed ? Navigator.pushReplacementNamed(context, '/seed_words') : Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red,
                child: Icon(Icons.warning, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Delete Account?'.i18n(ref),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'All information will be permanently deleted.'.i18n(ref),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    ),
                    child: Text(
                      'Cancel'.i18n(ref),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    ),
                    child: Text(
                      'Delete'.i18n(ref),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () async {
                      _forgotPin(context, ref);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _forgotPin(BuildContext context, WidgetRef ref) async {
    final authModel = ref.read(authModelProvider);
    await authModel.deleteAuthentication();
    Navigator.pushReplacementNamed(context, '/');
  }
}