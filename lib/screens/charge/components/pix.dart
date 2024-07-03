import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Pix extends ConsumerWidget {
  final String address = 'satsails@depix.info';

  const Pix({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final String cpfRegistered = ref.read(settingsProvider).identificationBr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Money with Pix'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Today you have sent X BRL, you can only send more X BRL today',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Min amount is 10 BRL',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Any amount below will be considered a donation',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Any amount amount above 5000 brl per day will be refunded. If you have sent more than 5000 brl, please contact our support on the settings tab via telegram.',
              ),
            ),
            SizedBox(height: 20),
            buildQrCode(address, context),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Pix key: ' + address,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Only send PIX from an account that has the CPF you registered ($cpfRegistered), otherwise we cannot process your transaction. If you made a mistake, please contact our support. on the settings tab via telegram.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}