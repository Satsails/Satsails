import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReceivePix extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = "satsails@depix.info";
    final pixPaymentCodeFuture = ref.watch(settingsProvider.select((settings) => settings.pixPaymentCode));

    return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Today you have sent X BRL, you can only send more X BRL today'.i18n(ref),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Min amount is 10 BRL'.i18n(ref),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Any amount below will be considered a donation'.i18n(ref),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Any amount above 5000 BRL per day will be refunded. If you have sent more than 5000 BRL, please contact our support on the settings tab via telegram.'.i18n(ref),
                ),
              ),
              const SizedBox(height: 20),
              buildQrCode(address, context),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Pix key: $address'.i18n(ref),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Pix payment code: $pixPaymentCodeFuture'.i18n(ref),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
