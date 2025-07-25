import 'package:Satsails/models/breez/sdk_instance.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

Future<PrepareSendResponse> prepareSendPaymentLightningBolt11() async {
  // ANCHOR: prepare-send-payment-lightning-bolt11
  // Set the bolt11 invoice you wish to pay
  PrepareSendResponse prepareSendResponse = await breezSDKLiquid.instance!.prepareSendPayment(
    req: PrepareSendRequest(destination: "<bolt11 invoice>"),
  );

  // If the fees are acceptable, continue to create the Send Payment
  BigInt? sendFeesSat = prepareSendResponse.feesSat;
  print("Fees: $sendFeesSat sats");
  // ANCHOR_END: prepare-send-payment-lightning-bolt11
  return prepareSendResponse;
}

Future<PrepareSendResponse> prepareSendPaymentLightningBolt12() async {
  // ANCHOR: prepare-send-payment-lightning-bolt12
  // Set the bolt12 offer you wish to pay
  PayAmount_Bitcoin optionalAmount = PayAmount_Bitcoin(receiverAmountSat: 5000 as BigInt);
  PrepareSendResponse prepareSendResponse = await breezSDKLiquid.instance!.prepareSendPayment(
    req: PrepareSendRequest(
      destination: "<bolt12 offer>",
      amount: optionalAmount,
    ),
  );
  // ANCHOR_END: prepare-send-payment-lightning-bolt12
  return prepareSendResponse;
}

Future<PrepareSendResponse> prepareSendPaymentLiquid() async {
  // ANCHOR: prepare-send-payment-liquid
  // Set the Liquid BIP21 or Liquid address you wish to pay
  PayAmount_Bitcoin optionalAmount = PayAmount_Bitcoin(receiverAmountSat: 5000 as BigInt);
  PrepareSendRequest prepareSendRequest = PrepareSendRequest(
    destination: "<Liquid BIP21 or address>",
    amount: optionalAmount,
  );

  PrepareSendResponse prepareSendResponse = await breezSDKLiquid.instance!.prepareSendPayment(
    req: prepareSendRequest,
  );

  // If the fees are acceptable, continue to create the Send Payment
  BigInt? sendFeesSat = prepareSendResponse.feesSat;
  print("Fees: $sendFeesSat sats");
  // ANCHOR_END: prepare-send-payment-liquid
  return prepareSendResponse;
}

Future<PrepareSendResponse> prepareSendPaymentLiquidDrain() async {
  // ANCHOR: prepare-send-payment-liquid-drain
  // Set the Liquid BIP21 or Liquid address you wish to pay
  PayAmount_Drain optionalAmount = PayAmount_Drain();
  PrepareSendRequest prepareSendRequest = PrepareSendRequest(
    destination: "<Liquid BIP21 or address>",
    amount: optionalAmount,
  );

  PrepareSendResponse prepareSendResponse = await breezSDKLiquid.instance!.prepareSendPayment(
    req: prepareSendRequest,
  );

  // If the fees are acceptable, continue to create the Send Payment
  BigInt? sendFeesSat = prepareSendResponse.feesSat;
  print("Fees: $sendFeesSat sats");
  // ANCHOR_END: prepare-send-payment-liquid-drain
  return prepareSendResponse;
}

Future<SendPaymentResponse> sendPayment({required PrepareSendResponse prepareResponse}) async {
  // ANCHOR: send-payment
  String optionalPayerNote = "<payer note>";
  SendPaymentResponse sendPaymentResponse = await breezSDKLiquid.instance!.sendPayment(
    req: SendPaymentRequest(
      prepareResponse: prepareResponse,
      payerNote: optionalPayerNote,
    ),
  );
  Payment payment = sendPaymentResponse.payment;
  // ANCHOR_END: send-payment
  print(payment);
  return sendPaymentResponse;
}

Future<void> prepareLnurlPay() async {
  // ANCHOR: prepare-lnurl-pay
  /// Endpoint can also be of the form:
  /// lnurlp://domain.com/lnurl-pay?key=val
  /// lnurl1dp68gurn8ghj7mr0vdskc6r0wd6z7mrww4excttsv9un7um9wdekjmmw84jxywf5x43rvv35xgmr2enrxanr2cfcvsmnwe3jxcukvde48qukgdec89snwde3vfjxvepjxpjnjvtpxd3kvdnxx5crxwpjvyunsephsz36jf
  String lnurlPayUrl = "lightning@address.com";

  InputType inputType = await breezSDKLiquid.instance!.parse(input: lnurlPayUrl);
  if (inputType is InputType_LnUrlPay) {
    PayAmount_Bitcoin amount = PayAmount_Bitcoin(receiverAmountSat: 5000 as BigInt);
    String optionalComment = "<comment>";
    bool optionalValidateSuccessActionUrl = true;

    PrepareLnUrlPayRequest req = PrepareLnUrlPayRequest(
      data: inputType.data,
      amount: amount,
      bip353Address: inputType.bip353Address,
      comment: optionalComment,
      validateSuccessActionUrl: optionalValidateSuccessActionUrl,
    );
    PrepareLnUrlPayResponse prepareResponse = await breezSDKLiquid.instance!.prepareLnurlPay(req: req);

    // If the fees are acceptable, continue to create the LNURL Pay
    BigInt feesSat = prepareResponse.feesSat;
    print("Fees: $feesSat sats");
  }
  // ANCHOR_END: prepare-lnurl-pay
}

Future<void> prepareLnurlPayDrain({required LnUrlPayRequestData data}) async {
  // ANCHOR: prepare-lnurl-pay-drain
  PayAmount_Drain amount = PayAmount_Drain();
  String optionalComment = "<comment>";
  bool optionalValidateSuccessActionUrl = true;

  PrepareLnUrlPayRequest req = PrepareLnUrlPayRequest(
    data: data,
    amount: amount,
    comment: optionalComment,
    validateSuccessActionUrl: optionalValidateSuccessActionUrl,
  );
  PrepareLnUrlPayResponse prepareResponse = await breezSDKLiquid.instance!.prepareLnurlPay(req: req);
  // ANCHOR_END: prepare-lnurl-pay-drain
  print(prepareResponse);
}

Future<void> lnurlPay({required PrepareLnUrlPayResponse prepareResponse}) async {
  // ANCHOR: lnurl-pay
  LnUrlPayResult result = await breezSDKLiquid.instance!.lnurlPay(
    req: LnUrlPayRequest(prepareResponse: prepareResponse),
  );
  // ANCHOR_END: lnurl-pay
  print(result);
}
