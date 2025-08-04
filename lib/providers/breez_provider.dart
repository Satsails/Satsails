import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/providers/breez_config_provider.dart';
import 'package:Satsails/services/breez/sdk_instance.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
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

// final lnAddressProvider = AsyncNotifierProvider<LnAddressNotifier, String?>(() {
//   return LnAddressNotifier();
// });

//
// final _lnurlCommonDepsProvider = FutureProvider<({
// BreezSDKLiquid sdk,
// LnurlService service,
// String webhookUrl,
// String pubkey,
// String? offer,
// int timestamp,
// })>((ref) async {
//   final sdk = await ref.watch(breezSDKProvider.future);
//   if (sdk.instance == null) {
//     throw Exception('Breez SDK not initialized.');
//   }
//
//   final webhookManager = LnurlWebhookManager(sdk);
//   final webhookUrl = await webhookManager.generateAndCacheWebhookUrl();
//   await webhookManager.registerWebhook(webhookUrl);
//
//   // Get node info for the pubkey.
//   final nodeInfo = await sdk.instance!.getInfo();
//   final pubkey = nodeInfo.walletInfo.pubkey;
//
//   // Attempt to get a Bolt12 offer, but don't fail if it doesn't work.
//   String? offer;
//   try {
//     const prepareReq = PrepareReceiveRequest(paymentMethod: PaymentMethod.bolt12Offer);
//     final prepareRes = await sdk.instance!.prepareReceivePayment(req: prepareReq);
//     final receiveReq = ReceivePaymentRequest(prepareResponse: prepareRes);
//     final receiveRes = await sdk.instance!.receivePayment(req: receiveReq);
//     offer = receiveRes.destination;
//   } on Exception {
//     // No-op, continue if the offer can't be generated
//   }
//
//   // Use a single timestamp for all signed messages.
//   final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//
//   return (
//   sdk: sdk,
//   service: LnurlService(),
//   webhookUrl: webhookUrl,
//   pubkey: pubkey,
//   offer: offer,
//   timestamp: timestamp,
//   );
// });
//
// // Provider to create a new LNURL or update an existing one.
// final editOrCreateLnurlProvider = FutureProvider.family<Result<Lnurl>, String>((ref, username) async {
//   final deps = await ref.watch(_lnurlCommonDepsProvider.future);
//   final isNewRegistration = ref.read(lnAddressProvider) == null;
//
//   final messageToSign = deps.service.constructSignedMessage(
//     time: deps.timestamp,
//     webhookUrl: deps.webhookUrl,
//     username: username, // Username is required for editing or new registration
//     offer: deps.offer,
//   );
//
//   final signRequest = SignMessageRequest(message: messageToSign);
//   final signResponse = await deps.sdk.instance!.signMessage(req: signRequest);
//   final signature = signResponse.signature;
//
//   final registrationType = isNewRegistration ? RegistrationType.newRegistration : RegistrationType.update;
//
//   final registrationResult = await deps.service.performRegistration(
//     pubkey: deps.pubkey,
//     signature: signature,
//     webhookUrl: deps.webhookUrl,
//     offer: deps.offer,
//     registrationType: registrationType,
//     username: username,
//   );
//
//   if (registrationResult.isSuccess && registrationResult.data?.lightningAddress != null) {
//     ref.read(lnAddressProvider.notifier).updateLnAddress(registrationResult.data!.lightningAddress);
//   }
//
//   return registrationResult;
// });
//
// // Provider for recovering a previously registered LNURL.
// final recoverLnurlProvider = FutureProvider<Result<Lnurl>>((ref) async {
//   final deps = await ref.watch(_lnurlCommonDepsProvider.future);
//
//   // STEP 1: Sign the message for the recovery request
//   final recoveryMessageToSign = deps.service.constructSignedMessage(
//     time: deps.timestamp,
//     webhookUrl: deps.webhookUrl,
//     // Note: username and offer are intentionally null for recovery
//     username: null,
//     offer: null,
//   );
//
//   final recoverySignRequest = SignMessageRequest(message: recoveryMessageToSign);
//   final recoverySignResponse = deps.sdk.instance!.signMessage(req: recoverySignRequest);
//   final recoverySignature = recoverySignResponse.signature;
//
//   // STEP 2: Perform the recovery call using the dedicated signature.
//   final recoveryResult = await deps.service.recoverLnurl(
//     pubkey: deps.pubkey,
//     signature: recoverySignature,
//     webhookUrl: deps.webhookUrl,
//   );
//
//   // STEP 3: Handle a successful recovery by re-registering to transfer ownership.
//   if (recoveryResult.isSuccess && recoveryResult.data?.lightningAddress != null) {
//
//     // Generate a new, unique username for ownership transfer.
//     final recoveredUsername = recoveryResult.data!.lightningAddress!.split('@').first;
//
//     // Sign a NEW message for the registration with the recovered username.
//     final registrationMessageToSign = deps.service.constructSignedMessage(
//       time: deps.timestamp,
//       webhookUrl: deps.webhookUrl,
//       username: recoveredUsername,
//       offer: deps.offer,
//     );
//
//     final registrationSignRequest = SignMessageRequest(message: registrationMessageToSign);
//     final registrationSignResponse = await deps.sdk.instance!.signMessage(req: registrationSignRequest);
//     final registrationSignature = registrationSignResponse.signature;
//
//     // STEP 4: Perform the ownership transfer (re-registration) with the new signature.
//     final ownershipTransferResult = await deps.service.performRegistration(
//       pubkey: deps.pubkey,
//       signature: registrationSignature,
//       webhookUrl: deps.webhookUrl,
//       username: recoveredUsername,
//       offer: deps.offer,
//       registrationType: RegistrationType.ownershipTransfer,
//     );
//
//     if (ownershipTransferResult.isSuccess && ownershipTransferResult.data?.lightningAddress != null) {
//       ref.read(lnAddressProvider.notifier).updateLnAddress(ownershipTransferResult.data!.lightningAddress!);
//     } else {
//     }
//
//   });
