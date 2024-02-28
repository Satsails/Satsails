import 'package:flutter/material.dart';
import 'package:satsails_wallet/helpers/asset_mapper.dart';
import '../../../providers/transactions_provider.dart';

Widget buildMiddleSection(List transactions) {
  return Expanded(
    child: SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: SizedBox(
          width: double.infinity, // Make the container occupy all horizontal space
          child: Column(
            children: [
              _buildTransactionList(transactions),
            ],
          ),
        ),
      ),
    ),
  );
}


Widget _buildTransactionList(List transactions) {
  return Column(
    children: [
      ListView.builder(
        shrinkWrap: true,
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildTransactionItem(transactions[index]);
        },
      ),
    ],
  );
}

Widget _buildTransactionItem(Map<Object?, Object?> transaction) {

  Object? satoshiObject = transaction['satoshi'];
  if (satoshiObject is Map) {
    Future<Map<String, dynamic>> exchangeData = getAllExchanges();
    print(exchangeData);
    List<Widget> listTiles = [];

    satoshiObject.forEach((key, value) {
      listTiles.add(
        ListTile(
          title: Text('Amount: ${value/100000000}'),
          trailing: Text(AssetMapper().mapAsset(key)), // Use key instead of transaction['date']
        ),
      );
    });

    // Return a Column widget containing all ListTiles
    return Column(
      children: listTiles,
    );
  }

  // Return an empty container if satoshiObject is not a Map
  return Container();
}
