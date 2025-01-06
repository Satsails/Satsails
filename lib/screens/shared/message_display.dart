import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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

void showTopOverlayMessage({
  required BuildContext context,
  required String message,
  required bool error,
}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 8.0,
      left: 8.0,
      right: 8.0,
      child: Material(
        color: Colors.transparent,
        child: AwesomeSnackbarContent(
          title: error ? 'Oops' : 'Ok!',
          message: message,
          messageTextStyle: TextStyle(fontSize: 16.sp, color: Colors.white),
          inMaterialBanner: false,
          contentType: error ? ContentType.failure : ContentType.success,
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

void showBottomOverlayMessage({
  required BuildContext context,
  required String message,
  required bool error,
}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 8.0,
      left: 8.0,
      right: 8.0,
      child: Material(
        color: Colors.transparent,
        child: AwesomeSnackbarContent(
          title: error ? 'Oops' : 'Ok!',
          message: message,
          messageTextStyle: TextStyle(fontSize: 16.sp, color: Colors.white),
          inMaterialBanner: false,
          contentType: error ? ContentType.failure : ContentType.success,
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

void showBottomOverlayMessageInfo({
  required BuildContext context,
  required String message,
}) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 8.0,
      left: 8.0,
      right: 8.0,
      child: Material(
        color: Colors.transparent,
        child: AwesomeSnackbarContent(
          title: 'Oops',
          message: message,
          messageTextStyle: TextStyle(fontSize: 16.sp),
          inMaterialBanner: false,
          contentType: ContentType.warning,
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

void showMessageSnackBar({
  required BuildContext context,
  required String message,
  required bool error,
}) {
  if (ScaffoldMessenger.maybeOf(context) == null) {
    return;
  }

  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    duration: const Duration(seconds: 3),
    content: AwesomeSnackbarContent(
      title: error ? 'Oops' : 'Ok!',
      message: message,
      messageTextStyle: TextStyle(fontSize: 16.sp, color: Colors.white),
      inMaterialBanner: true,
      contentType: error ? ContentType.failure : ContentType.success,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

void showInformationModal({
  required BuildContext context,
  required String title,
  required dynamic message,
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
