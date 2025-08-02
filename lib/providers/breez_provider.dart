import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/models/firebase_model.dart';
import 'package:Satsails/models/lnurl_model.dart';
import 'package:Satsails/providers/breez_config_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lightningLimitsProvider = FutureProvider<LightningPaymentLimitsResponse>((ref) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  return await sdk.instance!.fetchLightningLimits();
});

final prepareReceiveProvider = FutureProvider.family<PrepareReceiveResponse, BigInt>((ref, amountSat) async {
  final sdk = await ref.watch(breezSDKProvider.future);

  final req = PrepareReceiveRequest(
    paymentMethod: PaymentMethod.bolt11Invoice,
    amount: ReceiveAmount_Bitcoin(payerAmountSat: amountSat),
  );

  return await sdk.instance!.prepareReceivePayment(req: req);
});

final prepareReceiveResponseProvider = StateProvider<PrepareReceiveResponse?>((ref) => null);

final receivePaymentProvider = FutureProvider.family<ReceivePaymentResponse, String?>((ref, description) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final prepareResponse = ref.watch(prepareReceiveResponseProvider);

  if (prepareResponse == null) {
    throw Exception("prepareReceiveResponse is null. Cannot receive payment.");
  }

  final req = ReceivePaymentRequest(
    prepareResponse: prepareResponse,
    description: description,
  );

  return await sdk.instance!.receivePayment(req: req);
});

final receiveBolt12PaymentProvider =
FutureProvider.family<ReceivePaymentResponse, String?>((ref, description) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  if (sdk.instance == null) {
    throw Exception('Breez SDK is not initialized.');
  }

  final prepareReq = PrepareReceiveRequest(
    paymentMethod: PaymentMethod.bolt12Offer,
  );
  final prepareResponse = await sdk.instance!.prepareReceivePayment(req: prepareReq);

  final req = ReceivePaymentRequest(
    prepareResponse: prepareResponse,
    description: description,
  );

  return await sdk.instance!.receivePayment(req: req);
});

final parseInputProvider = FutureProvider.family<InputType, String>((ref, input) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  try {
    return await sdk.instance!.parse(input: input);
  } catch (e) {
    throw 'Invalid input address or invoice';
  }
});

final prepareSendResponseProvider = StateProvider<PrepareSendResponse?>((ref) => null);

final prepareSendProvider = FutureProvider.family<PrepareSendResponse, String>((ref, invoice) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = PrepareSendRequest(destination: invoice);

  final prepareResponse = await sdk.instance!.prepareSendPayment(req: req);

  ref.read(prepareSendResponseProvider.notifier).state = prepareResponse;

  return prepareResponse;
});

final sendPaymentProvider = FutureProvider<SendPaymentResponse>((ref) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final prepareResponse = ref.watch(prepareSendResponseProvider);

  if (prepareResponse == null) {
    throw Exception("Payment has not been prepared. Cannot send payment.");
  }

  final req = SendPaymentRequest(prepareResponse: prepareResponse);
  return await sdk.instance!.sendPayment(req: req);
});

final prepareLnurlPayProvider = FutureProvider.family<PrepareLnUrlPayResponse, ({LnUrlPayRequestData data, BigInt amount, String? comment, String? bip353Address})>((ref, params) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = PrepareLnUrlPayRequest(
    data: params.data,
    amount: PayAmount_Bitcoin(receiverAmountSat: params.amount),
    comment: params.comment,
    bip353Address: params.bip353Address,
  );
  return await sdk.instance!.prepareLnurlPay(req: req);
});

final prepareDrainLnurlProvider = FutureProvider.family<PrepareLnUrlPayResponse, ({LnUrlPayRequestData data, String? comment, String? bip353Address})>((ref, params) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = PrepareLnUrlPayRequest(
    data: params.data,
    amount: PayAmount_Drain(),
    comment: params.comment,
    bip353Address: params.bip353Address,
  );
  return await sdk.instance!.prepareLnurlPay(req: req);
});

final lnurlPayProvider = FutureProvider.family<LnUrlPayResult, PrepareLnUrlPayResponse>((ref, prepareResponse) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = LnUrlPayRequest(prepareResponse: prepareResponse);
  return await sdk.instance!.lnurlPay(req: req);
});

final listLightningPaymentsProvider = FutureProvider.family.autoDispose<List<Payment>, ListPaymentsRequest>((ref, req) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final allPayments = await sdk.instance!.listPayments(req: req);
  final lightningPayments = allPayments.where((p) => p.details is PaymentDetails_Lightning).toList();
  return lightningPayments;
});

