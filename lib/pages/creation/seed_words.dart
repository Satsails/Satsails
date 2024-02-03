import 'package:flutter/material.dart';
import '../../channels/greenwallet.dart' as greenwallet;

class SeedWords extends StatefulWidget {
  const SeedWords({Key? key}) : super(key: key);

  @override
  _SeedWordsState createState() => _SeedWordsState();
}

class _SeedWordsState extends State<SeedWords> {
  String mnemonic = '';

  @override
  void initState() {
    super.initState();
    initMnemonic();
  }

  Future<void> initMnemonic() async {
    mnemonic = await greenwallet.Channel('ios_wallet').getMnemonic();
    setState(() {});
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