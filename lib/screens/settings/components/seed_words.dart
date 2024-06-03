import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';

class SeedWords extends ConsumerWidget {
  const SeedWords({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authModel = ref.read(authModelProvider);
    final mnemonicFuture = authModel.getMnemonic();
    final backupDone = ref.watch(settingsProvider).backup;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Seed Words'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/settings');
          },
        ),
      ),
      body: FutureBuilder<String?>(
        future: mnemonicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String> words = snapshot.data!.split(' ');
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      children: List.generate(words.length, (index) {
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${index + 1}. ${words[index]}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  if (!backupDone)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CustomButton(
                      text: 'Backup Wallet'.i18n(ref),
                      onPressed: () {
                        Navigator.pushNamed(context, '/backup_wallet');
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
