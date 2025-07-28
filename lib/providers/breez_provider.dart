import 'package:Satsails/providers/breez_config_provider.dart';
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

final parseInputProvider = FutureProvider.family<InputType, String>((ref, input) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  try {
    return await sdk.instance!.parse(input: input);
  } catch (e) {
    throw Exception("Failed to parse input: $e");
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

final prepareLnurlPayProvider = FutureProvider.family<PrepareLnUrlPayResponse, ({LnUrlPayRequestData data, BigInt amount})>((ref, params) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = PrepareLnUrlPayRequest(
    data: params.data,
    amount: PayAmount_Bitcoin(receiverAmountSat: params.amount),
  );
  return await sdk.instance!.prepareLnurlPay(req: req);
});

final prepareDrainLnurlProvider = FutureProvider.family<PrepareLnUrlPayResponse, LnUrlPayRequestData>((ref, data) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = PrepareLnUrlPayRequest(
    data: data,
    amount: PayAmount_Drain(),
  );
  return await sdk.instance!.prepareLnurlPay(req: req);
});

final lnurlPayProvider = FutureProvider.family<LnUrlPayResult, PrepareLnUrlPayResponse>((ref, prepareResponse) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  final req = LnUrlPayRequest(prepareResponse: prepareResponse);
  return await sdk.instance!.lnurlPay(req: req);
});

final listLightningPaymentsProvider = FutureProvider.family<List<Payment>, ListPaymentsRequest>((ref, req) async {
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
  await sdk.instance!.rescanOnchainSwaps();
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
