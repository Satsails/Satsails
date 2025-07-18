import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_config_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickalert/quickalert.dart';

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
        color: Colors.redAccent,
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
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Delete Wallet?'.i18n,
      text: 'Are you sure you want to delete the wallet?'.i18n,
      titleColor: Colors.redAccent,
      textColor: Colors.white70,
      backgroundColor: Colors.black87,
      headerBackgroundColor: Colors.black87,
      showCancelBtn: false,
      showConfirmBtn: false,
      widget: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CustomElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close first dialog
            _showSecondDeleteDialog(context, authModel, ref); // Show second dialog
          },
          text: 'Delete Wallet'.i18n,
          backgroundColor: Colors.redAccent,
        ),
      ),
    );
  }

  void _showSecondDeleteDialog(BuildContext context, AuthModel authModel, WidgetRef ref) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Delete Wallet?'.i18n,
      text: 'Are you sure you want to delete the wallet?'.i18n,
      titleColor: Colors.redAccent,
      textColor: Colors.white70,
      backgroundColor: Colors.black87,
      showCancelBtn: false,
      showConfirmBtn: false,
      headerBackgroundColor: Colors.black87,
      widget: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CustomElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close second dialog
            await authModel.deleteAuthentication();
            ref.read(appLockedProvider.notifier).state = true;
            ref.invalidate(bitcoinConfigProvider);
            ref.invalidate(liquidConfigProvider);
            RestartWidget.restartApp(context);
          },
          text: 'Delete Wallet'.i18n,
          backgroundColor: Colors.redAccent,
        ),
      ),
    );
  }
}