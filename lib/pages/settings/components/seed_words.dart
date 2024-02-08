import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SeedWords extends StatefulWidget {
  const SeedWords({Key? key}) : super(key: key);

  @override
  _SeedWordsState createState() => _SeedWordsState();
}

class _SeedWordsState extends State<SeedWords> {
  String mnemonic = '';
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    initMnemonic();
  }

  Future<void> initMnemonic() async {
    String? storedMnemonic = await _storage.read(key: 'mnemonic');
    if (storedMnemonic != null) {
      setState(() {
        mnemonic = storedMnemonic;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Split the mnemonic into a list of words
    List<String> words = mnemonic.split(' ');

    return Scaffold(
      appBar: AppBar(
        title: Text('Seed Words'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: List.generate(words.length, (index) {
            return Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Text('${index + 1}. ${words[index]}'),
            );
          }),
        ),
      ),
    );
  }
}