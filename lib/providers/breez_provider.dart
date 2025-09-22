import 'package:Satsails/models/breez/error.dart';
import 'package:Satsails/models/breez/lnurl_model.dart';
import 'package:Satsails/models/breez/lnurl_service.dart';
import 'package:Satsails/models/breez/lnurl_webhook_manager.dart';
import 'package:Satsails/models/breez/username_utilities.dart';
import 'package:Satsails/notifications/firebase.dart';
import 'package:Satsails/providers/breez_config_provider.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A data class to hold the unified response from preparing any lightning payment.
class PrepareLightningPaymentResponse {
  final dynamic prepareResponse;
  final int networkFee;

  PrepareLightningPaymentResponse({
    required this.prepareResponse,
    required this.networkFee,
  });
}

/// A new provider that abstracts the entire lightning payment process.
/// It handles parsing, preparing, and sending payments for BOLT11, BOLT12, and LNURL-Pay.
final sendLightningPaymentProvider = FutureProvider.autoDispose.family<void,
    ({String address, int amount, String? comment, bool isDraining})>((ref, params) async {
  try {
    final sdk = await ref.watch(breezSDKProvider.future);
    final parsedInput = await sdk.instance!.parse(input: params.address);

    dynamic prepareResponse;

    // Prepare the payment based on the input type
    if (parsedInput is InputType_Bolt11) {
      prepareResponse = await sdk.instance!.prepareSendPayment(req: PrepareSendRequest(destination: parsedInput.invoice.bolt11));
    } else if (parsedInput is InputType_Bolt12Offer) {
      final req = PrepareSendRequest(
        destination: parsedInput.offer.offer,
        amount: params.amount > 0 ? PayAmount_Bitcoin(receiverAmountSat: BigInt.from(params.amount)) : null,
      );
      prepareResponse = await sdk.instance!.prepareSendPayment(req: req);
    } else if (parsedInput is InputType_LnUrlPay) {
      final lnurlPayData = parsedInput.data;
      if (params.isDraining) {
        prepareResponse = await sdk.instance!.prepareLnurlPay(
          req: PrepareLnUrlPayRequest(
            data: lnurlPayData,
            amount: PayAmount_Drain(),
            comment: params.comment,
            bip353Address: parsedInput.bip353Address,
          ),
        );
      } else {
        if (params.amount == 0) throw 'Please enter an amount for this recipient';
        prepareResponse = await sdk.instance!.prepareLnurlPay(
          req: PrepareLnUrlPayRequest(
            data: lnurlPayData,
            amount: PayAmount_Bitcoin(receiverAmountSat: BigInt.from(params.amount)),
            comment: params.comment,
            bip353Address: parsedInput.bip353Address,
          ),
        );
      }
    } else {
      throw "Unsupported address or invoice type";
    }

    // Execute the payment
    if (prepareResponse is PrepareSendResponse) {
      await sdk.instance!.sendPayment(req: SendPaymentRequest(prepareResponse: prepareResponse));
    } else if (prepareResponse is PrepareLnUrlPayResponse) {
      await sdk.instance!.lnurlPay(req: LnUrlPayRequest(prepareResponse: prepareResponse));
    }
  } catch (e) {
    throw formatBreezError(e);
  }
});

/// This provider now only prepares the payment and returns a unified response.
/// The actual sending is handled by `sendLightningPaymentProvider`.
final prepareLightningPaymentProvider = FutureProvider.autoDispose.family<PrepareLightningPaymentResponse,
    ({String address, int amount, String? comment, bool isDraining})>((ref, params) async {
  try {
    final sdk = await ref.watch(breezSDKProvider.future);
    final parsedInput = await sdk.instance!.parse(input: params.address);

    dynamic prepareResponse;
    int networkFee = 0;

    if (parsedInput is InputType_Bolt11) {
      prepareResponse = await sdk.instance!.prepareSendPayment(req: PrepareSendRequest(destination: parsedInput.invoice.bolt11));
      networkFee = prepareResponse.feesSat.toInt();
    } else if (parsedInput is InputType_Bolt12Offer) {
      final req = PrepareSendRequest(
        destination: parsedInput.offer.offer,
        amount: params.amount > 0 ? PayAmount_Bitcoin(receiverAmountSat: BigInt.from(params.amount)) : null,
      );
      prepareResponse = await sdk.instance!.prepareSendPayment(req: req);
      networkFee = prepareResponse.feesSat.toInt();
    } else if (parsedInput is InputType_LnUrlPay) {
      final lnurlPayData = parsedInput.data;
      if (params.isDraining) {
        prepareResponse = await sdk.instance!.prepareLnurlPay(
          req: PrepareLnUrlPayRequest(
            data: lnurlPayData,
            amount: PayAmount_Drain(),
            comment: params.comment,
            bip353Address: parsedInput.bip353Address,
          ),
        );
      } else {
        if (params.amount == 0) throw 'Please enter an amount for this recipient';
        prepareResponse = await sdk.instance!.prepareLnurlPay(
          req: PrepareLnUrlPayRequest(
            data: lnurlPayData,
            amount: PayAmount_Bitcoin(receiverAmountSat: BigInt.from(params.amount)),
            comment: params.comment,
            bip353Address: parsedInput.bip353Address,
          ),
        );
      }
      networkFee = prepareResponse.feesSat.toInt();
    } else {
      throw "Unsupported address or invoice type";
    }

    return PrepareLightningPaymentResponse(prepareResponse: prepareResponse, networkFee: networkFee);
  } catch (e) {
    throw formatBreezError(e);
  }
});


