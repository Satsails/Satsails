import 'package:Satsails/screens/charge/components/pix_buttons.dart';
import 'package:Satsails/screens/charge/components/pix_history.dart';
import 'package:Satsails/screens/charge/components/receive_pix.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Pix extends ConsumerWidget {
  const Pix({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedButton = ref.watch(topSelectedButtonProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pix', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PixButtons(),
            Expanded(
              child: selectedButton == 'Pix Address' ? const ReceivePix() : const PixHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
