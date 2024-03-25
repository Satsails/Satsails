import 'package:flutter/material.dart';

class Support extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Page'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Text('This is the Account Component'),
      ),
    );
  }
}