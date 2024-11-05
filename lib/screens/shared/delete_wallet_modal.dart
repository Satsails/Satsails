import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final recovery_code =  ref.read(userProvider).recoveryCode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                  size: 60,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Delete Wallet?'.i18n(ref),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Select an option below to proceed.'.i18n(ref),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                _buildOptionCard(
                  context,
                  icon: Icons.smartphone,
                  title: 'Delete Local Wallet'.i18n(ref),
                  description: 'Remove wallet data from this device only.'.i18n(ref),
                  color: Colors.blueAccent,
                  onTap: () {
                    _showConfirmationDialog(
                      context,
                      icon: Icons.smartphone,
                      iconColor: Colors.blueAccent,
                      title: 'Delete Local Wallet?'.i18n(ref),
                      message: 'Are you sure you want to delete the local wallet?'.i18n(ref),
                      confirmButtonColor: Colors.blueAccent,
                      confirmAction: () async {
                        await authModel.deleteAuthentication();
                        RestartWidget.restartApp(context);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                if (recovery_code != '') _buildOptionCard(
                  context,
                  icon: Icons.cloud_done,
                  title: 'Delete Server Data and Local Wallet'.i18n(ref),
                  description: 'Remove your data from the server and this device.'.i18n(ref),
                  color: Colors.orangeAccent,
                  onTap: () {
                    _showConfirmationDialog(
                      context,
                      icon: Icons.cloud_done,
                      iconColor: Colors.orangeAccent,
                      title: 'Delete Server Data and Local Wallet?'.i18n(ref),
                      message: 'Your server data and local wallet will be permanently deleted, and you will not receive any more fees from any of your affiliates.'.i18n(ref),
                      confirmButtonColor: Colors.orangeAccent,
                      confirmAction: () async {
                        await ref.read(deleteUserDataProvider.future);
                        await authModel.deleteAuthentication();
                        RestartWidget.restartApp(context);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Cancel'.i18n(ref),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
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

  void _showConfirmationDialog(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required Color confirmButtonColor,
    required VoidCallback confirmAction,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: iconColor,
                  child: Icon(icon, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      child: Text(
                        'Cancel'.i18n(ref),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: confirmButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      child: Text(
                        'Confirm'.i18n(ref),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        confirmAction();

                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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


