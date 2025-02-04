import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_config_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/quickalert.dart';

class DeleteWalletSection extends StatelessWidget {
  final WidgetRef ref;
  final String title;

  const DeleteWalletSection(
      {super.key, required this.ref, this.title = 'Delete Wallet'});

  @override
  Widget build(BuildContext context) {
    final authModel = ref.read(authModelProvider);
    return ListTile(
      leading: const Icon(Icons.delete, color: Colors.white),
      title: Text(title.i18n(ref), style: const TextStyle(color: Colors.white)),
      onTap: () {
        _showDeleteDialog(context, authModel, ref);
      },
    );
  }

  void _showDeleteDialog(BuildContext context, AuthModel authModel, WidgetRef ref) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Delete Wallet?'.i18n(ref),
      text: 'Are you sure you want to delete the wallet?'.i18n(ref),
      titleColor: Colors.redAccent, // Consistent title color
      textColor: Colors.white70,
      backgroundColor: Colors.black87,
      headerBackgroundColor: Colors.black87,
      showCancelBtn: false,
      showConfirmBtn: false,
      widget:
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CustomElevatedButton(
          onPressed: () {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Delete Wallet?'.i18n(ref),
              text: 'Are you sure? This action cannot be undone.'.i18n(ref),
              titleColor: Colors.redAccent, // Consistent title color
              textColor: Colors.white70,
              backgroundColor: Colors.black87,
              headerBackgroundColor: Colors.black87,
              showCancelBtn: false,
              showConfirmBtn: false,
              widget:
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: CustomElevatedButton(
                  onPressed: () async {
                    context.pop();
                    await authModel.deleteAuthentication();
                    ref.read(appLockedProvider.notifier).state = true;
                    ref.invalidate(bitcoinConfigProvider);
                    ref.invalidate(liquidConfigProvider);
                    RestartWidget.restartApp(context);
                  },
                  text:
                  'Delete wallet'.i18n(ref),
                  backgroundColor: Colors.redAccent,
                ),
              ),
            );
          },
          text: 'Delete wallet'.i18n(ref),
          backgroundColor: Colors.redAccent,
        ),
      ),
    );
  }
}

