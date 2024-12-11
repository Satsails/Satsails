import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:local_auth/local_auth.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';

class SeedWordsPin extends ConsumerStatefulWidget {
  SeedWordsPin({super.key});

  @override
  _SeedWordsPinState createState() => _SeedWordsPinState();
}

class _SeedWordsPinState extends ConsumerState<SeedWordsPin> {
  final TextEditingController _pinController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricChecked = false;

  @override
  void initState() {
    super.initState();
    // Trigger the biometric check when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometrics(context, ref));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Enter PIN'.i18n(ref), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop(); // Back button action
          },
        ),
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
      context.push('/seed_words'); // Redirect to the seed words screen on successful authentication
    } else {
      showMessageSnackBar(
        message: 'Invalid PIN'.i18n(ref),
        error: true,
        context: context,
      );
    }
  }

  Future<void> _checkBiometrics(BuildContext context, WidgetRef ref) async {
    if (_biometricChecked) return;

    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

    if (canCheckBiometrics) {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to view seed words'.i18n(ref),
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        context.push('/seed_words');
      }
    }

    _biometricChecked = true;
  }
}