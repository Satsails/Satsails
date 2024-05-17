import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideswapStatusModel extends StateNotifier<SideswapStatus> {
  SideswapStatusModel(super.state);

  void updateStatus(SideswapStatus newStatus) {
    state = newStatus;
  }
}

class SideswapStatus {
  List<dynamic>? bitcoinFeeRates;
  double elementsFeeRate;
  int minPegInAmount;
  int minPegOutAmount;
  int minSubmitAmount;
  int pegOutBitcoinTxVsize;
  String policyAsset;
  double priceBand;
  double serverFeePercentPegIn;
  double serverFeePercentPegOut;
  String uploadUrl;

  SideswapStatus({
    this.bitcoinFeeRates,
    this.elementsFeeRate = 0.000001,
    this.minPegInAmount = 10000,
    this.minPegOutAmount = 100000,
    this.minSubmitAmount = 2000,
    this.pegOutBitcoinTxVsize = 200,
    this.policyAsset = "6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d",
    this.priceBand = 0.101,
    this.serverFeePercentPegIn = 0.1,
    this.serverFeePercentPegOut = 0.1,
    this.uploadUrl = "https://api.sideswap.io/json-rpc",
  });

  factory SideswapStatus.fromJson(Map<String, dynamic> json) {
    var result = json['result'];
    return SideswapStatus(
      bitcoinFeeRates: result["bitcoin_fee_rates"],
      elementsFeeRate: result["elements_fee_rate"],
      minPegInAmount: result["min_peg_in_amount"],
      minPegOutAmount: result["min_peg_out_amount"],
      minSubmitAmount: result["min_submit_amount"],
      pegOutBitcoinTxVsize: result["peg_out_bitcoin_tx_vsize"],
      policyAsset: result["policy_asset"],
      priceBand: result["price_band"],
      serverFeePercentPegIn: result["server_fee_percent_peg_in"],
      serverFeePercentPegOut: result["server_fee_percent_peg_out"],
      uploadUrl: result["upload_url"],
    );
  }
}