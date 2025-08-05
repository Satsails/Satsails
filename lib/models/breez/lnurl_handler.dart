import 'dart:convert';

import 'package:Satsails/models/breez/sdk_instance.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LnurlHandler{
  Future<void> handleLnurlPayInfo({
    required BreezSDKLiquid sdk,
    required String payload,
  }) async {
    const String tag = 'LnurlPayInfoJob';
    try {
      final requestData = jsonDecode(payload);
      final String callbackUrl = requestData['callback_url'];
      final String replyUrl = requestData['reply_url'];

      final limits = await sdk.instance!.fetchLightningLimits();
      final int maxSat = limits.receive.maxSat.toInt();
      final int minSat = limits.receive.minSat.toInt();

      if (minSat < 1 || (minSat * 1000) > (maxSat * 1000)) {
        throw Exception("Invalid min-sendable amount in limits.");
      }

      const String metadataPlainText = "LNURL-pay to user";
      const int commentAllowed = 256;
      final String metadata = jsonEncode([
        ['text/plain', metadataPlainText]
      ]);

      final responsePayload = {
        'callback': callbackUrl,
        'maxSendable': maxSat * 1000,
        'minSendable': minSat * 1000,
        'metadata': metadata,
        'commentAllowed': commentAllowed,
        'tag': 'payRequest',
      };

      await _replyToServer(replyUrl, jsonEncode(responsePayload));
    } catch (e) {
      debugPrint('$tag: Failed to process lnurl: $e');
    }
  }


  Future<void> _replyToServer(String url, String body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'max-age=86400',
        },
        body: body,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error replying to server: $e');
    }}
}