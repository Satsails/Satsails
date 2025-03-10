import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

Widget buildAddressText(String address, BuildContext context, WidgetRef ref, [double fontSize = 16.0]) {

  return Padding(
    padding: EdgeInsets.all(8.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeIn,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.0),
          ),
          child: Padding(
            padding:EdgeInsets.symmetric(horizontal: 8.w),
            child: Center(
              child: Text(
                address,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding:EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  Share.share(address);
                },
                icon: Icon(Icons.share, color: Colors.white.withOpacity(0.7)),
                label: Text(
                  'Share'.i18n,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16.sp,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address));
                  showMessageSnackBar(
                    message: 'Address copied to clipboard'.i18n,
                    error: false,
                    context: context,
                  );
                },
                icon: Icon(Icons.copy, color: Colors.white.withOpacity(0.7)),
                label: Text(
                  'Copy'.i18n,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
