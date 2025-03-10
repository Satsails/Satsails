import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DepixConvertWarning extends ConsumerWidget {
  const DepixConvertWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final depixConvertWarning = ref.watch(balanceNotifierProvider).brlBalance;

    final dynamicFontSize = screenSize.width * 0.04;

    return depixConvertWarning >= 2000000000
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
         Icon(
          Icons.warning,
          color: Colors.orange,
          size: MediaQuery.of(context).size.width * 0.05,
        ),
        TextButton(
          onPressed: () {
            context.push('/home/exchange');
          },
          child: Text(
            'Convert your DEPIX to bitcoin'.i18n,
            style: TextStyle(
              color: Colors.grey,
              fontSize: dynamicFontSize,
            ),
          ),
        ),
      ],
    )
        : Container();
  }
}
