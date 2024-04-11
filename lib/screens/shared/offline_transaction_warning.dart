import 'package:flutter/material.dart';

class OfflineTransactionWarning extends StatelessWidget {
  final bool online;

  OfflineTransactionWarning({required this.online});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final dynamicPadding = screenSize.width * 0.03;
    final dynamicFontSize = screenSize.width * 0.04;

    return !online ? Padding(
      padding: EdgeInsets.all(dynamicPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.orange,
          ),
          SizedBox(width: 10),
          Text(
            'You are offline.',
            style: TextStyle(
              color: Colors.orange,
              fontSize: dynamicFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ) : Container();
  }
}