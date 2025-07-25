import 'package:Satsails/models/breez/sdk_instance.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

Future<PrepareReceiveResponse> prepareReceivePaymentLightning() async {
  // ANCHOR: prepare-receive-payment-lightning
  // Fetch the Receive lightning limits
  LightningPaymentLimitsResponse currentLightningLimits =
      await breezSDKLiquid.instance!.fetchLightningLimits();
  print("Minimum amount: ${currentLightningLimits.receive.minSat} sats");
  print("Maximum amount: ${currentLightningLimits.receive.maxSat} sats");

  // Create an invoice and set the amount you wish the payer to send
  ReceiveAmount_Bitcoin optionalAmount = ReceiveAmount_Bitcoin(payerAmountSat: 5000 as BigInt);
  PrepareReceiveResponse prepareResponse = await breezSDKLiquid.instance!.prepareReceivePayment(
    req: PrepareReceiveRequest(
      paymentMethod: PaymentMethod.bolt11Invoice,
      amount: optionalAmount,
    ),
  );

  // If the fees are acceptable, continue to create the Receive Payment
  BigInt receiveFeesSat = prepareResponse.feesSat;
  print("Fees: $receiveFeesSat sats");
  // ANCHOR_END: prepare-receive-payment-lightning
  return prepareResponse;
}

Future<PrepareReceiveResponse> prepareReceivePaymentLightningBolt12() async {
  // ANCHOR: prepare-receive-payment-lightning-bolt12
  PrepareReceiveResponse prepareResponse = await breezSDKLiquid.instance!.prepareReceivePayment(
    req: PrepareReceiveRequest(paymentMethod: PaymentMethod.bolt12Offer),
  );

  // If the fees are acceptable, continue to create the Receive Payment
  BigInt minReceiveFeesSat = prepareResponse.feesSat;
  double? swapperFeerate = prepareResponse.swapperFeerate;
  print("Fees: $minReceiveFeesSat sats + $swapperFeerate% of the sent amount");
  // ANCHOR_END: prepare-receive-payment-lightning-bolt12
  return prepareResponse;
}

Future<ReceivePaymentResponse> receivePayment(PrepareReceiveResponse prepareResponse) async {
  // ANCHOR: receive-payment
  String optionalDescription = "<description>";
  ReceivePaymentResponse res = await breezSDKLiquid.instance!.receivePayment(
    req: ReceivePaymentRequest(
      description: optionalDescription,
      prepareResponse: prepareResponse,
    ),
  );

  String destination = res.destination;
  // ANCHOR_END: receive-payment
  print(destination);
  return res;
}
