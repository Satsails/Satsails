import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:satsails_wallet/helpers/asset_mapper.dart';

Widget buildMiddleSection(List transactions, BuildContext context) {
  return Expanded(
    child: SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: SizedBox(
          width: double.infinity,
          child: _buildTransactionList(transactions, context), // Use _buildTransactionList directly
        ),
      ),
    ),
  );
}

Widget _buildTransactionList(List transactions, BuildContext context) {
  return ListView.builder(
    shrinkWrap: true,
    itemCount: transactions.length,
    itemBuilder: (BuildContext context, int index) {
      return _buildTransactionItem(transactions[index], context);
    },
  );
}

Widget _buildTransactionItem(Map<Object?, Object?> transaction, BuildContext context) {
  Object? satoshiObject = transaction['satoshi'];
  List<Widget> simpleTransactions = [];
  List<Widget> multipleAssetTransactions = [];

  if (satoshiObject is Map) {
    if (satoshiObject.length == 1) {
      satoshiObject.forEach((key, value) {
        simpleTransactions.add(
          ListTile(
            leading: Icon(
              value > 0 ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            title:  Text('${value < 0 ? "Sent" : "Received"} ${value / 100000000}', style: TextStyle(color: value < 0 ? Colors.red : null)),
            trailing: Text(AssetMapper().mapAsset(key), style: TextStyle(color: Colors.grey, fontSize: 20)),
          ),
        );
      });
    } else {
      satoshiObject.forEach((key, value) {
        multipleAssetTransactions.add(
          ListTile(
            leading: Icon(
              value > 0 ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            title: Text('${value < 0 ? "Sent" : "Received"} ${value / 100000000}', style: TextStyle(color: value < 0 ? Colors.red : null)),
            trailing: Text(AssetMapper().mapAsset(key), style: TextStyle(color: Colors.grey, fontSize: 20)),
          ),
        );
      });
    }
  }

  return Column(
    children: [
      ListTile(
        title: GestureDetector(
          onTap: () {
            _copyToClipboard(transaction['txhash']);
            _showSnackBar('Transaction ID copied to clipboard', context);
          },
          child: Text('Transaction ID: ${transaction['txhash']}'),
        ),
        subtitle: Text('Status: ${transaction['confirmation_status']}'),
      ),
      ...simpleTransactions,
      ...multipleAssetTransactions,
    ],
  );
}

void _showSnackBar(String message, BuildContext context) {
  // Use the ScaffoldMessenger to show a SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
}

void _copyToClipboard(Object? value) {
  if (value != null) {
    Clipboard.setData(ClipboardData(text: value.toString()));
  }
}