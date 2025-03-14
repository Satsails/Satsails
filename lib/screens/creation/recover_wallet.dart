import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/words_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';

class RecoverWallet extends ConsumerStatefulWidget {
  const RecoverWallet({super.key});

  @override
  _RecoverWalletState createState() => _RecoverWalletState();
}

class _RecoverWalletState extends ConsumerState<RecoverWallet> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(24, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(24, (_) => FocusNode());
  List<String> _filteredWords = [];
  int _totalWords = 12;
  bool _keyboardVisible = false;
  int _selectedWordIndex = -1;
  late AnimationController _suggestionController;
  late Animation<double> _suggestionFadeAnimation;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_onTextChanged);
    }

    _suggestionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _suggestionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _suggestionController, curve: Curves.easeInOut),
    );

    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        _keyboardVisible = visible;
      });
      if (visible && _filteredWords.isNotEmpty) {
        _suggestionController.forward();
      } else {
        _suggestionController.reverse();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_onTextChanged);
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _suggestionController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final currentIndex = _focusNodes.indexWhere((node) => node.hasFocus);
    if (currentIndex == -1) return;
    final query = _controllers[currentIndex].text;
    final wordsState = ref.read(wordsProvider);

    setState(() {
      _selectedWordIndex = currentIndex;
    });

    if (query.isEmpty) {
      setState(() {
        _filteredWords = [];
      });
      _suggestionController.reverse();
      return;
    }

    final filtered = wordsState.words!
        .where((word) => word.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredWords = filtered.length > 3 ? filtered.sublist(0, 3) : filtered;
    });
    if (_keyboardVisible && _filteredWords.isNotEmpty) {
      _suggestionController.forward();
    }
  }

  void _onWordSelected(String word) {
    final currentIndex = _focusNodes.indexWhere((node) => node.hasFocus);
    if (currentIndex == -1) return;
    _controllers[currentIndex].text = word;
    if (currentIndex < _totalWords - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[currentIndex + 1]);
    } else {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      _filteredWords = [];
    });
    _suggestionController.reverse();
  }

  Future<void> _recoverAccount(BuildContext context) async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = _controllers
        .take(_totalWords)
        .map((controller) => controller.text.trim())
        .join(' ');

    if (await authModel.validateMnemonic(mnemonic)) {
      await authModel.setMnemonic(mnemonic);
      await ref.read(settingsProvider.notifier).setBackup(true);
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

  Widget _buildSuggestionList(BuildContext context) {
    if (_filteredWords.isEmpty || !_keyboardVisible) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0), // Small gap above the keyboard
        child: FadeTransition(
          opacity: _suggestionFadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(
              maxHeight: 150, // Limits height to keep it compact
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredWords.length,
              itemBuilder: (context, index) {
                final word = _filteredWords[index];
                return Card(
                  color: Colors.grey[850],
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    title: Text(
                      word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      _onWordSelected(word);
                      setState(() {
                        _filteredWords = [];
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordsState = ref.watch(wordsProvider);

    if (wordsState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wordsState.words == null || wordsState.words!.isEmpty) {
      return Center(child: Text('Error: ${wordsState.err}'));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Recover Account'.i18n, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _totalWords = 12;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _totalWords == 12 ? Color(0xFF2B2B2B) : Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text("12 words".i18n, style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _totalWords = 24;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: _totalWords == 24 ? Color(0xFF2B2B2B) : Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text("24 words".i18n, style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "Enter your key. Carefully enter your seed words below to recover your Bitcoin account.".i18n,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                    bottom: screenHeight * 0.02,
                  ),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(
                        _totalWords,
                            (index) => SizedBox(
                          width: screenWidth * 0.28,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            style: const TextStyle(color: Colors.white),
                            autocorrect: false,
                            enableSuggestions: false,
                            keyboardType: TextInputType.visiblePassword,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFF404040),
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                              labelText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Color(0xFF6D6D6D), width: 4.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(color: Colors.orangeAccent, width: 4.0),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedWordIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15, vertical: screenHeight * 0.02),
                child: CustomButton(
                  text: 'Recover Account'.i18n,
                  onPressed: () => _recoverAccount(context),
                  primaryColor: Colors.green,
                  secondaryColor: Colors.green,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
          _buildSuggestionList(context), // Positioned right above the keyboard
        ],
      ),
    );
  }
}