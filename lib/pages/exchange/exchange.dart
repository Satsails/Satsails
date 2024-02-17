import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../helpers/wallet_strategy.dart';
import '../../../providers/balance_provider.dart';
import 'package:provider/provider.dart';
import './components/peg_status.dart';

// toggle visibility of sheet
// add min values for each asset
// implement transactions saving
// implement reopening draggable sheet
// implement swapping assets

class Exchange extends StatefulWidget {
  @override
  _ExchangeState createState() => _ExchangeState();
}

class _ExchangeState extends State<Exchange> {
  TextEditingController amountController = TextEditingController();
  String receivingAsset = 'BTC';
  String sendingAsset = 'L-BTC';
  bool sendBitcoins = true;
  bool pegIn = true;
  double sendAmount = 0;
  double maxAmount = 0;
  double minAmount = 0;
  double receivingAmount = 0;
  bool isSheetVisible = false;
  late Map<String, dynamic> balance = {};
  late WalletStrategy walletStrategy;

  List<String> sendingAssetList = ['BTC', 'L-BTC', 'USDT'];
  List<String> receivingAssetList = ['BTC', 'L-BTC', 'USDT'];

  @override
  void initState() {
    super.initState();
    walletStrategy = WalletStrategy();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<Stream<dynamic>> streamAndPayPegStatus() async {
    int sendAmountInSatoshi = (sendAmount * 100000000).toInt();
    Map<String, dynamic> data = await walletStrategy.checkSideswapType(sendingAsset, receivingAsset, pegIn, sendAmountInSatoshi);
    Stream<dynamic> pegStatus = walletStrategy.checkPegStatus(data["order_id"], pegIn);
    return pegStatus;
  }

  void checkMaxAmount(String asset, BuildContext context) {
    balance = Provider.of<BalanceProvider>(context).balance;
    double calculatedAmount = 0;

    if (asset == 'BTC') {
      calculatedAmount = balance['btc'] ?? 0;
    } else if (asset == 'L-BTC') {
      calculatedAmount = balance['l-btc'] ?? 0;
    } else if (asset == 'USDT') {
      calculatedAmount = balance['usdOnly'] ?? 0;
    }

    setState(() {
      maxAmount = calculatedAmount;
    });
  }

  void checkMinAmount(String asset, BuildContext context) {
    double calculatedAmount = 0;

    if (asset == 'BTC') {
      calculatedAmount = 0.0001;
    } else if (asset == 'L-BTC') {
      calculatedAmount = 0.001;
    }

    setState(() {
      minAmount = calculatedAmount;
    });
  }

  void checkAmountToReceive(String sendingAsset, String receivingAsset) {
    double calculatedAmount = 0;

    if (sendingAsset == 'BTC' && receivingAsset == 'L-BTC' || sendingAsset == 'L-BTC' && receivingAsset == 'BTC') {
      calculatedAmount = sendAmount * 0.99;
    } else if (sendingAsset == 'USDT') {
      calculatedAmount = balance['usdOnly'] ?? 0;
    }

    setState(() {
      receivingAmount = calculatedAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    checkMaxAmount(sendingAsset, context);
    checkMinAmount(sendingAsset, context);
    checkAmountToReceive(sendingAsset, receivingAsset);
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: amountController,
                            decoration: const InputDecoration(
                              hintText: "0",
                              border: InputBorder.none,
                              alignLabelWithHint: true,
                            ),
                            textAlign: TextAlign.right,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              double enteredAmount = double.tryParse(value) ?? 0;

                              if (enteredAmount > maxAmount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Entered amount cannot be greater than $maxAmount."),
                                  ),
                                );
                                amountController.text = maxAmount.toString();
                                setState(() {
                                  sendAmount = maxAmount;
                                });
                              } else {
                                setState(() {
                                  sendAmount = enteredAmount;
                                });
                              }
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Max: $maxAmount', // Display maxAmount
                              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                            ),
                          ),
                        ],
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
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Amount to receive without fees: $receivingAmount',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Add logic when the second ListTile is tapped
                },
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              // onPressed: sendAmount == 0 || sendAmount < minAmount
                onPressed: sendAmount == 0
                  ? null
                  : () {
                if (sendingAsset == receivingAsset) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("You can't convert the same asset."),
                    ),
                  );
                } else if (sendingAsset == "BTC" && receivingAsset == "USDT" ||
                    sendingAsset == "USDT" && receivingAsset == "BTC") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "You can't convert BTC to USDT directly. Please convert first to L-BTC. Feature is still in beta"),
                    ),
                  );
                } else {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return FutureBuilder<Stream<dynamic>>(
                        future: streamAndPayPegStatus(),
                        builder: (BuildContext context, AsyncSnapshot<Stream<dynamic>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return PegStatusSheet(
                              pegStatus: snapshot.data!,
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
              child: const Text('Convert'),
            ),
            Text(
              'Min to send: $minAmount', // Display minAmount
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}