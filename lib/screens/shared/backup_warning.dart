import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BackupWarning extends ConsumerWidget {
  const BackupWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final backupWarning = ref.watch(settingsProvider).backup;

    final dynamicFontSize = screenSize.width * 0.04;

    return !backupWarning
        ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.key_off,
              color: Colors.red,
            ),
            TextButton(
              onPressed: () {
                context.push('/seed_words');
              },
              child: Text(
                'Backup your wallet'.i18n,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: dynamicFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )
        : Container();
  }
}
