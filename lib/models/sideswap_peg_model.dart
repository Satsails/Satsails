import 'package:hive/hive.dart';
part 'sideswap_peg_model.g.dart';


@HiveType(typeId: 8)
class SideswapPeg extends HiveObject {
  @HiveField(0)
  final int? createdAt;
  @HiveField(1)
  final int? expiresAt;
  @HiveField(2)
  final String? orderId;
  @HiveField(3)
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

@HiveType(typeId: 9)
class SideswapPegStatus extends HiveObject {
  @HiveField(0)
  final String? orderId;
  @HiveField(1)
  final String? addr;
  @HiveField(2)
  final String? addrRecv;
  @HiveField(3)
  final int? createdAt;
  @HiveField(4)
  final int? expiresAt;
  @HiveField(5)
  final bool? pegIn;
  @HiveField(6)
  final List<SideswapPegStatusTransaction>? list;

  SideswapPegStatus({
    this.orderId,
    this.addr,
    this.addrRecv,
    this.createdAt,
    this.expiresAt,
    this.pegIn,
    this.list,
  });

  factory SideswapPegStatus.fromJson(Map<String, dynamic> json) {
    var result = json['result'];
    return SideswapPegStatus(
      orderId: result["order_id"],
      addr: result["addr"],
      addrRecv: result["addr_recv"],
      createdAt: result["created_at"],
      expiresAt: result["expires_at"],
      pegIn: result["peg_in"],
      list: (result["list"] as List).map((item) => SideswapPegStatusTransaction.fromJson(item)).toList(),
    );
  }
}

@HiveType(typeId: 10)
class SideswapPegStatusTransaction extends HiveObject {
  @HiveField(0)
  final int? amount;
  @HiveField(1)
  final int? createdAt;
  @HiveField(2)
  final dynamic detectedConfs;
  @HiveField(3)
  final dynamic payout;
  @HiveField(4)
  final String? payoutTxid;
  @HiveField(5)
  final String? status;
  @HiveField(6)
  final dynamic totalConfs;
  @HiveField(7)
  final String? txHash;
  @HiveField(8)
  final String? txState;
  @HiveField(9)
  final int? txStateCode;
  @HiveField(10)
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