final paymentProvider = FutureProvider.family<Payment?, GetPaymentRequest>((ref, req) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  return await sdk.instance!.getPayment(req: req);
});

final listRefundablesProvider = FutureProvider<List<RefundableSwap>>((ref) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  return await sdk.instance!.listRefundables();
});

final recommendedFeesProvider = FutureProvider<RecommendedFees>((ref) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  return await sdk.instance!.recommendedFees();
});

final prepareRefundProvider =
FutureProvider.family<PrepareRefundResponse, ({String swapAddress, String refundAddress, int feeRateSatPerVbyte})>((ref, params) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = PrepareRefundRequest(
    swapAddress: params.swapAddress,
    refundAddress: params.refundAddress,
    feeRateSatPerVbyte: params.feeRateSatPerVbyte,
  );
  return await sdk.instance!.prepareRefund(req: req);
});

final refundProvider = FutureProvider.family<RefundResponse, ({String swapAddress, String refundAddress, int feeRateSatPerVbyte})>((ref, params) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = RefundRequest(
    swapAddress: params.swapAddress,
    refundAddress: params.refundAddress,
    feeRateSatPerVbyte: params.feeRateSatPerVbyte,
  );
  return await sdk.instance!.refund(req: req);
});

final lnAddressProvider = AsyncNotifierProvider<LnAddressNotifier, String?>(() {
  return LnAddressNotifier();
});

final lnurlServiceProvider = Provider<LnurlService>(
      (ref) => LnurlService(),
);


final webhookUrlProvider = FutureProvider<String>((ref) async {
  final token = await FirebaseService.getTokenAndRefresh();
  final platform = await getPlatform();
  final url = dotenv.env['LNURL_SERVICE_URL'];
  return '$url/notify-lnurl/api/v1/notify?platform=$platform&token=$token';
});

final lnurlSignatureMessageProvider = Provider.family<String, SignatureParams>((ref, params) {
  final parts = [
    params.time.toString(),
    params.webhookUrl,
  ];

  if (params.username != null && params.username!.isNotEmpty) {
    parts.add(params.username!);

    if (params.offer != null && params.offer!.isNotEmpty) {
      parts.add(params.offer!);
    }
  }

  final finalMessage = parts.join('-');

  return finalMessage;
});

final setupLnAddressProvider = FutureProvider.family<Result<Lnurl>, ({String? username, bool isRecover})>(
      (ref, params) async {
    final sdk = await ref.watch(breezSDKProvider.future);
    if (sdk.instance == null) {
      throw Exception('Breez SDK not initialized.');
    }

    final service = ref.read(lnurlServiceProvider);
    final webhookUrl = await ref.watch(webhookUrlProvider.future);
    await sdk.instance!.registerWebhook(webhookUrl: webhookUrl);

    final nodeInfo = await sdk.instance!.getInfo();
    final pubkey = nodeInfo.walletInfo.pubkey;

    String? offer;
    try {
      const prepareReq = PrepareReceiveRequest(
        paymentMethod: PaymentMethod.bolt12Offer,
      );
      final prepareRes = await sdk.instance!.prepareReceivePayment(req: prepareReq);
      final receiveReq = ReceivePaymentRequest(
        prepareResponse: prepareRes,
      );
      final receiveRes = await sdk.instance!.receivePayment(req: receiveReq);
      offer = receiveRes.destination;
    } catch (e) {}

    final messageToSign = ref.read(lnurlSignatureMessageProvider(SignatureParams(
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      webhookUrl: webhookUrl,
      username: params.username,
      offer: offer,
    )));

    final signRequest = SignMessageRequest(message: messageToSign);
    final signResponse = sdk.instance!.signMessage(req: signRequest);
    final signature = signResponse.signature;

    final result = await service.performRegistration(
      pubkey: pubkey,
      signature: signature,
      webhookUrl: webhookUrl,
      registrationType: params.isRecover
          ? RegistrationType.recovery
          : (params.username != null
          ? RegistrationType.update
          : RegistrationType.newRegistration),
      baseUsername: params.username,
      offer: offer,
    );

    if (result.isSuccess && result.data?.lightningAddress != null) {
      ref.read(lnAddressProvider.notifier).updateLnAddress(result.data!.lightningAddress);
    }

    return result;
  },
);