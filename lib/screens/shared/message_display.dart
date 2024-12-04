import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MessageDisplay extends ConsumerWidget {
  final String message;

  const MessageDisplay({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Colors.redAccent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.i18n(ref),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showMessageSnackBar({
  required BuildContext context,
  required String message,
  required bool error,
}) {
  IconSnackBar.show(
    context,
    label: message,
    iconColor: Colors.white,
    backgroundColor: error ? Colors.redAccent : Colors.green,
    snackBarType: error ? SnackBarType.fail : SnackBarType.success,
    duration: const Duration(seconds: 5),
  );
}

void showInformationModal({
  required BuildContext context,
  required String title,
  required dynamic message, // Accept both String and List<String>
}) {
  String formattedMessage;

  if (message is List<String>) {
    // Join array of messages into a single string with line breaks
    formattedMessage = message.join('\n');
  } else if (message is String) {
    formattedMessage = message;
  } else {
    throw ArgumentError('Message must be either a String or List<String>');
  }

  QuickAlert.show(
    context: context,
    type: QuickAlertType.info,
    title: title,
    text: formattedMessage,
    textColor: Colors.white,
    titleColor: Colors.white,
    confirmBtnText: 'OK',
    confirmBtnColor: Colors.orange,
    backgroundColor: Colors.black,
  );
}
