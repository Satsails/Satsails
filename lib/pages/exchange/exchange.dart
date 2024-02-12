import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/sideswap/sideswap_stream_prices.dart';

class Exchange extends StatefulWidget {
  @override
  _ExchangeState createState() => _ExchangeState();
}

class _ExchangeState extends State<Exchange> {
  late SideswapStreamPrices _webSocketService;

  String receivingAsset = 'BTC';
  String sendingAsset = 'L-BTC';
  bool sendBitcoins = true;
  int sendAmount = 100;

  List<String> sendingAssetList = ['BTC', 'L-BTC', 'USDT'];
  List<String> receivingAssetList = ['BTC', 'L-BTC', 'USDT'];

  @override
  void initState() {
    _webSocketService = SideswapStreamPrices();
    _webSocketService.connect(
      asset: receivingAsset,
      sendBitcoins: sendBitcoins,
      sendAmount: sendAmount,
    );
    super.initState();
  }

  @override
  void dispose() {
    _webSocketService.close();
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
                        decoration: InputDecoration(
                          hintText: "-0", // Hint text with "-0"
                          border: InputBorder.none, // Remove underline
                          alignLabelWithHint: true, // Align the text to the right
                        ),
                        textAlign: TextAlign.right, // Align the entered text to the right
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  // Add logic to choose the asset to convert
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
                  // Add logic to choose the asset to convert
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (sendingAsset == receivingAsset) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You can't convert anything."),
                    ),
                  );
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
