import 'package:flutter/material.dart';
import 'package:satsails/models/mnemonic_model.dart';

class RecoverWallet extends StatefulWidget {
  const RecoverWallet({Key? key}) : super(key: key);

  @override
  _RecoverWalletState createState() => _RecoverWalletState();
}

class _RecoverWalletState extends State<RecoverWallet> {
  final List<int> _wordCounts = [12, 24];
  int _selectedWordCount = 12;
  List<String> _words = List.generate(12, (index) => '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recover Wallet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: _selectedWordCount,
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
                        setState(() {
                          _words[index] = newValue;
                        });
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
                        color: _words[index].isEmpty ? Colors.grey : Colors.black,
                        fontSize: 13.0,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // final mnemonic = _words.join(' ');
                  final mnemonic = "near angle old frequent only pair banana giggle armed penalty torch boat";
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