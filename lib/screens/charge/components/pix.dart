import 'package:Satsails/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Pix extends ConsumerWidget {
  final String address = 'satsails@depix.info';

  const Pix({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixPaymentCodeFuture = ref.read(authModelProvider).getPaymentCode();

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
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Today you have sent X BRL, you can only send more X BRL today',
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Min amount is 10 BRL',
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Any amount below will be considered a donation',
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Any amount amount above 5000 brl per day will be refunded. If you have sent more than 5000 brl, please contact our support on the settings tab via telegram.',
              ),
            ),
            const SizedBox(height: 20),
            buildQrCode(address, context),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Pix key: ' + address,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<String>(
                future: pixPaymentCodeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Text(
                      "please add this code to your pix: ${snapshot.data}",
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return const Text('No payment code available');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
