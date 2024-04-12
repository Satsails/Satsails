import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:satsails/providers/auth_provider.dart';
import 'package:satsails/screens/shared/custom_button.dart';

class SetPin extends ConsumerWidget {
  const SetPin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Set PIN'),
      ),
      body: Center(
        child: Form(
          key: formKey,
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
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Set PIN',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final authModel = ref.read(authModelProvider);
                      final mnemonic = await authModel.getMnemonic();
                      if (mnemonic == null || mnemonic.isEmpty) {
                        await authModel.setMnemonic(await authModel.generateMnemonic());
                      }
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid 6 digit pin'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
