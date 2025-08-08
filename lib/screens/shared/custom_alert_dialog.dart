import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> showCustomAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required List<Widget> actions,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return CustomAlertDialog(
        title: title,
        content: content,
        actions: actions,
      );
    },
  );
}

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    actions[i],
                    if (i < actions.length - 1) SizedBox(height: 12.h),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
