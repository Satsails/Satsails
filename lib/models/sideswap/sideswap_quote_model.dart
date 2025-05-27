import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Utxo class (unchanged)
class Utxo {
  final String txid;
  final int vout;
  final String asset;
  final int value;
  final String assetBf;
  final String valueBf;
  final String? redeemScript;

  Utxo({
    required this.txid,
    required this.vout,
    required this.asset,
    required this.value,
    required this.assetBf,
    required this.valueBf,
    this.redeemScript,
  });

  Map<String, dynamic> toJson() {
    return {
      'txid': txid,
      'vout': vout,
      'asset': asset,
      'value': value,
      'asset_bf': assetBf,
      'value_bf': valueBf,
      if (redeemScript != null) 'redeem_script': redeemScript,
    };
  }
}

// QuoteRequest class (unchanged)
class QuoteRequest {
  final String baseAsset;
  final String quoteAsset;
  final String assetType;
  final String tradeDir;
  final int amount;
  final String receiveAddress;
  final String changeAddress;
  final List<Utxo> utxos;

  QuoteRequest({
    required this.baseAsset,
    required this.quoteAsset,
    required this.assetType,
    required this.tradeDir,
    required this.amount,
    required this.receiveAddress,
    required this.changeAddress,
    required this.utxos,
  });

  QuoteRequest.empty()
      : baseAsset = '',
        quoteAsset = '',
        assetType = '',
        tradeDir = '',
        amount = 0,
        receiveAddress = '',
        changeAddress = '',
        utxos = [];
}

class SideswapQuote {
  final int quoteSubId;
  final String baseAsset;
  final String quoteAsset;
  final String assetType;
  final String tradeDir;
  final int amount;
  final String feeAsset;
  final String status;
  final int? baseAmount;
  final int? quoteAmount;
  final int? fixedFee;
  final int? serverFee;
  final int? quoteId;
  final int? ttl;
  final int? available;
  final String? errorMsg;
  final int? deliverAmount;
  final int? receiveAmount;

  SideswapQuote({
    required this.quoteSubId,
    required this.baseAsset,
    required this.quoteAsset,
    required this.assetType,
    required this.tradeDir,
    required this.amount,
    required this.feeAsset,
    required this.status,
    this.baseAmount,
    this.quoteAmount,
    this.fixedFee,
    this.serverFee,
    this.quoteId,
    this.ttl,
    this.available,
    this.errorMsg,
    this.deliverAmount,
    this.receiveAmount,
  });

  factory SideswapQuote.fromJson(Map<String, dynamic> json) {
    if (json['result']?['start_quotes'] != null) {
      final result = json['result']['start_quotes'];
      return SideswapQuote(
        quoteSubId: result['quote_sub_id'] ?? 0,
        baseAsset: '',
        quoteAsset: '',
        assetType: '',
        tradeDir: '',
        amount: 0,
        feeAsset: result['fee_asset'] ?? '',
        status: 'Initial',
        errorMsg: json['error']?['message'],
      );
    }

    final quote = json['params']?['quote'] ?? json;
    final statusData = quote['status'] ?? {};
    final success = statusData['Success'];
    final lowBalance = statusData['LowBalance'];
    final error = statusData['Error'];

    String status;
    int? baseAmount, quoteAmount, fixedFee, serverFee, quoteId, ttl, available;
    String? errorMsg;
    int? deliverAmount, receiveAmount;

    if (success != null) {
      status = 'Success';
      baseAmount = success['base_amount'];
      quoteAmount = success['quote_amount'];
      fixedFee = success['fixed_fee'];
      serverFee = success['server_fee'];
      quoteId = success['quote_id'];
      ttl = success['ttl'];

      final totalFee = (fixedFee ?? 0) + (serverFee ?? 0);


      if (quote['trade_dir'] == 'Sell' && quote['asset_type'] == 'Base') {
        deliverAmount = baseAmount! + totalFee;
        receiveAmount = quoteAmount;
      } else if (quote['trade_dir'] == 'Sell' && quote['asset_type'] == 'Quote') {
        deliverAmount = baseAmount;
        receiveAmount = quoteAmount! + totalFee;
      } else if (quote['trade_dir'] == 'Buy' && quote['asset_type'] == 'Base') {
        deliverAmount = quoteAmount;
        receiveAmount = baseAmount! + totalFee;
      } else if (quote['trade_dir'] == 'Buy' && quote['asset_type'] == 'Quote') {
        deliverAmount = quoteAmount! + totalFee;
        receiveAmount = baseAmount;
      }
    } else if (lowBalance != null) {
      status = 'LowBalance';
      available = lowBalance['available'];
      baseAmount = lowBalance['base_amount'];
      quoteAmount = lowBalance['quote_amount'];
      fixedFee = lowBalance['fixed_fee'];
      serverFee = lowBalance['server_fee'];
    } else {
      status = 'Error';
      errorMsg = error?['error_msg'] ?? json['error']?['message'];
    }

    return SideswapQuote(
      quoteSubId: quote['quote_sub_id'] ?? 0,
      baseAsset: quote['asset_pair']?['base'] ?? '',
      quoteAsset: quote['asset_pair']?['quote'] ?? '',
      assetType: quote['asset_type'] ?? '',
      tradeDir: quote['trade_dir'] ?? '',
      amount: quote['amount'] ?? 0,
      feeAsset: quote['fee_asset'] ?? '',
      status: status,
      baseAmount: baseAmount,
      quoteAmount: quoteAmount,
      fixedFee: fixedFee,
      serverFee: serverFee,
      quoteId: quoteId,
      ttl: ttl,
      available: available,
      errorMsg: errorMsg,
      deliverAmount: deliverAmount,
      receiveAmount: receiveAmount,
    );
  }
}

class SideswapQuoteModel extends StateNotifier<SideswapQuote> {
  SideswapQuoteModel(this.ref)
      : super(SideswapQuote(
    quoteSubId: 0,
    baseAsset: '',
    quoteAsset: '',
    assetType: '',
    tradeDir: '',
    amount: 0,
    feeAsset: '',
    status: 'Initial',
  )) {
    ref.listen<AsyncValue<SideswapQuote>>(
      sideswapQuoteStreamProvider,
          (previous, next) {
        next.when(
          data: (value) => state = value,
          loading: () {
            state = SideswapQuote(
              quoteSubId: 0,
              baseAsset: _request?.baseAsset ?? '',
              quoteAsset: _request?.quoteAsset ?? '',
              assetType: _request?.assetType ?? '',
              tradeDir: _request?.tradeDir ?? '',
              amount: _request?.amount ?? 0,
              feeAsset: '',
              status: 'Loading',
            );
          },
          error: (error, stackTrace) {
            state = SideswapQuote(
              quoteSubId: 0,
              baseAsset: _request?.baseAsset ?? '',
              quoteAsset: _request?.quoteAsset ?? '',
              assetType: _request?.assetType ?? '',
              tradeDir: _request?.tradeDir ?? '',
              amount: _request?.amount ?? 0,
              feeAsset: '',
              status: 'Error',
              errorMsg: error.toString(),
            );
          },
        );
      },
    );
  }

  final Ref ref;
  QuoteRequest? _request; // Store the QuoteRequest for use in state updates
}