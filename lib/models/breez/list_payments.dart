import 'package:Satsails/models/breez/sdk_instance.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

Future<(Payment?, Payment?)> getPayment() async {
  // ANCHOR: get-payment
  String paymentHash = "<payment hash>";
  GetPaymentRequest reqByHash = GetPaymentRequest.paymentHash(paymentHash: paymentHash);
  Payment? paymentByHash = await breezSDKLiquid.instance!.getPayment(req: reqByHash);

  String swapId = "<swap id>";
  GetPaymentRequest reqBySwapId = GetPaymentRequest.swapId(swapId: swapId);
  Payment? paymentBySwapId = await breezSDKLiquid.instance!.getPayment(req: reqBySwapId);
  // ANCHOR_END: get-payment
  return (paymentByHash, paymentBySwapId);
}

Future<List<Payment>> listPayments() async {
  // ANCHOR: list-payments
  ListPaymentsRequest req = ListPaymentsRequest();
  List<Payment> paymentsList = await breezSDKLiquid.instance!.listPayments(req: req);
  // ANCHOR_END: list-payments
  return paymentsList;
}