import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/words_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class RecoverWallet extends ConsumerStatefulWidget {
  const RecoverWallet({super.key});

  @override
  _RecoverWalletState createState() => _RecoverWalletState();
}

class _RecoverWalletState extends ConsumerState<RecoverWallet> {
  final List<TextEditingController> _controllers = List.generate(24, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(24, (_) => FocusNode());
  List<String> _filteredWords = [];
  int _totalWords = 12;
  bool _keyboardVisible = false;
  int _selectedWordIndex = -1;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_onTextChanged);
    }

    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        _keyboardVisible = visible;
      });
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
      return;
    }

    final filtered = wordsState.words!
        .where((word) => word.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredWords = filtered.length > 3 ? filtered.sublist(0, 3) : filtered;
    });
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
  }

  Future<void> _recoverAccount(BuildContext context) async {
    final authModel = ref.read(authModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final mnemonic = _controllers
        .take(_totalWords)
        .map((controller) => controller.text.trim())
        .join(' ');

    if (await authModel.validateMnemonic(mnemonic)) {
      await authModel.setMnemonic(mnemonic);
      Navigator.pushNamed(context, '/set_pin');
    } else {
      Fluttertoast.showToast(
        msg: 'Invalid mnemonic',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: screenWidth * 0.04,
      );
    }
  }

  Widget _buildSuggestionList(BuildContext context) {
    if (_filteredWords.isEmpty || !_keyboardVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _filteredWords.map((word) {
          return ListTile(
            title: Text(word),
            onTap: () => _onWordSelected(word),
          );
        }).toList(),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Recover Account'.i18n(ref)),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.transparent,
                ),
                child: DropdownButton<int>(
                  dropdownColor: Colors.white,
                  value: _totalWords,
                  items: [12, 24].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value" + 'words'.i18n(ref)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _totalWords = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                    top: screenHeight * 0.02,
                  ),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _totalWords,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          children: [
                            TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                labelText: 'Word'.i18n(ref) + ' ${index + 1}',
                                labelStyle: TextStyle(
                                  color: _selectedWordIndex == index ? Colors.orangeAccent : Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 4.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.orangeAccent,
                                    width: 4.0,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedWordIndex = index;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.09,
                child: CustomButton(
                  text: 'Recover Account'.i18n(ref),
                  onPressed: () => _recoverAccount(context),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildSuggestionList(context),
          ),
        ],
      ),
    );
  }
}
