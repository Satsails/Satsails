import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:local_auth/local_auth.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:quickalert/quickalert.dart';

class OpenPin extends ConsumerStatefulWidget {
  OpenPin({super.key});

  @override
  _OpenPinState createState() => _OpenPinState();
}

class _OpenPinState extends ConsumerState<OpenPin> {
  final TextEditingController _pinController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricChecked = false;
  int _attempts = 0; // Counter for tracking failed attempts

  @override
  void initState() {
    super.initState();
    // Trigger the biometric check when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometrics(context, ref));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Center(child: Text('Enter PIN'.i18n(ref), style: const TextStyle(color: Colors.white))),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
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

    if (pinText == _pinController.text) {
      _attempts = 0; // Reset the attempts counter on success
      context.go('/home');
    } else {
      _attempts++; // Increment the attempts counter

      // Check if the user has failed 6 times
      if (_attempts >= 6) {
        await _forgotPin(context, ref); // Trigger wallet deletion
      } else {
        int remainingAttempts = 6 - _attempts;
        showMessageSnackBar(
          context: context,
          message: 'Invalid PIN'.i18n(ref) + ' $remainingAttempts ' + 'attempts remaining'.i18n(ref),
          error: true,
        );
      }
    }
  }

  Future<void> _checkBiometrics(BuildContext context, WidgetRef ref) async {
    if (_biometricChecked) return;

    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;

    if (canCheckBiometrics) {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to open the app'.i18n(ref),
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        context.go('/home');
      }
    }

    _biometricChecked = true;
  }

  Future<void> _showConfirmationDialog(BuildContext context, WidgetRef ref) async {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Delete Account?'.i18n(ref),
      text: 'All information will be permanently deleted.'.i18n(ref),
      titleColor: Colors.redAccent,
      textColor: Colors.white70,
      backgroundColor: Colors.black87,
      headerBackgroundColor: Colors.black87,
      showCancelBtn: false,
      showConfirmBtn: false,
      widget: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CustomElevatedButton(
          onPressed: () async {
            context.pop();
            await _forgotPin(context, ref);
          },
          text: 'Delete wallet'.i18n(ref),
          backgroundColor: Colors.redAccent,
        ),
      ),
    );
  }


  Future<void> _forgotPin(BuildContext context, WidgetRef ref) async {
    final authModel = ref.read(authModelProvider);
    await authModel.deleteAuthentication(); // Delete the wallet
    context.go('/');
  }
}
