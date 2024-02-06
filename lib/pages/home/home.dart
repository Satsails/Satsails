import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'dart:ui';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isSwitched = false;

  @override
  void initState() {
    super.initState();
    // checkForWallets();
  }

  void checkForWallets() async {
    final _storage = const FlutterSecureStorage();
    String mnemonic = await _storage.read(key: 'mnemonic') ?? '';
    // Map<String, dynamic> walletInfo = await greenwallet.Channel('ios_wallet').fetchAllSubAccounts(mnemonic: mnemonic, connectionType: 'electrum-liquid');
  }

  // Inside the build method of your _HomeState class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimateGradient(
            primaryBegin: Alignment.topLeft,
            primaryEnd: Alignment.bottomLeft,
            secondaryBegin: Alignment.bottomLeft,
            secondaryEnd: Alignment.topRight,
            primaryColors: const [
              Colors.blueAccent,
              Colors.blueAccent,
              Colors.white,
            ],
            secondaryColors: const [
              Colors.white,
              Colors.blueAccent,
              Colors.blueAccent,
            ],
            duration: const Duration(seconds: 10),
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + kToolbarHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        const Text(
                          '1 BTC',
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '40000 USD',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            // Add logic to navigate or perform an action when the button is pressed
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.white.withOpacity(0.8), // Adjust opacity as needed
                            ),
                            foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.black,
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide(color: Colors.grey[800]!),
                              ),
                            ),
                            elevation: MaterialStateProperty.all<double>(0.0),
                          ),
                          child: const Text('View Accounts'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircularButton(Icons.add, 'Add Money', () {}),
                      _buildCircularButton(
                          Icons.swap_horizontal_circle, 'Exchange', () {}),
                      _buildCircularButton(Icons.payment, 'Pay', () {}),
                      _buildCircularButton(
                          Icons.arrow_downward_sharp, 'Receive', () {}),
                    ],
                  ),
                ),
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    elevation: 8.0,
                    color: Colors.white.withOpacity(0.9), // Adjust opacity as needed
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: SizedBox(
                  height: 50,
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Search",
                      fillColor: Colors.white.withOpacity(0.8), // Adjust opacity as needed
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black), // Adjust opacity as needed
                  onPressed: () {},
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(
                        Icons.candlestick_chart_rounded, color: Colors.black), // Adjust opacity as needed
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                        Icons.account_balance, color: Colors.black), // Adjust opacity as needed
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildCircularButton(IconData icon, String subtitle, VoidCallback onPressed) {
  return Column(
    children: [
      InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withOpacity(0.7)), // Adjust opacity as needed
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.8), // Adjust opacity as needed
            radius: 25,
            child: Icon(
              icon,
              color: Colors.black.withOpacity(0.7), // Adjust opacity as needed
              size: 25,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 10),
      ),
    ],
  );
}
