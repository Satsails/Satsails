import 'package:flutter/material.dart';
import 'package:satsails_wallet/models/mnemonic_model.dart';

class RecoverWallet extends StatefulWidget {
  const RecoverWallet({Key? key}) : super(key: key);

  @override
  _RecoverWalletState createState() => _RecoverWalletState();
}

class _RecoverWalletState extends State<RecoverWallet> {
  final List<int> _wordCounts = [12, 24];
  int _selectedWordCount = 12;
  List<String> _words = List.generate(12, (index) => '');

  Future<void> _showWordDialog(int index) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Enter Word ${index + 1}',
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                setState(() {
                  _words[index] = controller.text;
                });
                Navigator.of(context).pop();

                // Check if the final word has been inserted
                if (index == _selectedWordCount - 1) {
                  final mnemonic = _words.join(' ');
                  final model = MnemonicModel(mnemonic: mnemonic);
                  if (model.validateMnemonic()) {
                    model.setMnemonic();
                    Navigator.pushNamed(context, '/set_pin');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid mnemonic'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DropdownButton<int>(
              value: _selectedWordCount,
              items: _wordCounts.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value words'),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedWordCount = newValue!;
                  _words = List.generate(_selectedWordCount, (index) => '');
                });
              },
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Adjust the number of items per row
                ),
                itemCount: _selectedWordCount,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showWordDialog(index),
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(5.0), // Reduce the margin
                      padding: const EdgeInsets.all(5.0), // Reduce the padding
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        _words[index].isEmpty ? 'Word ${index + 1}' : _words[index],
                        style: TextStyle(
                          color: _words[index].isEmpty ? Colors.grey : Colors.black,
                          fontSize: 13.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}