final lightningLimitsProvider = FutureProvider<LightningPaymentLimitsResponse>((ref) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  return await sdk.instance!.fetchLightningLimits();
});

final prepareReceiveProvider = FutureProvider.family<PrepareReceiveResponse, BigInt>((ref, amountSat) async {
  try {
    final sdk = await ref.watch(breezSDKProvider.future);
    final req = PrepareReceiveRequest(
      paymentMethod: PaymentMethod.bolt11Invoice,
      amount: ReceiveAmount_Bitcoin(payerAmountSat: amountSat),
    );
    return await sdk.instance!.prepareReceivePayment(req: req);
  } catch (e) {
    throw formatBreezError(e);
  }
});

final prepareReceiveResponseProvider = StateProvider<PrepareReceiveResponse?>((ref) => null);

final receivePaymentProvider = FutureProvider.family<ReceivePaymentResponse, String?>((ref, description) async {
  try {
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
  } catch (e) {
    throw formatBreezError(e);
  }
});

final receiveBolt12PaymentProvider =
FutureProvider.family<ReceivePaymentResponse, String?>((ref, description) async {
  try {
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
  } catch (e) {
    throw formatBreezError(e);
  }
});

final parseInputProvider = FutureProvider.family<InputType, String>((ref, input) async {
  final sdk = await ref.watch(breezSDKProvider.future);
  try {
    return await sdk.instance!.parse(input: input);
  } catch (e) {
    throw formatBreezError(e);
  }
});

final prepareSendResponseProvider = StateProvider<PrepareSendResponse?>((ref) => null);

final prepareSendProvider = FutureProvider.family<PrepareSendResponse, String>((ref, invoice) async {
  try {
    final sdk = await ref.watch(breezSDKProvider.future);
    final req = PrepareSendRequest(destination: invoice);

    final prepareResponse = await sdk.instance!.prepareSendPayment(req: req);

    ref.read(prepareSendResponseProvider.notifier).state = prepareResponse;

    return prepareResponse;
  } catch (e) {
    throw formatBreezError(e);
  }
});

final sendPaymentProvider = FutureProvider<SendPaymentResponse>((ref) async {
  try {
    final sdk = await ref.watch(breezSDKProvider.future);
    final prepareResponse = ref.watch(prepareSendResponseProvider);

    if (prepareResponse == null) {
      throw Exception("Payment has not been prepared. Cannot send payment.");
    }

    final req = SendPaymentRequest(prepareResponse: prepareResponse);
    return await sdk.instance!.sendPayment(req: req);
  } catch (e) {
    throw formatBreezError(e);
  }
});

final prepareLnurlPayProvider = FutureProvider.family<PrepareLnUrlPayResponse, ({LnUrlPayRequestData data, BigInt amount, String? comment, String? bip353Address})>((ref, params) async {
  try {
    final sdk = await ref.watch(breezSDKProvider.future);
    final req = PrepareLnUrlPayRequest(
      data: params.data,
      amount: PayAmount_Bitcoin(receiverAmountSat: params.amount),
      comment: params.comment,
      bip353Address: params.bip353Address,
    );
    return await sdk.instance!.prepareLnurlPay(req: req);
  } catch (e) {
    throw formatBreezError(e);
  }
});

final prepareDrainLnurlProvider = FutureProvider.family<PrepareLnUrlPayResponse, ({LnUrlPayRequestData data, String? comment, String? bip353Address})>((ref, params) async {
  try {
    final sdk = await ref.watch(breezSDKProvider.future);
    final req = PrepareLnUrlPayRequest(
      data: params.data,
      amount: PayAmount_Drain(),
      comment: params.comment,
      bip353Address: params.bip353Address,
    );
    return await sdk.instance!.prepareLnurlPay(req: req);
  } catch (e) {
    throw formatBreezError(e);
  }
});

