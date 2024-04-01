import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';

class Accounts extends ConsumerWidget {
  const Accounts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    final balance = ref.watch(balanceNotifierProvider);
    final bitcoin = ref.watch(bitcoinNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Account Management'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: screenWidth * 0.02),
            const Text(
              'Savings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenWidth * 0.02),
            Card(
              color: Colors.orangeAccent,
              elevation: 0,
              child: Column(
                children: [
                  _buildListTile('Bitcoin', balance.btcBalance.toString(),const Icon(LineAwesome.bitcoin, color: Colors.white,), context, bitcoin),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            const Text(
              'Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenWidth * 0.02),
            Card(
              color: Colors.blueAccent,
              child: Column(
                children: [
                  _buildListTile('Liquid', balance.liquidBalance.toString(), const Icon(LineAwesome.bitcoin, color: Colors.white), context, bitcoin),
                  _buildDivider(),
                  _buildListTile('Lightning', '', const Icon(LineAwesome.bolt_solid, color: Colors.white), context, bitcoin),
                  _buildDivider(),
                  _buildListTile('Real', balance.brlBalance.toString(), Flag(Flags.brazil), context, bitcoin.getAddress()),
                  _buildDivider(),
                  _buildListTile('Dollar', balance.usdBalance.toString(), Flag(Flags.united_states_of_america), context, bitcoin),
                  _buildDivider(),
                  _buildListTile('Euro', balance.eurBalance.toString(), Flag(Flags.european_union), context, bitcoin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String trailing, icon, BuildContext context, bitcoin) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.white),
      child: ExpansionTile(
        leading: icon,
        title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
        trailing: Text(trailing, style: const TextStyle(fontSize: 16, color: Colors.white)),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  _receivePayment(context, bitcoin);
                },
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  // Add your receive button handler here
                },
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _receivePayment(BuildContext context, dynamic bitcoin) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<dynamic>(
          future: bitcoin.getAddress().then((value) => value.address.toString()),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final String address = snapshot.data.toString();
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Receive',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        buildQrCode(address),
                        const SizedBox(height: 20),
                        buildAddressText(address, context),
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              );
            } else {
              return const Center(child: Text('No data'));
            }
          },
        );
      },
    );
  }

  Widget buildQrCode(String address) {
    return Card(
      elevation: 5,
      child: QrImageView(
        backgroundColor: Colors.white,
        data: address,
        version: QrVersions.auto,
        size: 300.0,
      ),
    );
  }

  Widget buildAddressText(String? address, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (address != null) {
          Clipboard.setData(ClipboardData(text: address));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Address copied to clipboard: $address'),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.blue, width: 1.0),
        ),
        child: Text(
          address ?? '',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }
}
