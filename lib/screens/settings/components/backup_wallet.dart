import 'dart:math';
import 'dart:ui'; // Required for BackdropFilter
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/localizations.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure ref is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMnemonic();
    });
  }

  Future<void> fetchMnemonic() async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();

    if (mounted) {
      if (mnemonic != null && mnemonic.isNotEmpty) {
        setState(() {
          mnemonicWords = mnemonic.split(' ');
          generateQuiz();
          _isLoading = false;
        });
      } else {
        showMessageSnackBar(
          message: 'Failed to load mnemonic.'.i18n,
          error: true,
          context: context,
        );
        // Pop the screen if the mnemonic can't be loaded
        context.pop();
      }
    }
  }

  void generateQuiz() {
    if (mnemonicWords == null) return;
    final random = Random();
    final mnemonicLength = mnemonicWords!.length;
    final newSelectedIndices = <int>{};

    while (newSelectedIndices.length < 4) {
      int index = random.nextInt(mnemonicLength);
      newSelectedIndices.add(index);
    }

    selectedIndices = newSelectedIndices.toList();

    for (var index in selectedIndices) {
      final correctWord = mnemonicWords![index];
      final options = <String>{correctWord};
      while (options.length < 3) {
        String word = mnemonicWords![random.nextInt(mnemonicLength)];
        options.add(word);
      }
      final shuffledOptions = options.toList()..shuffle();
      quizOptions[index] = shuffledOptions;
    }
  }

  bool checkAnswers() {
    if (userSelections.length < selectedIndices.length) return false;
    for (var index in selectedIndices) {
      if (userSelections[index] != mnemonicWords![index]) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Backup Wallet'.i18n,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedIndices.length,
                  itemBuilder: (context, index) {
                    int wordIndex = selectedIndices[index];
                    return _buildQuizItem(wordIndex);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: CustomButton(
                  text: 'Verify Backup'.i18n,
                  onPressed: () {
                    if (checkAnswers()) {
                      ref.read(settingsProvider.notifier).setBackup(true);
                      showMessageSnackBar(
                        message: 'Wallet successfully backed up!'.i18n,
                        error: false,
                        context: context,
                      );
                      context.go('/home');
                    } else {
                      showMessageSnackBar(
                        message: 'Incorrect selections. Please try again.'.i18n,
                        error: true,
                        context: context,
                      );
                    }
                  },
                  primaryColor: Colors.white.withOpacity(0.2),
                  secondaryColor: Colors.white.withOpacity(0.15),
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizItem(int wordIndex) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'Word'.i18n} ${wordIndex + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
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
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 16.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      ),
    );
  }
}
