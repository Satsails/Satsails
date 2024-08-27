import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget buildQrCode(String address, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Hero(
        tag: 'qrCode',
        child: QrImageView(
          data: address,
          version: QrVersions.auto,
          size: MediaQuery.of(context).size.width * 0.5,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Colors.orange,
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