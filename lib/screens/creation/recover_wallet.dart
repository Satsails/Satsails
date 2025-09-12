import 'dart:ui'; // Required for BackdropFilter
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/words_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecoverWallet extends ConsumerStatefulWidget {
  const RecoverWallet({super.key});

  @override
  _RecoverWalletState createState() => _RecoverWalletState();
}

class _RecoverWalletState extends ConsumerState<RecoverWallet>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
  List.generate(24, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(24, (_) => FocusNode());
  List<String> _filteredWords = [];
  int _totalWords = 12;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() => _onTextChanged(i));
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          _onTextChanged(i);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(int index) {
    if (!_focusNodes[index].hasFocus) {
      if (_filteredWords.isNotEmpty) {
        setState(() => _filteredWords = []);
      }
      return;
    }

    final query = _controllers[index].text;
    final wordsState = ref.read(wordsProvider);

    if (query.isEmpty) {
      setState(() => _filteredWords = []);
      return;
    }

    if (wordsState.words != null) {
      final filtered = wordsState.words!
          .where((word) => word.toLowerCase().startsWith(query.toLowerCase()))
          .take(4) // Show up to 4 suggestions
          .toList();
      setState(() => _filteredWords = filtered);
    }
  }

  void _onWordSelected(String word) {
    final focusedIndex = _focusNodes.indexWhere((node) => node.hasFocus);

    if (focusedIndex != -1) {
      _controllers[focusedIndex].text = word;
      _controllers[focusedIndex].selection = TextSelection.fromPosition(
          TextPosition(offset: _controllers[focusedIndex].text.length)); // Move cursor to end

      if (focusedIndex < _totalWords - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[focusedIndex + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
      setState(() => _filteredWords = []);
    }
  }

  Future<void> _recoverAccount(BuildContext context) async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = _controllers
        .take(_totalWords)
        .map((controller) => controller.text.trim().toLowerCase())
        .join(' ');

    if (await authModel.validateMnemonic(mnemonic)) {
      await authModel.setMnemonic(mnemonic);
      ref.read(settingsProvider.notifier).setBackup(true);
      context.push('/set_pin');
    } else {
      FocusScope.of(context).unfocus();
      showMessageSnackBar(
        message: 'Invalid mnemonic'.i18n,
        error: true,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordsState = ref.watch(wordsProvider);

    if (wordsState.loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (wordsState.words == null || wordsState.words!.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Error: ${wordsState.err}')),
      );
    }

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text('Recover Account'.i18n,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold)),
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          body: SafeArea(
            bottom: true,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        _buildWordCountToggle(),
                        SizedBox(height: 16.h),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            "Enter your key. Carefully enter your seed words below to recover your Bitcoin account."
                                .i18n,
                            textAlign: TextAlign.center,
                            style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        _buildMnemonicGrid(),
                      ],
                    ),
                  ),
                ),
                if (isKeyboardVisible) _buildSuggestionList(),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                  child: CustomButton(
                    text: 'Recover Account'.i18n,
                    onPressed: () => _recoverAccount(context),
                    primaryColor: Colors.green.withOpacity(0.8),
                    secondaryColor: Colors.green.withOpacity(0.6),
                    textColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // FIX: This widget is now styled like the _buildSectionPicker from Analytics
  Widget _buildWordCountToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleButton("12 words".i18n, 12),
          _buildToggleButton("24 words".i18n, 24),
        ],
      ),
    );
  }

  // FIX: This button is styled to work inside the new toggle design
  Widget _buildToggleButton(String text, int wordCount) {
    bool isSelected = _totalWords == wordCount;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _totalWords = wordCount),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black.withOpacity(0.5) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade400,
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMnemonicGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.8,
      ),
      itemCount: _totalWords,
      itemBuilder: (context, index) {
        return _buildWordInputField(index);
      },
    );
  }

  Widget _buildWordInputField(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 8.w,
                top: 6.h,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
                textAlign: TextAlign.center,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionList() {
    if (_filteredWords.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: 60.h,
          color: Colors.black.withOpacity(0.5),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: _filteredWords.length,
            itemBuilder: (context, index) {
              final word = _filteredWords[index];
              return GestureDetector(
                onTap: () => _onWordSelected(word),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      word,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}