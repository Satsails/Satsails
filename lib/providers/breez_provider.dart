import 'package:Satsails/providers/breez_config_provider.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A single, central provider that resolves the Breez SDK instance.
// All other providers will watch this to avoid redundant fetches.
final breezSDKInstanceProvider = FutureProvider<BreezSDKInstance>((ref) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  return sdk.instance!;
});

final lightningLimitsProvider = FutureProvider<LightningPaymentLimitsResponse>((ref) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  return sdk.fetchLightningLimits();
});

final parseInputProvider = FutureProvider.family<InputType, String>((ref, input) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  try {
    return sdk.parse(input: input);
  } catch (e) {
    // Re-throw the original error to preserve the stack trace for better debugging.
    rethrow;
  }
});

// --- Receive Payment Flow (Refactored) ---

final prepareReceiveProvider = FutureProvider.family<PrepareReceiveResponse, BigInt>((ref, amountSat) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = PrepareReceiveRequest(
    paymentMethod: PaymentMethod.bolt11Invoice,
    amount: ReceiveAmount_Bitcoin(payerAmountSat: amountSat),
  );
  return sdk.prepareReceivePayment(req: req);
});

final prepareReceiveBolt12Provider = FutureProvider<PrepareReceiveResponse>((ref) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = PrepareReceiveRequest(paymentMethod: PaymentMethod.bolt12Offer);
  // This provider now simply returns the response. The StateProvider was removed.
  return sdk.prepareReceivePayment(req: req);
});

// This provider now takes the 'prepareResponse' directly as a parameter.
final receivePaymentProvider =
FutureProvider.family<ReceivePaymentResponse, ({PrepareReceiveResponse prepareResponse, String? description})>((ref, params) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = ReceivePaymentRequest(
    prepareResponse: params.prepareResponse,
    description: params.description,
  );
  return sdk.receivePayment(req: req);
});

// --- Send Payment Flow (Refactored) ---

final prepareSendProvider = FutureProvider.family<PrepareSendResponse, String>((ref, invoice) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = PrepareSendRequest(destination: invoice);
  // This provider now simply returns the response. The StateProvider was removed.
  return sdk.prepareSendPayment(req: req);
});

// This provider now takes the 'prepareResponse' directly as a parameter.
final sendPaymentProvider = FutureProvider.family<SendPaymentResponse, PrepareSendResponse>((ref, prepareResponse) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = SendPaymentRequest(prepareResponse: prepareResponse);
  return sdk.sendPayment(req: req);
});


// --- LNURL-Pay Flow ---

final prepareLnurlPayProvider = FutureProvider.family<PrepareLnUrlPayResponse, ({LnUrlPayRequestData data, BigInt amount, String? comment, String? bip353Address})>((ref, params) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = PrepareLnUrlPayRequest(
    data: params.data,
    amount: PayAmount_Bitcoin(receiverAmountSat: params.amount),
    comment: params.comment,
    bip353Address: params.bip353Address,
  );
  return sdk.prepareLnurlPay(req: req);
});

final prepareDrainLnurlProvider = FutureProvider.family<PrepareLnUrlPayResponse, ({LnUrlPayRequestData data, String? comment, String? bip353Address})>((ref, params) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = PrepareLnUrlPayRequest(
    data: params.data,
    amount: PayAmount_Drain(),
    comment: params.comment,
    bip353Address: params.bip353Address,
  );
  return sdk.prepareLnurlPay(req: req);
});

final lnurlPayProvider = FutureProvider.family<LnUrlPayResult, PrepareLnUrlPayResponse>((ref, prepareResponse) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = LnUrlPayRequest(prepareResponse: prepareResponse);
  return sdk.lnurlPay(req: req);
});

// --- Other Providers ---

final listLightningPaymentsProvider = FutureProvider.family.autoDispose<List<Payment>, ListPaymentsRequest>((ref, req) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final allPayments = await sdk.listPayments(req: req);
  return allPayments.where((p) => p.details is PaymentDetails_Lightning).toList();
});

final paymentProvider = FutureProvider.family<Payment?, GetPaymentRequest>((ref, req) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  return sdk.getPayment(req: req);
});

final listRefundablesProvider = FutureProvider<List<RefundableSwap>>((ref) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  return sdk.listRefundables();
});

final recommendedFeesProvider = FutureProvider<RecommendedFees>((ref) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  return sdk.recommendedFees();
});

final prepareRefundProvider =
FutureProvider.family<PrepareRefundResponse, ({String swapAddress, String refundAddress, int feeRateSatPerVbyte})>((ref, params) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = PrepareRefundRequest(
    swapAddress: params.swapAddress,
    refundAddress: params.refundAddress,
    feeRateSatPerVbyte: params.feeRateSatPerVbyte,
  );
  return sdk.prepareRefund(req: req);
});

final refundProvider = FutureProvider.family<RefundResponse, ({String swapAddress, String refundAddress, int feeRateSatPerVbyte})>((ref, params) async {
  final sdk = await ref.watch(breezSDKInstanceProvider.future);
  final req = RefundRequest(
    swapAddress: params.swapAddress,
    refundAddress: params.refundAddress,
    feeRateSatPerVbyte: params.feeRateSatPerVbyte,
  );
  return sdk.refund(req: req);
});