import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineTransactionWarning extends ConsumerWidget {
  final bool online;

  OfflineTransactionWarning({required this.online});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text(
            'You are offline.'.i18n(ref),
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