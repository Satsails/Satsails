import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PixHistory extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pixHistory = ref.watch(getUserTransactionsProvider);

    return pixHistory.when(
        data: (history) => ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final pix = history[index];
            return ListTile(
              title: Text(pix),
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error'.i18n(ref))),
    );
  }
}
