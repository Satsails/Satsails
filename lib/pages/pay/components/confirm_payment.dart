import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import '../../../providers/balance_provider.dart';
import '../../../helpers/networks.dart';
import '../../../helpers/asset_mapper.dart';

class ConfirmPayment extends StatefulWidget {
  final String address;
  final bool isLiquid;

  ConfirmPayment({required this.address, required this.isLiquid});

  @override
  State<ConfirmPayment> createState() => _ConfirmPaymentState();
}

class _ConfirmPaymentState extends State<ConfirmPayment> {
  String selectedAsset = 'Bitcoin';
  late Map<String, dynamic> balance;
  double maxAmount = 0;
  TextEditingController amountController = TextEditingController();
  double sendAmount = 0;

  Future<String> confirmAndSendPayment(double amount, String asset, String transactionType) async {
    const storage = FlutterSecureStorage();
    String mnemonic = await storage.read(key: 'mnemonic') ?? "";
    int amountInt = (amount * 100000000).toInt();
    String assetId;
    if (asset== 'Bitcoin') {
      asset = 'L-BTC';
      assetId = AssetMapper().reverseMapTicker(asset);
    }else {
      asset = 'USD';
      assetId = AssetMapper().reverseMapTicker(asset);
    }

    return await greenwallet.Channel('ios_wallet').sendToAddress(
      mnemonic: mnemonic,
      connectionType: transactionType == 'liquid' ? NetworkSecurityCase.liquidSS.network  : NetworkSecurityCase.bitcoinSS.network,
      address: widget.address,
      amount: amountInt,
      assetId: assetId,
    );
  }

  void checkMaxAmount(String asset) async {
    double calculatedAmount = 0;

    if (widget.isLiquid) {
      if (asset == 'Bitcoin') {
        calculatedAmount = balance['l-btc'];
      } else if (asset == 'USD') {
        calculatedAmount = balance['usdOnly'];
      }
    } else {
      calculatedAmount = balance['btc'];
    }

    setState(() {
      maxAmount = calculatedAmount;
    });
  }

  double getHighestFee() {
    if (widget.isLiquid) {
      return selectedAsset == 'Bitcoin' ? balance['highestLiquidFee'] : balance['highestLiquidFeeUsd'];
    } else {
      return balance['highestBitcoinFee'];
    }
  }

  @override
  Widget build(BuildContext context) {
    balance = Provider.of<BalanceProvider>(context).balance;
    checkMaxAmount(selectedAsset);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You are sending a payment to: ',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Text(
              '${widget.address}',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Send:',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  width: 120,
                  child: TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      hintText: "0",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue), // Set the border color
                      ),
                      alignLabelWithHint: true,
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      double enteredAmount = double.tryParse(value) ?? 0;

                      if (enteredAmount > maxAmount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Entered amount cannot be greater than $maxAmount."),
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
                ),
                const SizedBox(width: 20),
                if (widget.isLiquid)
                  DropdownButton<String>(
                    value: selectedAsset,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAsset = newValue!;
                      });
                    },
                    items: <String>['Bitcoin', 'USD']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
              ],
            ),
            Text(
              'Max amount: $maxAmount',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Highest fee: ${getHighestFee()}', // Call the function here
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: (sendAmount > 0 && maxAmount >= getHighestFee() && sendAmount >= getHighestFee())
                  ? () {
                confirmAndSendPayment(
                  sendAmount,
                  selectedAsset,
                  widget.isLiquid ? 'liquid' : 'bitcoin',
                ).then((value) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transaction completed with ID: $value'),
                    ),
                  );
                });
              }
                  : null,
              child: const Text(
                'Confirm',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
