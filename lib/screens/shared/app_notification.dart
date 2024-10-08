import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/pix_transaction_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/shared/notification_widget.dart';
import 'package:in_app_notification/in_app_notification.dart';

class AppNotification extends ConsumerWidget {
  const AppNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(pixTransactionReceivedProvider);

    notification.whenData((data) async {
      if (data.isNotEmpty) {
        final messageType = data['type'] ?? 'default';

        if (messageType == 'success') {
          // Show success notification
          InAppNotification.show(
            context: context,
            child: NotificationWidget(
              title: 'PIX received'.i18n(ref),
              body: 'App will sync in background'.i18n(ref),
              backgroundColor: Colors.green,
            ),
          );

          // Perform sync for success
          await ref.read(liquidSyncNotifierProvider.notifier).performSync();
        } else if (messageType == 'failed') {
          // Show failed notification
          InAppNotification.show(
            context: context,
            child: NotificationWidget(
              title: 'PIX failed'.i18n(ref),
              body: 'Transaction failed, please try again'.i18n(ref),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });

    return const SizedBox.shrink();
  }
}