import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupWarning extends ConsumerWidget {
  const BackupWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final backupWarning = ref.watch(settingsProvider).backup;

    final dynamicPadding = screenSize.width * 0.03;
    final dynamicFontSize = screenSize.width * 0.04;

    return !backupWarning
        ? Padding(
      padding: EdgeInsets.all(dynamicPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.warning,
            color: Colors.orange,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/backup_wallet');
            },
            child: Text(
              'Backup your wallet'.i18n(ref),
              style: TextStyle(
                color: Colors.orange,
                fontSize: dynamicFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )
        : Container();
  }
}
