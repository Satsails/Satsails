import 'dart:async';

import 'package:breez_liquid/breez_liquid.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as liquid_sdk;
import 'package:rxdart/rxdart.dart';

class BreezSDKLiquid {
  static final BreezSDKLiquid _singleton = BreezSDKLiquid._internal();

  factory BreezSDKLiquid() => _singleton;

  BreezSDKLiquid._internal() {
    initializeLogStream();
  }

  liquid_sdk.BindingLiquidSdk? _instance;

  liquid_sdk.BindingLiquidSdk? get instance => _instance;

  Future<void> connect({
    required liquid_sdk.ConnectRequest req,
  }) async {
    try {
      _instance = await liquid_sdk.connect(req: req);
      _initializeEventsStream(_instance!);
      _subscribeToSdkStreams(_instance!);
      await _fetchWalletData(_instance!);
    } catch (e) {
      _instance = null;
      rethrow;
    }
  }

  void disconnect() {
    if (_instance == null) {
      throw Exception();
    }

    _instance!.disconnect();
    _unsubscribeFromSdkStreams();
    _instance = null;
  }

  Future<void> _fetchWalletData(liquid_sdk.BindingLiquidSdk sdk) async {
    await _getInfo(sdk);
    await _listPayments(sdk: sdk);
  }

  Future<liquid_sdk.GetInfoResponse> _getInfo(liquid_sdk.BindingLiquidSdk sdk) async {
    final walletInfo = await sdk.getInfo();
    _walletInfoController.add(walletInfo);
    return walletInfo;
  }

  Future<List<liquid_sdk.Payment>> _listPayments({
    required liquid_sdk.BindingLiquidSdk sdk,
  }) async {
    const req = liquid_sdk.ListPaymentsRequest();
    final paymentsList = await sdk.listPayments(req: req);
    _paymentsController.add(paymentsList);
    return paymentsList;
  }

  StreamSubscription<liquid_sdk.LogEntry>? _breezLogSubscription;

  Stream<liquid_sdk.LogEntry>? _breezLogStream;

  /// Initializes SDK log stream.
  ///
  /// Call once on your Dart entrypoint file, e.g.; `lib/main.dart`.
  void initializeLogStream() {
    _breezLogStream ??= liquid_sdk.breezLogStream().asBroadcastStream();
  }

  StreamSubscription<liquid_sdk.SdkEvent>? _breezEventsSubscription;

  Stream<liquid_sdk.SdkEvent>? _breezEventsStream;

  void _initializeEventsStream(liquid_sdk.BindingLiquidSdk sdk) {
    _breezEventsStream ??= sdk.addEventListener().asBroadcastStream();
  }

  /// Subscribes to SDK's event & log streams.
  void _subscribeToSdkStreams(liquid_sdk.BindingLiquidSdk sdk) {
    _subscribeToEventsStream(sdk);
    _subscribeToLogStream();
  }

  final StreamController<liquid_sdk.GetInfoResponse> _walletInfoController =
      BehaviorSubject<liquid_sdk.GetInfoResponse>();

  Stream<liquid_sdk.GetInfoResponse> get walletInfoStream => _walletInfoController.stream;

  final StreamController<liquid_sdk.Payment> _paymentResultStream = StreamController.broadcast();

  final StreamController<List<liquid_sdk.Payment>> _paymentsController =
      BehaviorSubject<List<liquid_sdk.Payment>>();

  Stream<List<liquid_sdk.Payment>> get paymentsStream => _paymentsController.stream;

  Stream<liquid_sdk.Payment> get paymentResultStream => _paymentResultStream.stream;

