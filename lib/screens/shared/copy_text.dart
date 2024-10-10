import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

Widget buildAddressText(String address, BuildContext context, WidgetRef ref, [double fontSize = 16.0]) {
  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;

  return Padding(
    padding: EdgeInsets.all(width * 0.02),
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
            padding: EdgeInsets.symmetric(horizontal: width * 0.02),
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
        SizedBox(height: height * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  Share.share(address);
                },
                icon: Icon(Icons.share, color: Colors.white.withOpacity(0.7)),
                label: Text(
                  'Share'.i18n(ref),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16.0,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: address));
                  Fluttertoast.showToast(
                    msg: 'Address copied to clipboard'.i18n(ref),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                },
                icon: Icon(Icons.copy, color: Colors.white.withOpacity(0.7)),
                label: Text(
                  'Copy'.i18n(ref),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: width * 0.04,
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
