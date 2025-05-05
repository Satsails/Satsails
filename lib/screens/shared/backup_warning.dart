import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class BackupWarning extends ConsumerWidget {
  const BackupWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupWarning = ref.watch(settingsProvider).backup;
    final hasCoinos = ref.watch(coinosLnProvider).token.isNotEmpty;
    final hasMigratedCoinos = ref.watch(coinosLnProvider).isMigrated;

    if (hasCoinos && !hasMigratedCoinos) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.cloud, // Icon representing migration
            color: Colors.red,
          ),
          TextButton(
            onPressed: () {
              showCustodialWarningModal(context, ref);
            },
            child: Text(
              'Lightning migration'.i18n,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (!backupWarning) {
      return Row(
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
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        'Transactions'.i18n,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }
  }
}

// terrible code repetition but it is only here because it will be deleted soon anyway

void showCustodialWarningModal(BuildContext context, WidgetRef ref) {
  final coinosLn = ref.watch(coinosLnProvider);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black87,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(24.sp),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lightning Migration Warning'.i18n,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.sp),
              Text(
                'You can retrieve your past Coinos balances since we have migrated to Spark'.i18n,
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
              SizedBox(height: 24.sp),
              _buildCopyableField(label: 'Username', value: coinosLn.username, context: context),
              SizedBox(height: 16.sp),
              _buildCopyableField(label: 'Password', value: coinosLn.password, context: context),
              SizedBox(height: 24.sp),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () => _launchURL('https://coinos.io/login'),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.sp),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Visit Coinos'.i18n,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.sp),
                    TextButton(
                      onPressed: () {
                        ref.read(coinosLnProvider.notifier).setMigrated(true);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 24.sp),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Mark as Migrated'.i18n,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildCopyableField({required String label, required String value, required BuildContext context}) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4.0),
            SelectableText(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.copy, color: Colors.white),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          showMessageSnackBar(context: context, message: '$label copied to clipboard!'.i18n, error: false);
        },
      ),
    ],
  );
}

Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}