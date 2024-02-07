import 'package:flutter/material.dart';

Widget _buildMiddleSection() {
  return Expanded(
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity, // Make the container occupy all horizontal space
            child: Column(
              children: [
                _buildTransactionList(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildTransactionList() {
  return Column(
    children: [
      _buildTransactionItem('Received', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC'),
      _buildTransactionItem('Sent', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC'),
      _buildTransactionItem('Received', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC'),
      _buildTransactionItem('Sent', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC'),
      _buildTransactionItem('Received', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC'),
      _buildTransactionItem('Sent', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC', '0.0001 BTC'),
    ],
  );
}

Widget _buildTransactionItem(String type, String amount, String fee, String date, String status) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.account_balance_wallet, color: Colors.black),
    ),
    title: Text(type, style: const TextStyle(fontSize: 12, color: Colors.black)),
    subtitle: Text(amount, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    trailing: Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
  );
}