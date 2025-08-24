import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_config_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/screens/shared/custom_alert_dialog.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/services/background_sync_service.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteWalletSection extends StatelessWidget {
  final WidgetRef ref;
  final String title;

  const DeleteWalletSection({
    super.key,
    required this.ref,
    this.title = 'Delete Wallet',
  });

  @override
  Widget build(BuildContext context) {
    final authModel = ref.read(authModelProvider);
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.delete, color: Colors.white),
        title: Text(
          title.i18n,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          _showFirstDeleteDialog(context, authModel, ref);
        },
      ),
    );
  }

  void _showFirstDeleteDialog(BuildContext context, AuthModel authModel, WidgetRef ref) {
    showCustomAlertDialog(
      context: context,
      title: 'Delete Wallet?'.i18n,
      content: 'This action is irreversible. Are you sure you have backed up your seed phrase?'.i18n,
      actions: [
        CustomButton(
          onPressed: () => Navigator.of(context).pop(),
          text: 'Cancel'.i18n,
          primaryColor: Colors.grey.withOpacity(0.2),
          secondaryColor: Colors.grey.withOpacity(0.2),
          textColor: Colors.white,
        ),
        const SizedBox(width: 12),
        CustomButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showSecondDeleteDialog(context, authModel, ref);
          },
          text: 'Delete Wallet'.i18n,
          primaryColor: Colors.redAccent,
          secondaryColor: Colors.red,
          textColor: Colors.white,
        ),
      ],
    );
  }

  void _showSecondDeleteDialog(BuildContext context, AuthModel authModel, WidgetRef ref) {
    showCustomAlertDialog(
      context: context,
      title: 'Final Confirmation'.i18n,
      content: 'All your data will be permanently erased. This cannot be undone.'.i18n,
      actions: [
        CustomButton(
          onPressed: () => Navigator.of(context).pop(),
          text: 'Cancel'.i18n,
          primaryColor: Colors.grey.withOpacity(0.2),
          secondaryColor: Colors.grey.withOpacity(0.2),
          textColor: Colors.white,
        ),
        const SizedBox(width: 12),
        CustomButton(
          onPressed: () async {
            Navigator.of(context).pop();

            BackgroundSyncService().stop();

            await authModel.deleteAuthentication();
            ref.invalidate(bitcoinConfigProvider);
            ref.invalidate(liquidConfigProvider);
            RestartWidget.restartApp(context);
          },
          text: 'Delete Wallet'.i18n,
          primaryColor: Colors.redAccent,
          secondaryColor: Colors.red,
          textColor: Colors.white,
        ),
      ],
    );
  }
}