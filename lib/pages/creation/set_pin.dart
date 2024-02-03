import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SetPin extends StatefulWidget {
  const SetPin({super.key});

  @override
  _SetPinState createState() => _SetPinState();
}

class _SetPinState extends State<SetPin> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _storage = FlutterSecureStorage();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _setPin() async {
    if (_formKey.currentState!.validate()) {
      await _storage.write(key: 'pin', value: _pinController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set PIN'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _pinController,
                decoration: const InputDecoration(
                  labelText: 'Enter your PIN',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a PIN';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: _setPin,
                child: Text('Set PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}