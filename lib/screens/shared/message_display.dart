import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.clearSnackBars(); // Clear any existing snackbars

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          Icons.info,
          color: Colors.orange,
          size: 28.0, // Use 28.sp if using a scaling library
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0, // Use 16.sp if using a scaling library
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: Color(0xFF333333),
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  scaffoldMessenger.showSnackBar(snackBar);
}

void showMessageSnackBar({
  required BuildContext context,
  required String message,
  required bool error,
  bool info = false,
  bool top = false,
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.clearSnackBars(); // Clear any existing snackbars

  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          error
              ? Icons.error
              : info
              ? Icons.info
              : Icons.check_circle,
          color: Colors.white,
          size: 28.0,
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: error ? Colors.red : Colors.green,
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    margin: top
        ? EdgeInsets.only(
      top: 16.0,
      left: 16.0,
      right: 16.0,
    )
        : null,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  scaffoldMessenger.showSnackBar(snackBar);
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
