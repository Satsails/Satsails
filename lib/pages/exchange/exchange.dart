import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../helpers/wallet_strategy.dart';

class Exchange extends StatefulWidget {
  @override
  _ExchangeState createState() => _ExchangeState();
}

class _ExchangeState extends State<Exchange> {

  String receivingAsset = 'BTC';
  String sendingAsset = 'L-BTC';
  bool sendBitcoins = true;
  bool pegIn = true;
  int sendAmount = 0;

  List<String> sendingAssetList = ['BTC', 'L-BTC', 'USDT'];
  List<String> receivingAssetList = ['BTC', 'L-BTC', 'USDT'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Card(
              child: ListTile(
                title: Row(
                  children: [
                    DropdownButton<String>(
                      value: sendingAsset,
                      onChanged: (value) {
                        setState(() {
                          sendingAsset = value!;
                        });
                      },
                      items: sendingAssetList.map<DropdownMenuItem<String>>((String asset) {
                        return DropdownMenuItem<String>(
                          value: asset,
                          child: Text(asset),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "0",
                          border: InputBorder.none,
                          alignLabelWithHint: true,
                        ),
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            sendAmount = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Add logic when the first ListTile is tapped
                },
              ),
            ),
            const Icon(
              Icons.arrow_downward,
              size: 40.0,
            ),
            Card(
              child: ListTile(
                subtitle: Row(
                  children: [
                    const SizedBox(width: 8.0),
                    DropdownButton<String>(
                      value: receivingAsset,
                      onChanged: (value) {
                        setState(() {
                          receivingAsset = value!;
                        });
                      },
                      items: receivingAssetList.map<DropdownMenuItem<String>>((String asset) {
                        return DropdownMenuItem<String>(
                          value: asset,
                          child: Text(asset),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                onTap: () {
                  // Add logic when the second ListTile is tapped
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (sendingAsset == receivingAsset) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You can't convert the same asset."),
                    ),
                  );
                } else if (sendingAsset == "BTC" && receivingAsset == "USDT" || sendingAsset == "USDT" && receivingAsset == "BTC") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You can't convert BTC to USDT directly. Please convert first to L-BTC. Feature is still in beta"),
                    ),
                  );
                } else {
                  // Add the else block for other conditions if needed
                  WalletStrategy().checkSideswapType(sendingAsset, receivingAsset, pegIn);
                }
              },
              child: const Text('Convert'),
            )
          ],
        ),
      ),
    );
  }
}
