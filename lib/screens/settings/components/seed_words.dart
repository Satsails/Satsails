import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails_wallet/providers/mnemonic_provider.dart';

class SeedWords extends ConsumerWidget {
  const SeedWords({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mnemonicFuture = ref.watch(mnemonicProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Words'),
      ),
      body: mnemonicFuture.when(
        data: (mnemonicModel) {
          List<String> words = mnemonicModel.mnemonic!.split(' ');
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: List.generate(words.length, (index) {
                return Card(
                  color: Colors.blueGrey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${index + 1}. ${words[index]}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}