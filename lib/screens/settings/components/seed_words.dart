import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Seed Words'.i18n(ref),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else {
            List<String> words = snapshot.data!.split(' ');
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}. ${words[index]}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
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
