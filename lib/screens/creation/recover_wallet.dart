import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/providers/auth_provider.dart';

class RecoverWalletState extends StateNotifier<RecoverWalletData> {
  RecoverWalletState() : super(RecoverWalletData());

  void setSelectedWordCount(int count) {
    state = RecoverWalletData(wordCount: count, words: List.generate(count, (index) => ''));
  }

  void setWord(int index, String word) {
    state = RecoverWalletData(
      wordCount: state.wordCount,
      words: List<String>.from(state.words)..[index] = word,
    );
  }
}

class RecoverWalletData {
  final int wordCount;
  final List<String> words;

  RecoverWalletData({this.wordCount = 12, this.words = const ['','','','','','','','','','','','']});
}

final recoverWalletProvider = StateNotifierProvider<RecoverWalletState, RecoverWalletData>((ref) {
  return RecoverWalletState();
});


class RecoverWallet extends ConsumerWidget {
  const RecoverWallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<int> _wordCounts = [12, 24];
    final data = ref.watch(recoverWalletProvider);
    final authModel = ref.read(authModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recover Wallet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<int>(
                value: data.wordCount,
                items: _wordCounts.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value words'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  ref.read(recoverWalletProvider.notifier).setSelectedWordCount(newValue!);
                },
              ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: data.wordCount,
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(5.0),
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      onChanged: (newValue) {
                        ref.read(recoverWalletProvider.notifier).setWord(index, newValue);
                      },
                      decoration: InputDecoration(
                        hintText: 'Word ${index + 1}',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        color: ref.read(recoverWalletProvider).words[index].isEmpty
                            ? Colors.grey
                            : Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  // final mnemonic = data.words.join(' ');
                  final mnemonic = "near angle old frequent only pair banana giggle armed penalty torch boat";
                  if (await authModel.validateMnemonic(mnemonic)) {
                    await authModel.setMnemonic(mnemonic);
                    Navigator.pushNamed(context, '/set_pin');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid mnemonic'),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.cyan[400]!,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  minimumSize:
                  MaterialStateProperty.all<Size>(const Size(300.0, 60.0)),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}