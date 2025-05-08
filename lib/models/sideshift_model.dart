import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Satsails/handlers/response_handlers.dart';

part 'sideshift_model.g.dart';

class SideShiftShiftRequest {
  final String settleAddress;
  final String? settleMemo;
  final String? refundAddress;
  final String? refundMemo;
  final String depositCoin;
  final String settleCoin;
  final String? depositNetwork;
  final String? settleNetwork;
  final String affiliateId;
  final String? externalId;

  SideShiftShiftRequest({
    required this.settleAddress,
    this.settleMemo,
    this.refundAddress,
    this.refundMemo,
    required this.depositCoin,
    required this.settleCoin,
    this.depositNetwork,
    this.settleNetwork,
    required this.affiliateId,
    this.externalId,
  });

  Map<String, dynamic> toJson() => {
    'settleAddress': settleAddress,
    if (settleMemo != null) 'settleMemo': settleMemo,
    if (refundAddress != null) 'refundAddress': refundAddress,
    if (refundMemo != null) 'refundMemo': refundMemo,
    'depositCoin': depositCoin,
    'settleCoin': settleCoin,
    if (depositNetwork != null) 'depositNetwork': depositNetwork,
    if (settleNetwork != null) 'settleNetwork': settleNetwork,
    'affiliateId': affiliateId,
    if (externalId != null) 'externalId': externalId,
  };

  factory SideShiftShiftRequest.usdtToLiquidUsdt({
    required String settleAddress,
    required String refundAddress,
    required String depositNetwork,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDT',
      depositNetwork: depositNetwork,
      settleNetwork: 'liquid',
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.usdcToLiquidUsdt({
    required String settleAddress,
    required String refundAddress,
    required String depositNetwork,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDC',
      settleCoin: 'USDT',
      depositNetwork: depositNetwork,
      settleNetwork: 'liquid',
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.majorCryptoToLiquidBtc({
    required String settleAddress,
    required String refundAddress,
    required String depositCoin,
    required String depositNetwork,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: depositCoin,
      settleCoin: 'BTC',
      depositNetwork: depositNetwork,
      settleNetwork: 'liquid',
      affiliateId: affiliateId,
    );
  }
}

@HiveType(typeId: 30)
class SideShift {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String depositCoin;
  @HiveField(2)
  final String depositNetwork;
  @HiveField(3)
  final String settleCoin;
  @HiveField(4)
  final String settleNetwork;
  @HiveField(5)
  final String depositAddress;
  @HiveField(6)
  final String? depositMemo;
  @HiveField(7)
  final String depositAmount;
  @HiveField(8)
  final String settleAmount;
  @HiveField(9)
  final String status;
  @HiveField(10)
  final int timestamp;
  @HiveField(11)
  final String settleAddress;
  @HiveField(12)
  final String depositMin;
  @HiveField(13)
  final String depositMax;
  @HiveField(14)
  final String type;
  @HiveField(15)
  final String expiresAt;
  @HiveField(16)
  final String averageShiftSeconds;
  @HiveField(17)
  final String settleCoinNetworkFee;
  @HiveField(18)
  final String networkFeeUsd;
  @HiveField(19)
  final String? settleMemo;
  @HiveField(20)
  final String refundAddress;
  @HiveField(21)
  final String? refundMemo;

  SideShift({
    required this.id,
    required this.depositCoin,
    required this.depositNetwork,
    required this.settleCoin,
    required this.settleNetwork,
    required this.depositAddress,
    this.depositMemo,
    required this.depositAmount,
    required this.settleAmount,
    required this.status,
    required this.timestamp,
    required this.settleAddress,
    required this.depositMin,
    required this.depositMax,
    required this.type,
    required this.expiresAt,
    required this.averageShiftSeconds,
    required this.settleCoinNetworkFee,
    required this.networkFeeUsd,
    this.settleMemo,
    required this.refundAddress,
    this.refundMemo,
  });

  factory SideShift.fromJson(Map<String, dynamic> json) {
    return SideShift(
      id: json['id'] as String,
      depositCoin: json['depositCoin'] as String,
      depositNetwork: json['depositNetwork'] as String,
      settleCoin: json['settleCoin'] as String,
      settleNetwork: json['settleNetwork'] as String,
      depositAddress: json['depositAddress'] as String,
      depositMemo: json['depositMemo'] as String?,
      depositAmount: json['depositAmount']?.toString() ?? '0',
      settleAmount: json['settleAmount']?.toString() ?? '0',
      status: json['status'] as String,
      timestamp: DateTime.parse(json['createdAt'] as String).millisecondsSinceEpoch ~/ 1000,
      settleAddress: json['settleAddress'] as String,
      depositMin: json['depositMin']?.toString() ?? '0',
      depositMax: json['depositMax']?.toString() ?? '0',
      type: json['type'] as String,
      expiresAt: json['expiresAt'] as String,
      averageShiftSeconds: json['averageShiftSeconds']?.toString() ?? '0',
      settleCoinNetworkFee: json['settleCoinNetworkFee']?.toString() ?? '0',
      networkFeeUsd: json['networkFeeUsd']?.toString() ?? '0',
      settleMemo: json['settleMemo'] as String?,
      refundAddress: json['refundAddress'] as String? ?? '',
      refundMemo: json['refundMemo'] as String?,
    );
  }
}

class SideShiftService {
  static Future<Result<SideShift>> createShift(SideShiftShiftRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('https://sideshift.ai/api/v2/shifts/variable'),
        body: jsonEncode(request.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        return Result(data: SideShift.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: 'Failed to create shift: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'An error occurred. Please try again later');
    }
  }

  static Future<Result<List<SideShift>>> getShiftsByIds(List<String> ids) async {
    try {
      final response = await http.get(
        Uri.parse('https://sideshift.ai/api/v2/shifts?ids=${ids.join(',')}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> shiftsJson = jsonDecode(response.body);
        final shifts = shiftsJson.map((json) => SideShift.fromJson(json)).toList();
        return Result(data: shifts);
      } else {
        return Result(error: 'Failed to retrieve shifts: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'An error occurred. Please try again later');
    }
  }

  static Future<Result<void>> setRefundAddress(String shiftId, String refundAddress) async {
    try {
      final response = await http.post(
        Uri.parse('https://sideshift.ai/api/v2/shifts/$shiftId/set-refund-address'),
        body: jsonEncode({'refundAddress': refundAddress}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Result(data: null);
      } else {
        return Result(error: 'Failed to set refund address: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'An error occurred. Please try again later');
    }
  }
}

class SideshiftAsset {
  final String id;
  final String coin;
  final String network;
  final String name;

  SideshiftAsset({
    required this.id,
    required this.coin,
    required this.network,
    required this.name,
  });
}

class SideshiftAssetPair {
  final SideshiftAsset from;
  final SideshiftAsset to;

  SideshiftAssetPair({required this.from, required this.to});
}