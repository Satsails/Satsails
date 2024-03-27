import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:satsails_wallet/providers/pin_provider.dart';
import 'package:local_auth/local_auth.dart';

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
              ElevatedButton(
                onPressed: () => _checkPin(context, ref),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.cyan[400]!),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                      const Size(300.0, 60.0)),
                ),
                child: const Text(
                  'Enter PIN',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkPin(BuildContext context, WidgetRef ref) async {
    final pin = ref.watch(pinProvider.future);
    if (pin.then((pin) => pin.pin) == _pinController.text) {
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
}