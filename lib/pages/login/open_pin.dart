import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:local_auth/local_auth.dart';

class OpenPin extends StatefulWidget {
  @override
  _OpenPinState createState() => _OpenPinState();
}

class _OpenPinState extends State<OpenPin> {
  final _pinController = TextEditingController();
  final _storage = FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkPin() async {
    String? storedPin = await _storage.read(key: 'pin');
    if (storedPin != null && storedPin == _pinController.text) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Invalid PIN'),
              content: Text('The PIN you entered is incorrect.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    }
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (canCheckBiometrics) {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to open the app',
      );
      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter PIN'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // Center items vertically
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkPin,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.cyan[400]!),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(const Size(300.0, 60.0)),
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
}