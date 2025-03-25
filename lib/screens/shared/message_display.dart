import 'package:Satsails/translations/translations.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:quickalert/quickalert.dart';

class MessageDisplay extends ConsumerWidget {
  final String message;

  const MessageDisplay({
    super.key,
    required this.message,
  });

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
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.i18n,
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

void showMessageSnackBarInfo({
  required BuildContext context,
  required String message,
}) {
  DelightToastBar(
    snackbarDuration: const Duration(seconds: 3),
    builder: (context) => ToastCard(
      color: Colors.grey.shade900,
      leading: const Icon(
        Icons.info,
        size: 28,
        color: Colors.orange,
      ),
      title: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: Colors.white,
        ),
      ),
    ),
    position: DelightSnackbarPosition.bottom,
  ).show(context);
}

void showMessageSnackBar({
  required BuildContext context,
  required String message,
  required bool error,
  bool info = false,
  bool top = false,
}) {
  DelightToastBar(
    snackbarDuration: const Duration(seconds: 3),
    autoDismiss: true,
    animationDuration: const Duration(milliseconds: 500),
    builder: (context) => ToastCard(
      color: error ? Colors.red : Colors.green,
      leading: Icon(
          error ? Icons.error : info ? Icons.info : Icons.check_circle,
          color: Colors.white,
          size: 28.sp
      ),
      title: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: Colors.white,
        ),
      ),
    ),
    position: top ? DelightSnackbarPosition.top : DelightSnackbarPosition.bottom,
  ).show(context);
}

void showInformationModal({
  required BuildContext context,
  required String title,
  required dynamic message,
}) {
  String formattedMessage;

  if (message is List<String>) {
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
    titleColor: Colors.white,
    backgroundColor: Colors.black87, // Slightly lighter for better aesthetics
    showCancelBtn: false,
    showConfirmBtn: false,
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedMessage,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.01.sh),
        // Optional: Close Button or Additional Elements
        // Since the user requested not to add buttons, we'll omit this.
      ],
    ),
  );
}