  /* TODO: Liquid - Log statements are added for debugging purposes, should be removed after early development stage is complete & events are behaving as expected.*/
  /// Subscribes to SdkEvent's stream
  void _subscribeToEventsStream(liquid_sdk.BindingLiquidSdk sdk) {
    _breezEventsSubscription = _breezEventsStream?.listen(
      (event) async {
        if (event is liquid_sdk.SdkEvent_PaymentFailed) {
          _logStreamController.add(
            liquid_sdk.LogEntry(line: "Payment Failed. ${event.details.destination}", level: "WARN"),
          );
          _paymentResultStream.addError(PaymentException(event.details));
        }
        if (event is liquid_sdk.SdkEvent_PaymentPending) {
          _logStreamController.add(
            liquid_sdk.LogEntry(line: "Payment Pending. ${event.details.destination}", level: "INFO"),
          );
          _paymentResultStream.add(event.details);
        }
        if (event is liquid_sdk.SdkEvent_PaymentRefunded) {
          _logStreamController.add(
            liquid_sdk.LogEntry(line: "Payment Refunded. ${event.details.destination}", level: "INFO"),
          );
          _paymentResultStream.add(event.details);
        }
        if (event is liquid_sdk.SdkEvent_PaymentRefundPending) {
          _logStreamController.add(
            liquid_sdk.LogEntry(line: "Pending Payment Refund. ${event.details.destination}", level: "INFO"),
          );
          _paymentResultStream.add(event.details);
        }
        if (event is liquid_sdk.SdkEvent_PaymentSucceeded) {
          _logStreamController.add(
            liquid_sdk.LogEntry(line: "Payment Succeeded. ${event.details.destination}", level: "INFO"),
          );
          _paymentResultStream.add(event.details);
        }
        if (event is liquid_sdk.SdkEvent_PaymentWaitingConfirmation) {
          _logStreamController.add(
            liquid_sdk.LogEntry(
                line: "Payment Waiting Confirmation. ${event.details.destination}", level: "INFO"),
          );
          _paymentResultStream.add(event.details);
        }
        if (event is liquid_sdk.SdkEvent_Synced) {
          _logStreamController.add(const liquid_sdk.LogEntry(line: "Received Synced event.", level: "INFO"));
        }
        await _fetchWalletData(sdk);
      },
    );
  }

  final _logStreamController = StreamController<liquid_sdk.LogEntry>.broadcast();

  Stream<liquid_sdk.LogEntry> get logStream => _logStreamController.stream;

  /// Subscribes to SDK's logs stream
  void _subscribeToLogStream() {
    _breezLogSubscription = _breezLogStream?.listen((logEntry) {
      _logStreamController.add(logEntry);
    }, onError: (e) {
      _logStreamController.addError(e);
    });
  }

  /// Unsubscribes from SDK's event & log streams.
  void _unsubscribeFromSdkStreams() {
    _breezEventsSubscription?.cancel();
    _breezLogSubscription?.cancel();
  }
}

// TODO: Liquid - Return this exception from the SDK directly
class PaymentException {
  final liquid_sdk.Payment details;

  const PaymentException(this.details);
}

extension ConfigCopyWith on liquid_sdk.Config {
  liquid_sdk.Config copyWith({
    BlockchainExplorer? liquidExplorer,
    BlockchainExplorer? bitcoinExplorer,
    String? mempoolspaceUrl,
    String? workingDir,
    liquid_sdk.LiquidNetwork? network,
    BigInt? paymentTimeoutSec,
    int? zeroConfMinFeeRateMsat,
    String? syncServiceUrl,
    List<liquid_sdk.ExternalInputParser>? externalInputParsers,
    bool? useDefaultExternalInputParsers,
    List<liquid_sdk.AssetMetadata>? assetMetadata,
    String? breezApiKey,
  }) {
    return liquid_sdk.Config(
      liquidExplorer: liquidExplorer ?? this.liquidExplorer,
      bitcoinExplorer: bitcoinExplorer ?? this.bitcoinExplorer,
      workingDir: workingDir ?? this.workingDir,
      network: network ?? this.network,
      paymentTimeoutSec: paymentTimeoutSec ?? this.paymentTimeoutSec,
      syncServiceUrl: syncServiceUrl ?? this.syncServiceUrl,
      useDefaultExternalInputParsers: useDefaultExternalInputParsers ?? this.useDefaultExternalInputParsers,
      externalInputParsers: externalInputParsers ?? this.externalInputParsers,
      assetMetadata: assetMetadata ?? this.assetMetadata,
      breezApiKey: breezApiKey ?? this.breezApiKey,
    );
  }
}

BreezSDKLiquid breezSDKLiquid = BreezSDKLiquid();
