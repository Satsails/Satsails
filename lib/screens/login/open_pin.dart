import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:local_auth/local_auth.dart';
import 'package:satsails/providers/auth_provider.dart';
import 'package:satsails/screens/shared/custom_button.dart';

class OpenPin extends ConsumerWidget {
  final TextEditingController _pinController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance?.addPostFrameCallback((_) =>
        _checkBiometrics(context));

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Enter PIN')),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: true,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _pinController.text = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a PIN';
                  } else if (value.length != 6) {
                    return 'PIN must be exactly 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomButton(text: 'Unlock', onPressed: () => _checkPin(context, ref)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _showConfirmationDialog(context, ref),
                child: const Text(
                  'Forgot PIN',
                  style: TextStyle(fontSize: 20.0, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkPin(BuildContext context, WidgetRef ref) async {
    final authModel = ref.read(authModelProvider);
    final pinText = await authModel.getPin();
    if (pinText == _pinController.text) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid PIN'),
        ),
      );
    }
  }

  Future<void> _checkBiometrics(BuildContext context) async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (canCheckBiometrics) {
      bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Please authenticate to open the app',
          options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true
          )
      );
      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _showConfirmationDialog(BuildContext context, WidgetRef ref) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset PIN'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This will delete all your data and reset your PIN.'),
                Text('Do you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _forgotPin(context, ref);
              },
            ),
          ],
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