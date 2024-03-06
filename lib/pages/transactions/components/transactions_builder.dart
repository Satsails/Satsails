import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:satsails_wallet/helpers/asset_mapper.dart';

Widget buildTransactions(List transactions, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
    ),
    child: SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - kToolbarHeight,
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildTransactionItem(transactions[index], context);
        },
      ),
    ),
  );
}

Widget _buildTransactionItem(Map<Object?, Object?> transaction, BuildContext context) {
  Object? satoshiObject = transaction['satoshi'];
  // fix text leaving the screen
  return Column(
    children: [
      ListTile(
        title: Text('Type: ${transaction['type']}', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: GestureDetector(
          onTap: () {
            _copyToClipboard(transaction['txhash']);
            _showSnackBar('Transaction ID copied to clipboard', context);
          },
          child: Text('Transaction ID: ${transaction['txhash']}'),
        ),
        trailing: Text('Status: ${transaction['confirmation_status']}'),
      ),
      if (satoshiObject is Map)
        ...satoshiObject.entries.map((entry) {
          var key = entry.key;
          var value = entry.value;

          Icon leadingIcon;
          if (transaction['type'] == 'redeposit') {
            leadingIcon = Icon(Icons.arrow_forward); // Replace with the actual icon for redeposit
          } else {
            leadingIcon = Icon(
              value > 0 ? Icons.arrow_downward : Icons.arrow_upward,
            );
          }

          return ListTile(
            leading: leadingIcon,
            title: Text(
              '${transaction['type'] == 'redeposit' ? "Redeposited" : value < 0 ? "Sent" : "Received"} ${value.abs() / 100000000}',
              style: TextStyle(color: transaction['type'] == 'redeposit' ? Colors.blue : value < 0 ? Colors.red : Colors.green),
            ),
            trailing: Text(
              AssetMapper().mapAsset(key),
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
          );
        }),
    ],
  );
}

void _showSnackBar(String message, BuildContext context) {
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
