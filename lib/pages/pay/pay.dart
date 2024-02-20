import 'package:flutter/material.dart';

class Pay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text('This is the Account Component'),
    );
  }
// after reading the qr code if it is liquid as if you want to send dollars or bitcoin, or all avaliable funds
// Trying to send to lightening network, it will convert to bitcoin and send to lightening network via boltz. Will use lbtc if possible to send. ALso option to use all avaliable funds
// If sending to btc try to warn user to convert funds to btc if no sufficient.
// implement message saying that feature that learns from user's transactions will adjust to reduce fees.
// Must have balancing functions that will calculate what needs to be sent, and do all the appropriate conversions in the background.
}