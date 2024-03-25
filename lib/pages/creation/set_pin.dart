import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../helpers/account_type.dart';
import '../../helpers/networks.dart';

class SetPin extends StatefulWidget {
  const SetPin({super.key});

  @override
  _SetPinState createState() => _SetPinState();
}

class _SetPinState extends State<SetPin> {
  final _formKey = GlobalKey<FormState>();
  final _storage = FlutterSecureStorage();
  String _pin = '';

  Future<void> _setPin() async {
    if (_formKey.currentState!.validate()) {
      await _storage.write(key: 'pin', value: _pin);
      // String mnemonic = await greenwallet.Channel('ios_wallet').getMnemonic();
      // await greenwallet.Channel('ios_wallet').createSubAccount(mnemonic: mnemonic, walletType: AccountType.segWit.toString());
      // await greenwallet.Channel('ios_wallet').createSubAccount(mnemonic: mnemonic, walletType: AccountType.segWit.toString(), connectionType: NetworkSecurityCase.liquidSS.network);
      // await _storage.write(key: 'mnemonic', value: mnemonic);
      Navigator.pushNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set PIN'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
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
                    _pin = value;
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _setPin,
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
                    'Set PIN',
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
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