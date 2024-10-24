import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ErrorDisplay extends ConsumerWidget {
  final String message;
  final bool isCard;
  final bool showToast;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.isCard = true,
    this.showToast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showToast) {
      Fluttertoast.showToast(
        msg: message.i18n(ref),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    if (isCard) {
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
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message.i18n(ref),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
