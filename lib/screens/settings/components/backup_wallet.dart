import 'dart:math';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BackupWallet extends ConsumerStatefulWidget {
  const BackupWallet({super.key});

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
        message: 'Failed to load mnemonic.'.i18n,
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
    if (mnemonicWords == null || mnemonicWords!.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Backup Wallet'.i18n,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.sp),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Backup Wallet'.i18n,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24.sp),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the correct word for each position:'.i18n,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedIndices.length,
                  itemBuilder: (context, index) {
                    int wordIndex = selectedIndices[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0x00333333).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0x00333333).withOpacity(0.4),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${'Word in position'.i18n} ${wordIndex + 1}:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: quizOptions[wordIndex]!.map((option) {
                                  bool isSelected = userSelections[wordIndex] == option;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        userSelections[wordIndex] = option;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.orangeAccent : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(4.r),
                                        border: Border.all(
                                          color: isSelected ? Colors.orangeAccent : Colors.grey[600]!,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
                child: CustomButton(
                  text: 'Verify'.i18n,
                  onPressed: () {
                    if (checkAnswers()) {
                      ref.read(settingsProvider.notifier).setBackup(true);
                      FocusScope.of(context).unfocus();
                      showMessageSnackBar(
                        message: 'Wallet successfully backed up!'.i18n,
                        error: false,
                        context: context,
                      );
                      context.go('/home');
                    } else {
                      FocusScope.of(context).unfocus();
                      showMessageSnackBar(
                        message: 'Incorrect selections. Please try again.'.i18n,
                        error: true,
                        context: context,
                      );
                    }
                  },
                  primaryColor: Colors.green,
                  secondaryColor: Colors.green,
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}