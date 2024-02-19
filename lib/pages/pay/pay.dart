import 'package:flutter/material.dart';

class Pay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text('This is the Account Component'),
    );
  }
//   after reading the qr code if it is liquid as if you want to send dollars or bitcoin
//   for transactions if no sufficient balance, redirect user to exhange so he can manually exhange
//   (id he has usd and wants to send btc he must go to exhange, convert from usd to l-btc and then to btc and then send)
// implement message saying that feature that learns from user's transactions will adjust to reduce fees.
// Must have balancing functions that will calculate what needs to be sent, and do all the appropriate conversions in the background.
}