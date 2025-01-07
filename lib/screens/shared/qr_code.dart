import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget buildQrCode(String address, BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Hero(
        tag: 'qrCode',
        child: QrImageView(
          data: address,
          version: QrVersions.auto,
          size: 0.5.sw,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.black,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.circle,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}