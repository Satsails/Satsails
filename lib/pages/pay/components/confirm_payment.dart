import 'package:flutter/material.dart';

class ConfirmPayment extends StatelessWidget {
  final String address;

  ConfirmPayment({required this.address});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Payment'),
      ),
      body: Center(
        child: Text('Address: $address'),
      ),
    );
  }
}