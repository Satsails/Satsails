import 'package:flutter_riverpod/flutter_riverpod.dart';

// peg
class SideswapPegModel extends StateNotifier<SideswapPeg> {
  SideswapPegModel(super.state);
}

class SideswapPeg {
  final int? createdAt;
  final int? expiresAt;
  final String? orderId;
  final String? pegAddr;

  SideswapPeg({
    this.createdAt,
    this.expiresAt,
    this.orderId,
    this.pegAddr,
  });

  factory SideswapPeg.fromJson(Map<String, dynamic> json) {
    var result = json['result'];
    return SideswapPeg(
      createdAt: result["created_at"],
      expiresAt: result["expires_at"],
      orderId: result["order_id"],
      pegAddr: result["peg_addr"],
    );
  }
}

// check for status
class SideswapPegStatusModel extends StateNotifier<SideswapPegStatus> {
  SideswapPegStatusModel(super.state);
}


class SideswapPegStatus {
  final String? orderId;
  final String? pegAddr;
  final String? status;
  final List<SideswapPegStatusTransaction>? list;

  SideswapPegStatus({
    this.orderId,
    this.pegAddr,
    this.status,
    this.list,
  });

  factory SideswapPegStatus.fromJson(Map<String, dynamic> json) {
    var result = json['result'];
    return SideswapPegStatus(
      orderId: result["order_id"],
      pegAddr: result["peg_addr"],
      status: result["status"],
      list: (result["list"] as List).map((item) => SideswapPegStatusTransaction.fromJson(item)).toList(),
    );
  }
}

class SideswapPegStatusTransaction {
  final int? amount;
  final int? createdAt;
  final dynamic detectedConfs;
  final dynamic payout;
  final String? payoutTxid;
  final String? status;
  final dynamic totalConfs;
  final String? txHash;
  final String? txState;
  final int? txStateCode;
  final int? vout;

  SideswapPegStatusTransaction({
    this.amount,
    this.createdAt,
    this.detectedConfs,
    this.payout,
    this.payoutTxid,
    this.status,
    this.totalConfs,
    this.txHash,
    this.txState,
    this.txStateCode,
    this.vout,
  });

  factory SideswapPegStatusTransaction.fromJson(Map<String, dynamic> json) {
    return SideswapPegStatusTransaction(
      amount: json["amount"],
      createdAt: json["created_at"],
      detectedConfs: json["detected_confs"],
      payout: json["payout"],
      payoutTxid: json["payout_txid"],
      status: json["status"],
      totalConfs: json["total_confs"],
      txHash: json["tx_hash"],
      txState: json["tx_state"],
      txStateCode: json["tx_state_code"],
      vout: json["vout"],
    );
  }
}