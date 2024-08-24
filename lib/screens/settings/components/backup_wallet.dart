import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BackupWallet extends ConsumerStatefulWidget {
  const BackupWallet({super.key});

  @override
  _BackupWalletState createState() => _BackupWalletState();
}

class _BackupWalletState extends ConsumerState<BackupWallet> {
  late List<String> mnemonicWords;
  List<int> selectedIndices = [];
  Map<int, List<String>> quizOptions = {};
  Map<int, String> userSelections = {};

  @override
  void initState() {
    super.initState();
    fetchMnemonic();
  }

  void fetchMnemonic() async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();
    setState(() {
      mnemonicWords = mnemonic!.split(' ');
      generateQuiz();
    });
  }

  void generateQuiz() {
    final random = Random();
    while (selectedIndices.length < 4) {
      int index = random.nextInt(mnemonicWords.length);
      if (!selectedIndices.contains(index)) {
        selectedIndices.add(index);
      }
    }

    for (var index in selectedIndices) {
      List<String> options = [mnemonicWords[index]];
      while (options.length < 3) {
        String word = mnemonicWords[random.nextInt(mnemonicWords.length)];
        if (!options.contains(word)) {
          options.add(word);
        }
      }
      options.shuffle();
      quizOptions[index] = options;
    }
  }

  bool checkAnswers() {
    for (var index in selectedIndices) {
      if (userSelections[index] != mnemonicWords[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (mnemonicWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Backup Wallet'.i18n(ref)),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Backup Wallet'.i18n(ref),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select the correct word for each position:'.i18n(ref),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: selectedIndices.length,
                itemBuilder: (context, index) {
                  int wordIndex = selectedIndices[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${'Word in position'.i18n(ref)} ${wordIndex + 1}:',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Column(
                          children: quizOptions[wordIndex]!.map((option) {
                            return RadioListTile<String>(
                              title: Text(option, style: const TextStyle(color: Colors.white)),
                              value: option,
                              groupValue: userSelections[wordIndex],
                              onChanged: (value) {
                                setState(() {
                                  userSelections[wordIndex] = value!;
                                });
                              },
                              activeColor: Colors.orangeAccent,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            CustomButton(
              text: 'Verify'.i18n(ref),
              onPressed: () {
                if (checkAnswers()) {
                  ref.read(settingsProvider.notifier).setBackup(true);
                  Fluttertoast.showToast(
                    msg: 'Wallet successfully backed up!'.i18n(ref),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  Fluttertoast.showToast(
                    msg: 'Incorrect selections. Please try again.'.i18n(ref),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
