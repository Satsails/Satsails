import 'package:Satsails/screens/charge/components/pix_buttons.dart';
import 'package:Satsails/screens/charge/components/pix_history.dart';
import 'package:Satsails/screens/charge/components/receive_pix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Pix extends ConsumerWidget {
  const Pix({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedButton = ref.watch(topSelectedButtonProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pix'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PixButtons(),
            Expanded(
              child: selectedButton == 'Pix Address' ? ReceivePix() : PixHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
