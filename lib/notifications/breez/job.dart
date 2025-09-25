import 'dart:async';
import 'dart:convert';

import 'package:Satsails/notifications/breez/notification.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:http/http.dart' as http;

// --- Abstract Base Class & Helpers (No changes needed here) ---
abstract class Job {
  final String payload;
  Job(this.payload);
  Future<void> start(BreezSdkLiquid sdk);

  Future<void> replyToServer(String url, Map<String, dynamic> data, {int maxAge = 0}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (maxAge > 0) headers['Cache-Control'] = 'max-age=$maxAge';
      await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to reply to server: $e');
      throw e;
    }
  }

  Future<void> fail(String reason, String replyUrl) async {
    await replyToServer(replyUrl, {'status': 'ERROR', 'reason': reason});
  }
}
class LnurlPayInfoRequest {
  final String callbackUrl;
  final String replyUrl;
  LnurlPayInfoRequest.fromJson(Map<String, dynamic> json)
      : callbackUrl = json['callback_url'],
        replyUrl = json['reply_url'];
}
class LnurlPayInvoiceRequest {
  final int amount;
  final String? comment;
  final String replyUrl;
  final String? verifyUrl;
  LnurlPayInvoiceRequest.fromJson(Map<String, dynamic> json)
      : amount = json['amount'],
        comment = json['comment'],
        replyUrl = json['reply_url'],
        verifyUrl = json['verify_url'];
}
class LnurlPayVerifyRequest {
  final String paymentHash;
  final String replyUrl;
  LnurlPayVerifyRequest.fromJson(Map<String, dynamic> json)
      : paymentHash = json['payment_hash'],
        replyUrl = json['reply_url'];
}
class SwapUpdatedRequest {
  final String id;
  SwapUpdatedRequest.fromJson(Map<String, dynamic> json) : id = json['id'];
}
class InvoiceRequestRequest {
  final String offer;
  final String invoiceRequest;
  final String replyUrl;
  InvoiceRequestRequest.fromJson(Map<String, dynamic> json)
      : offer = json['offer'],
        invoiceRequest = json['invoice_request'],
        replyUrl = json['reply_url'];
}

class LnurlPayInfoJob extends Job {
  LnurlPayInfoJob(super.payload);

  @override
  Future<void> start(BreezSdkLiquid sdk) async {
    const String tag = 'LnurlPayInfoJob';
    LnurlPayInfoRequest? request;
    bool success = false;
    try {
      final data = jsonDecode(payload);
      request = LnurlPayInfoRequest.fromJson(data);
      final limits = await sdk.fetchLightningLimits();
      final maxSat = limits.receive.maxSat;
      final minSat = limits.receive.minSat;

      if (minSat < BigInt.one || (minSat * BigInt.from(1000)) > (maxSat * BigInt.from(1000))) {
        throw Exception("Invalid min-sendable amount in limits.");
      }
      const String plainTextMetadata = "Pay to satsails";

      final response = {
        'tag': 'payRequest',
        'minSendable': (minSat * BigInt.from(1000)).toInt(),
        'callback': request.callbackUrl,
        'maxSendable': (maxSat * BigInt.from(1000)).toInt(),
        'metadata': jsonEncode([['text/plain', plainTextMetadata]]),
      };

      await replyToServer(request.replyUrl, response, maxAge: 86400);
      success = true;
    } catch (e) {
      debugPrint('$tag: Failed to process lnurl: $e');
      if (request != null) await fail(e.toString(), request.replyUrl);
    } finally {
      await NotificationHelper.showNotification(
        title: success ? 'Retrieving Payment Information'.i18n : 'Receive Payment Failed'.i18n,
        channelId: NotificationHelper.replaceableChannelId,
      );
    }
  }
}

class LnurlPayInvoiceJob extends Job {
  LnurlPayInvoiceJob(super.payload);

  @override
  Future<void> start(BreezSdkLiquid sdk) async {
    const String tag = 'LnurlPayInvoiceJob';
    LnurlPayInvoiceRequest? request;
    bool success = false;
    try {
      final data = jsonDecode(payload);
      request = LnurlPayInvoiceRequest.fromJson(data);
      final limits = await sdk.fetchLightningLimits();
      final amountSatBigInt = BigInt.from((request.amount / 1000).truncate());

      if (amountSatBigInt < limits.receive.minSat || amountSatBigInt > limits.receive.maxSat) {
        throw Exception("Invalid amount requested: ${request.amount}");
      }
      const plainTextMetadata = "Pay to satsails";
      final prepareRes = await sdk.prepareReceivePayment(
        req: PrepareReceiveRequest(
          paymentMethod: PaymentMethod.lightning,
          amount: ReceiveAmount_Bitcoin(payerAmountSat: amountSatBigInt),
        ),
      );
      final receiveRes = await sdk.receivePayment(
        req: ReceivePaymentRequest(
          prepareResponse: prepareRes,
          description: jsonEncode([['text/plain', plainTextMetadata]]),
          useDescriptionHash: true,
          payerNote: request.comment,
        ),
      );

      String? verificationUrl;
      if (request.verifyUrl != null) {
        try {
          final inputType = await sdk.parse(input: receiveRes.destination);
          if (inputType is InputType_Bolt11) {
            verificationUrl = request.verifyUrl!.replaceAll('{payment_hash}', inputType.invoice.paymentHash);
          }
        } catch (e) {
          debugPrint('$tag: Failed to parse invoice to build verify URL: $e');
        }
      }

      final response = {
        'pr': receiveRes.destination,
        'routes': [],
        if (verificationUrl != null) 'verify': verificationUrl,
      };

      await replyToServer(request.replyUrl, response);
      success = true;
    } catch (e) {
      debugPrint('$tag: Failed to process lnurl invoice: $e');
      if (request != null) await fail(e.toString(), request.replyUrl);
    } finally {
      await NotificationHelper.showNotification(
        title: success ? 'Fetching Invoice'.i18n : 'Receive Payment Failed'.i18n,
        channelId: NotificationHelper.replaceableChannelId,
      );
    }
  }
}

