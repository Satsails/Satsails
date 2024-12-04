import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/restart_widget.dart';
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
      type: QuickAlertType.warning,
      title: 'Delete Wallet?'.i18n(ref),
      text: 'Choose an option below:'.i18n(ref),
      confirmBtnText: 'Delete Wallet'.i18n(ref),
      titleColor: Colors.white,
      textColor: Colors.white,
      backgroundColor: Colors.black,
      showCancelBtn: true,
      cancelBtnTextStyle: const TextStyle(color: Colors.green, fontSize: 20),
      confirmBtnColor: Colors.red,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.confirm,
          title: 'Delete Wallet?'.i18n(ref),
          text: 'Are you sure you want to delete the wallet?'.i18n(ref),
          confirmBtnText: 'Delete'.i18n(ref),
          titleColor: Colors.white,
          textColor: Colors.white,
          backgroundColor: Colors.black,
          showCancelBtn: true,
          cancelBtnTextStyle: const TextStyle(color: Colors.green, fontSize: 20),
          confirmBtnColor: Colors.red,
          onConfirmBtnTap: () async {
            context.pop();
            await authModel.deleteAuthentication();
            RestartWidget.restartApp(context);
          },
        );
      },
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required IconData icon,
        required String title,
        required String description,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: color),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color.darken(),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
