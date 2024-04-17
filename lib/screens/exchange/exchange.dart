import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:satsails/helpers/exchange.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/services/sideswap/sideswap_status.dart';
import 'package:satsails/services/sideswap/sideswap_exchange.dart';
import './components/peg_status.dart';
import './components/exchange_status.dart';

class Exchange extends StatefulWidget {
  @override
  _ExchangeState createState() => _ExchangeState();
}

class _ExchangeState extends State<Exchange> {
  // implement logic with transaction fees
  late SideswapServerStatus serverStatus;
  late SideswapStreamPrices streamPrices;
  TextEditingController amountController = TextEditingController();
  String receivingAsset = 'L-BTC';
  String sendingAsset = 'BTC';
  String errorMessage = '';
  bool sendBitcoins = true;
  bool pegIn = true;
  bool exchange = false;
  double sendAmount = 0;
  double price = 0;
  double maxAmount = 0;
  double minAmount = 0;
  double receivingAmount = 0;
  double serviceFee = 0;
  late Map<String, dynamic> balance;
  late WalletStrategy walletStrategy;

  List<String> sendingAssetList = ['BTC', 'L-BTC', 'USDT'];
  List<String> receivingAssetList = ['L-BTC'];

  @override
  void initState() {
    super.initState();
    walletStrategy = WalletStrategy();
    serverStatus = SideswapServerStatus();
    streamPrices = SideswapStreamPrices();
    runExchangeLogic(sendingAsset, context);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<Stream<dynamic>> streamAndPayPegStatus() async {
    int sendAmountInSatoshi = (sendAmount * 100000000).toInt();
    Map<String, dynamic> data =
    await walletStrategy.checkSideswapType(sendingAsset, receivingAsset, pegIn, sendAmountInSatoshi);
    Stream<dynamic> pegStatus = walletStrategy.checkPegStatus(data["order_id"], pegIn);
    return pegStatus;
  }
  //
  // Future<Stream<dynamic>> streamAndExchange() async {
  //   int sendAmountInSatoshi = (sendAmount * 100000000).toInt();
  //   int receivingAmountInSatoshi = (receivingAmount * 100000000).toInt();
  //   Stream<dynamic> exchange  = walletStrategy.startSwap(sendBitcoins, sendAmountInSatoshi, receivingAmountInSatoshi, AssetMapper.reverseMapTicker(sendingAsset), price);
  //   return exchange;
  // }
  //
  void checkPegMaxAmount(String asset, BuildContext context, dynamic data) {
    double calculatedAmount = 0;

    if (asset == 'BTC') {
      calculatedAmount = balance['btc'] ?? 0;
    } else if (asset == 'L-BTC') {
      calculatedAmount = balance['l-btc'] ?? 0;
    }

    maxAmount = calculatedAmount;
  }

  void checkPegMinAmount(String asset, BuildContext context, dynamic data) {
    try {
      double calculatedAmount = 0;

      if (asset == 'BTC') {
        calculatedAmount = data["result"]["min_peg_in_amount"] / 100000000 + balance['highestBitcoinFee'];
        setState(() {
          pegIn = true;
        });
      } else if (asset == 'L-BTC') {
        calculatedAmount = data["result"]["min_peg_out_amount"] / 100000000 + balance['highestLiquidFee'];
        setState(() {
          pegIn = false;
        });
      }


      minAmount = calculatedAmount;

      if (sendAmount < minAmount) {
        setState(() {
          errorMessage = 'Amount to send cannot be less than $minAmount';
        });
      } else {
        setState(() {
          errorMessage = '';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = '';
      });
    }
  }


  void checkExchangeMaxAmount(String asset, BuildContext context) {
    double calculatedAmount = 0;

    if (asset == 'L-BTC') {
      calculatedAmount = balance['l-btc'] ?? 0;
    } else if (asset == 'USDT') {
      calculatedAmount = balance['usdOnly'] ?? 0;
    }

    maxAmount = calculatedAmount;
  }

  void runExchangeLogic(String asset, BuildContext context) {
    try {
      if (asset == 'BTC' && receivingAsset == 'L-BTC' || asset == 'L-BTC' && receivingAsset == 'BTC') {
        setState(() {
          errorMessage = '';
        });
        serverStatus.connect();
        serverStatus.messageStream.listen((dynamic data) {
          checkPegMaxAmount(asset, context, data);
          checkPegMinAmount(asset, context, data);
          checkPegAmountToReceive(sendingAsset, receivingAsset, data);
        });
      } else if (asset == 'USDT' || receivingAsset == 'L-BTC' || asset == 'L-BTC' || receivingAsset == 'USDT') {
        exchange = true;
        int sendAmountInSatoshi = (sendAmount * 100000000).toInt();
        String assetId = '';
        // if (sendBitcoins) {
        //   assetId = AssetMapper.reverseMapTicker(receivingAsset);
        // } else {
        //   assetId = AssetMapper.reverseMapTicker(sendingAsset);
        // }
        checkExchangeMaxAmount(asset, context);
        if (sendAmountInSatoshi > 0) {
          streamPrices.connect(asset: assetId, sendBitcoins: sendBitcoins, sendAmount: sendAmountInSatoshi);
          streamPrices.messageStream.listen((dynamic data) {
            Map<String, dynamic> parsedData = {};
            if (data["method"] == "update_price_stream") {
              parsedData = data["params"];
            } else {
              parsedData = data["result"];
            }
            setState(() {
              errorMessage = parsedData["error_msg"] ?? '';
            });
            if (errorMessage.isNotEmpty) {
              return; // Return early on error
            }
            receivingAmount = parsedData["recv_amount"] / 100000000;
            serviceFee = parsedData["fixed_fee"] / 100000000;
            price = parsedData["price"];
          });
        }
        receivingAmount = 0;
        serviceFee = 0;
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
      });
    }
  }


  void checkPegAmountToReceive(String sendingAsset, String receivingAsset, dynamic data) {
    double calculatedAmount = 0;

    if (sendingAsset == 'BTC' && receivingAsset == 'L-BTC' || sendingAsset == 'L-BTC' && receivingAsset == 'BTC') {
      if (pegIn) {
        calculatedAmount = sendAmount * (1 - data["result"]["server_fee_percent_peg_in"]);
        serviceFee = data["result"]["server_fee_percent_peg_in"];
      } else {
      calculatedAmount = sendAmount * (1 - data["result"]["server_fee_percent_peg_out"]);
      serviceFee = data["result"]["server_fee_percent_peg_out"];
      }
    }

    receivingAmount = calculatedAmount;
  }

  @override
  Widget build(BuildContext context) {
    // implement balance provider
    balance = 0.0 as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Exchange'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            buildSendingAssetCard(context),
            const Icon(
              Icons.arrow_downward,
              size: 40.0,
            ),
            buildReceivingAssetCard(),
            const SizedBox(height: 20.0),
            buildConvertButton(),
            const SizedBox(height: 20.0),
            if (exchange == false) buildInfoText('Min to send: $minAmount'),
            buildInfoText(errorMessage),
            if (exchange == false) buildInfoText('Service fee: $serviceFee' + '%'),
            if (exchange) buildInfoText('Service fee: $serviceFee'),
          ],
        ),
      ),
    );
  }

  Card buildSendingAssetCard(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            buildSendingAssetDropdown(),
            const SizedBox(width: 8.0),
            Expanded(
              child: buildSendingAssetTextField(),
            ),
          ],
        ),
      ),
    );
  }

  DropdownButton<String> buildSendingAssetDropdown() {
    return DropdownButton<String>(
      value: sendingAsset,
      onChanged: (value) {
        setState(() {
          sendingAsset = value!;
          updateReceivingAssetList();
          runExchangeLogic(sendingAsset, context);
        });
      },
      items: sendingAssetList.map<DropdownMenuItem<String>>((String asset) {
        return DropdownMenuItem<String>(
          value: asset,
          child: Text(asset),
        );
      }).toList(),
    );
  }

  void updateReceivingAssetList() {
    if (sendingAsset == 'BTC') {
      setState(() {
        receivingAssetList = ['L-BTC'];
        receivingAsset = 'L-BTC';
      });
    } else if (sendingAsset == 'USDT') {
      setState(() {
        receivingAssetList = ['L-BTC'];
        receivingAsset = 'L-BTC';
        sendBitcoins = false;
      });
    } else if (sendingAsset == 'L-BTC') {
      setState(() {
        receivingAssetList = ['BTC', 'USDT'];
        receivingAsset = 'BTC';
      });
    }
    else {
      setState(() {
        receivingAssetList = ['BTC', 'L-BTC', 'USDT'];
        sendBitcoins = true;
      });
    }
  }



  Column buildSendingAssetTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAmountTextField(),
        buildMaxAmountText(),
      ],
    );
  }

  TextField buildAmountTextField() {
    return TextField(
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
            runExchangeLogic(sendingAsset, context);
          });
        } else {
          setState(() {
            sendAmount = enteredAmount;
            runExchangeLogic(sendingAsset, context);
          });
        }
      },
    );
  }

  Align buildMaxAmountText() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        'Max: $maxAmount',
        style: const TextStyle(fontSize: 12.0, color: Colors.grey),
      ),
    );
  }

  Card buildReceivingAssetCard() {
    return Card(
      child: ListTile(
        subtitle: Row(
          children: [
            const SizedBox(width: 8.0),
            buildReceivingAssetDropdown(),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                'Amount to receive: $receivingAmount',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownButton<String> buildReceivingAssetDropdown() {
    return DropdownButton<String>(
      value: receivingAsset,
      onChanged: (value) {
        setState(() {
          receivingAsset = value!;
        });
        runExchangeLogic(sendingAsset, context);
      },
      items: receivingAssetList.map<DropdownMenuItem<String>>((String asset) {
        return DropdownMenuItem<String>(
          value: asset,
          child: Text(asset),
        );
      }).toList(),
    );
  }

  ElevatedButton buildConvertButton() {
    return ElevatedButton(
      onPressed: sendAmount == 0 || errorMessage.isNotEmpty
          ? null
          : () async {
        if (!exchange) {
          try {
            Stream<dynamic> pegStatusStream =
            await streamAndPayPegStatus();

            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return PegStatusSheet(
                  pegStatus: pegStatusStream,
                );
              },
            );
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
              ),
            );
          }
        } else {
          try {
            // Stream<dynamic> exchangeStream = await streamAndExchange();

            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return ExchangeStatus(
                  exchangeStatus: Stream.empty(),
                );
              },
            );
          } catch (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
              ),
            );
          }
        }
      },
      child: const Text('Convert'),
    );
  }


  Text buildInfoText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12.0, color: Colors.grey),
    );
  }
}