// ... (The rest of your jobs and the factory function remain the same)
class LnurlPayVerifyJob extends Job {
  LnurlPayVerifyJob(super.payload);

  @override
  Future<void> start(BreezSdkLiquid sdk) async {
    const String tag = 'LnurlPayVerifyJob';
    LnurlPayVerifyRequest? request;
    bool success = false;
    try {
      final data = jsonDecode(payload);
      request = LnurlPayVerifyRequest.fromJson(data);

      final payment = await sdk.getPayment(req: GetPaymentRequest_PaymentHash(paymentHash: request.paymentHash));
      if (payment == null) {
        throw Exception("Payment not found");
      }

      final details = payment.details;
      if (details is! PaymentDetails_Lightning) {
        throw Exception("Payment is not a lightning payment");
      }

      final settled = payment.status == PaymentState.complete ||
          (payment.status == PaymentState.pending && details.claimTxId != null);

      final response = {
        'pr': details.invoice,
        'settled': settled,
        'status': 'OK',
      };

      final maxAge = settled ? (60 * 60 * 24 * 7) : 3; // 1 week or 3 seconds
      await replyToServer(request.replyUrl, response, maxAge: maxAge);
      success = true;
    } catch (e) {
      debugPrint('$tag: Failed to process lnurl verify: $e');
      if (request != null) await fail(e.toString(), request.replyUrl);
    } finally {
      await NotificationHelper.showNotification(
        title: success ? 'Verifying Payment'.i18n : 'Payment Verification Failed'.i18n,
        channelId: NotificationHelper.replaceableChannelId,
      );
    }
  }
}

class SwapUpdatedJob extends Job {
  SwapUpdatedJob(super.payload);

  @override
  Future<void> start(BreezSdkLiquid sdk) async {
    const String tag = 'SwapUpdatedJob';
    try {
      final data = jsonDecode(payload);
      final request = SwapUpdatedRequest.fromJson(data);
      final swapIdHash = request.id;

      // Poll for payment status
      for (int i = 0; i < 10; i++) { // Poll a few times
        final payment = await sdk.getPayment(req: GetPaymentRequest_SwapId(swapId: swapIdHash));
        if (payment != null) {
          if (payment.status == PaymentState.created) {
            _handlePaymentSuccess(payment);
            return;
          }
          if (payment.status == PaymentState.waitingFeeAcceptance) {
            _handlePaymentWaitingFeeAcceptance();
            return;
          }
        }
        await Future.delayed(const Duration(seconds: 5));
      }
      _handleFailure(); // If not found after polling
    } catch (e) {
      debugPrint('$tag: Failed to process swap update: $e');
      _handleFailure();
    }
  }

  void _handlePaymentSuccess(Payment payment) {
    final received = payment.paymentType == PaymentType.receive;
    NotificationHelper.showNotification(
      title: received ? 'Payment Received'.i18n : 'Payment Sent'.i18n,
      body: '${payment.amountSat} sats',
      channelId: NotificationHelper.dismissibleChannelId,
    );
  }

  void _handlePaymentWaitingFeeAcceptance() {
    NotificationHelper.showNotification(
      title: 'Payment requires fee acceptance'.i18n,
      body: 'Tap to review updated fees'.i18n,
      channelId: NotificationHelper.dismissibleChannelId,
    );
  }

  void _handleFailure() {
    NotificationHelper.showNotification(
      title: 'Payment Pending'.i18n,
      body: 'Tap to complete payment'.i18n,
      channelId: NotificationHelper.dismissibleChannelId,
    );
  }
}

class InvoiceRequestJob extends Job {
  InvoiceRequestJob(super.payload);

  @override
  Future<void> start(BreezSdkLiquid sdk) async {
    const String tag = 'InvoiceRequestJob';
    InvoiceRequestRequest? request;
    bool success = false;
    try {
      final data = jsonDecode(payload);
      request = InvoiceRequestRequest.fromJson(data);

      final createInvoiceResponse = await sdk.createBolt12Invoice(
        req: CreateBolt12InvoiceRequest(
          offer: request.offer,
          invoiceRequest: request.invoiceRequest,
        ),
      );

      final response = {'invoice': createInvoiceResponse.invoice};
      await replyToServer(request.replyUrl, response);
      success = true;
    } catch (e) {
      debugPrint('$tag: Failed to process invoice request: $e');
      if (request != null) {
        await replyToServer(request.replyUrl, {'error': e.toString()});
      }
    } finally {
      await NotificationHelper.showNotification(
        title: success ? 'Fetching Invoice'.i18n : 'Invoice Request Failed'.i18n,
        channelId: NotificationHelper.replaceableChannelId,
      );
    }
  }
}


/// Factory function to create the correct job from a RemoteMessage.
Job? getJobFromMessage(RemoteMessage message) {
  final type = message.data[NotificationType.type];
  final payload = message.data[NotificationType.payload];
  if (payload == null) return null;

  switch (type) {
    case NotificationType.lnurlPayInfo:
      return LnurlPayInfoJob(payload);
    case NotificationType.lnurlPayInvoice:
      return LnurlPayInvoiceJob(payload);
    case NotificationType.lnurlPayVerify:
      return LnurlPayVerifyJob(payload);
    case NotificationType.swapUpdated:
      return SwapUpdatedJob(payload);
    case NotificationType.invoiceRequest:
      return InvoiceRequestJob(payload);
    default:
      return null;
  }
}
