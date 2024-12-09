import 'dart:math';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class BackupWallet extends ConsumerStatefulWidget {
  const BackupWallet({Key? key}) : super(key: key);

  @override
  _BackupWalletState createState() => _BackupWalletState();
}

class _BackupWalletState extends ConsumerState<BackupWallet> {
  List<String>? mnemonicWords;
  List<int> selectedIndices = [];
  Map<int, List<String>> quizOptions = {};
  Map<int, String> userSelections = {};

  @override
  void initState() {
    super.initState();
    fetchMnemonic();
  }

  Future<void> fetchMnemonic() async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();

    if (mnemonic != null && mnemonic.isNotEmpty) {
      setState(() {
        mnemonicWords = mnemonic.split(' ');
        generateQuiz();
      });
    } else {
      showMessageSnackBar(
        message: 'Failed to load mnemonic.'.i18n(ref),
        error: true,
        context: context,
      );
    }
  }

  void generateQuiz() {
    final random = Random();
    final mnemonicLength = mnemonicWords!.length;

    while (selectedIndices.length < 4) {
      int index = random.nextInt(mnemonicLength);
      if (!selectedIndices.contains(index)) {
        selectedIndices.add(index);
      }
    }

    for (var index in selectedIndices) {
      List<String> options = [mnemonicWords![index]];
      while (options.length < 3) {
        String word = mnemonicWords![random.nextInt(mnemonicLength)];
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
      if (userSelections[index] != mnemonicWords![index]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (mnemonicWords == null || mnemonicWords!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
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
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select the correct word for each position:'.i18n(ref),
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        Column(
                          children: quizOptions[wordIndex]!.map((option) {
                            return RadioListTile<String>(
                              title: Text(
                                option,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
              child: CustomButton(
                text: 'Verify'.i18n(ref),
                onPressed: () {
                  if (checkAnswers()) {
                    ref.read(settingsProvider.notifier).setBackup(true);
                    showMessageSnackBar(
                      message: 'Wallet successfully backed up!'.i18n(ref),
                      error: false,
                      context: context,
                    );
                    context.go('/home');
                  } else {
                    showMessageSnackBar(
                      message: 'Incorrect selections. Please try again.'.i18n(ref),
                      error: true,
                      context: context,
                    );
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