final lnurlPayProvider = FutureProvider.family<LnUrlPayResult, PrepareLnUrlPayResponse>((ref, prepareResponse) async {
  try {
    final sdk = await ref.watch(breezSDKProvider.future);
    final req = LnUrlPayRequest(prepareResponse: prepareResponse);
    return await sdk.instance!.lnurlPay(req: req);
  } catch (e) {
    throw formatBreezError(e);
  }
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

final breezPreferencesProvider = Provider((ref) => BreezPreferences());
final messageSignerProvider = Provider((ref) => BreezMessageSigner(ref));
final webhookServiceProvider = Provider((ref) => WebhookService(ref));
final lnurlPayServiceProvider = Provider((ref) => LnUrlPayService());
final usernameResolverProvider = Provider((ref) => UsernameResolver(ref.watch(breezPreferencesProvider)));
final webhookRequestBuilderProvider = Provider((ref) => WebhookRequestBuilder(ref.watch(messageSignerProvider)));

final lnurlRegistrationManagerProvider = Provider((ref) {
  return LnUrlRegistrationManager(
    lnAddressService: ref.watch(lnurlPayServiceProvider),
    breezPreferences: ref.watch(breezPreferencesProvider),
    requestBuilder: ref.watch(webhookRequestBuilderProvider),
    usernameResolver: ref.watch(usernameResolverProvider),
    webhookService: ref.watch(webhookServiceProvider),
  );
});

final lnAddressProvider = StateNotifierProvider<LnAddressNotifier, AsyncValue<String?>>((ref) {
  return LnAddressNotifier(ref.watch(breezPreferencesProvider));
});

class LnAddressNotifier extends StateNotifier<AsyncValue<String?>> {
  final BreezPreferences _preferences;
  LnAddressNotifier(this._preferences) : super(const AsyncValue.loading()) {
    _loadInitialAddress();
  }

  Future<void> _loadInitialAddress() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _preferences.getLnAddress());
  }

  Future<void> updateLnAddress(String? address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _preferences.setLnAddress(address);
      return address;
    });
  }
}

final createOrEditLnurlProvider = FutureProvider.family<Lnurl, String?>((ref, username) async {
  final manager = ref.watch(lnurlRegistrationManagerProvider);
  final sdk = await ref.watch(breezSDKProvider.future);
  final pubkey = (await sdk.instance!.getInfo()).walletInfo.pubkey;

  final webhookUrl = await manager.setupWebhook(pubkey, forceRefresh: true);

  String? offer;
  try {
    const prepareReq = PrepareReceiveRequest(paymentMethod: PaymentMethod.bolt12Offer);
    final prepareRes = await sdk.instance!.prepareReceivePayment(req: prepareReq);
    final receiveReq = ReceivePaymentRequest(prepareResponse: prepareRes);
    final receiveRes = await sdk.instance!.receivePayment(req: receiveReq);
    offer = receiveRes.destination;
  } on Exception catch (e) {
  }

  final result = await manager.performRegistration(
    pubKey: pubkey,
    webhookUrl: webhookUrl,
    registrationType: RegistrationType.newRegistration,
    baseUsername: username,
    offer: offer,
  );

  if (result.lightningAddress != null) {
    await ref.read(lnAddressProvider.notifier).updateLnAddress(result.lightningAddress);
  }
  return result;
});


final recoverLnurlProvider = FutureProvider<Lnurl>((ref) async {
  final manager = ref.watch(lnurlRegistrationManagerProvider);
  final sdk = await ref.watch(breezSDKProvider.future);
  final pubkey = (await sdk.instance!.getInfo()).walletInfo.pubkey;

  final webhookUrl = await manager.setupWebhook(pubkey, forceRefresh: true);

  final result = await manager.performRegistration(
    pubKey: pubkey,
    webhookUrl: webhookUrl,
    registrationType: RegistrationType.recovery,
  );

  if (result.lightningAddress != null) {
    await ref.read(lnAddressProvider.notifier).updateLnAddress(result.lightningAddress);
  }
  return result;
});


final setupLnAddressProvider = FutureProvider.autoDispose<Lnurl>((ref) async {
  final bool allowed = await FirebaseService.checkNotificationPermissionStatus();

  if (!allowed) {
    throw NotificationPermissionException(
      "Notification permissions are required to set up a Lightning Address.",
    );
  }


  final preferences = ref.read(breezPreferencesProvider);
  final sdk = await ref.watch(breezSDKProvider.future);
  final pubkey = (await sdk.instance!.getInfo()).walletInfo.pubkey;

  final isRegistered = await preferences.isLnUrlWebhookRegistered();

  if (isRegistered) {
    final manager = ref.watch(lnurlRegistrationManagerProvider);
    await manager.setupWebhook(pubkey);

    final username = await preferences.getLnAddressUsername();
    final domain = ref.read(lnurlPayServiceProvider).getDomain();
    return Lnurl(
      pubkey: pubkey,
      username: username,
      lightningAddress: (username != null && domain != null) ? '$username@$domain' : null,
      registeredAt: DateTime.now(),
    );
  } else {
    try {
      print("No LNURL registered. Attempting to recover...");
      return await ref.watch(recoverLnurlProvider.future);
    } on WebhookNotFoundException {
      print("Recovery failed. Creating a new random LNURL address...");
      return await ref.watch(createOrEditLnurlProvider(null).future);
    } catch (e) {
      throw Exception("Initial setup failed: ${e.toString()}");
    }
  }
});
