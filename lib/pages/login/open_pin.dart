import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pinController = TextEditingController();
  final _storage = FlutterSecureStorage();

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
        builder: (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(
                labelText: 'Enter your PIN',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _checkPin,
              child: Text('Enter'),
            ),
          ],
        ),
      ),
    );
  }
}