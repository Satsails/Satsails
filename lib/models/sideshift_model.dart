import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Satsails/handlers/response_handlers.dart';

part 'sideshift_model.g.dart';

/// Parameters for setting a refund address for a shift
class RefundAddressParams {
  final String shiftId;
  final String refundAddress;

  RefundAddressParams({required this.shiftId, required this.refundAddress});
}

/// Enum defining supported cryptocurrency shift pairs
enum ShiftPair {
  usdtTronToLiquidUsdt,
  usdtBscToLiquidUsdt,
  usdtEthToLiquidUsdt,
  usdtSolToLiquidUsdt,
  usdtPolygonToLiquidUsdt,
  usdcEthToLiquidUsdt,
  usdcTronToLiquidUsdt,
  usdcBscToLiquidUsdt,
  usdcSolToLiquidUsdt,
  usdcPolygonToLiquidUsdt,
  usdcAvaxToLiquidUsdt,
  ethToLiquidBtc,
  trxToLiquidBtc,
  bnbToLiquidBtc,
  solToLiquidBtc,
  liquidUsdtToUsdtTron,
  liquidUsdtToUsdtBsc,
  liquidUsdtToUsdtEth,
  liquidUsdtToUsdtSol,
  liquidUsdtToUsdtPolygon,
  liquidUsdtToUsdcEth,
  liquidUsdtToUsdcTron,
  liquidUsdtToUsdcBsc,
  liquidUsdtToUsdcSol,
  liquidUsdtToUsdcPolygon,
  usdtPolygonToBtc,
  usdtPolygonToLiquidBtc,
  usdtSolanaToBtc,
  usdtSolanaToLiquidBtc,
  usdcAvaxToBtc,
  usdcAvaxToLiquidBtc,
}

/// Mapping of ShiftPair enum to ShiftParams
final shiftParamsMap = {
  ShiftPair.usdtTronToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'tron',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdtBscToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'bsc',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdtEthToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'ethereum',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdtSolToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'solana',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdtPolygonToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'polygon',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcEthToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'ethereum',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcTronToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'tron',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcBscToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'bsc',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcSolToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'solana',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcPolygonToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'polygon',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcAvaxToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'avax',
    settleNetwork: 'liquid',
  ),
  ShiftPair.ethToLiquidBtc: ShiftParams(
    depositCoin: 'ETH',
    settleCoin: 'BTC',
    depositNetwork: 'ethereum',
    settleNetwork: 'liquid',
  ),
  ShiftPair.trxToLiquidBtc: ShiftParams(
    depositCoin: 'TRX',
    settleCoin: 'BTC',
    depositNetwork: 'tron',
    settleNetwork: 'liquid',
  ),
  ShiftPair.bnbToLiquidBtc: ShiftParams(
    depositCoin: 'BNB',
    settleCoin: 'BTC',
    depositNetwork: 'bsc',
    settleNetwork: 'liquid',
  ),
  ShiftPair.solToLiquidBtc: ShiftParams(
    depositCoin: 'SOL',
    settleCoin: 'BTC',
    depositNetwork: 'solana',
    settleNetwork: 'liquid',
  ),
  ShiftPair.liquidUsdtToUsdtTron: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'liquid',
    settleNetwork: 'tron',
  ),
  ShiftPair.liquidUsdtToUsdtBsc: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'liquid',
    settleNetwork: 'bsc',
  ),
  ShiftPair.liquidUsdtToUsdtEth: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'liquid',
    settleNetwork: 'ethereum',
  ),
  ShiftPair.liquidUsdtToUsdtSol: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'liquid',
    settleNetwork: 'solana',
  ),
  ShiftPair.liquidUsdtToUsdtPolygon: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'liquid',
    settleNetwork: 'polygon',
  ),
  ShiftPair.liquidUsdtToUsdcEth: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDC',
    depositNetwork: 'liquid',
    settleNetwork: 'ethereum',
  ),
  ShiftPair.liquidUsdtToUsdcTron: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDC',
    depositNetwork: 'liquid',
    settleNetwork: 'tron',
  ),
  ShiftPair.liquidUsdtToUsdcBsc: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDC',
    depositNetwork: 'liquid',
    settleNetwork: 'bsc',
  ),
  ShiftPair.liquidUsdtToUsdcSol: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDC',
    depositNetwork: 'liquid',
    settleNetwork: 'solana',
  ),
  ShiftPair.liquidUsdtToUsdcPolygon: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDC',
    depositNetwork: 'liquid',
    settleNetwork: 'polygon',
  ),
  ShiftPair.usdtPolygonToBtc: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'BTC',
    depositNetwork: 'polygon',
    settleNetwork: 'bitcoin',
  ),
  ShiftPair.usdtPolygonToLiquidBtc: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'BTC',
    depositNetwork: 'polygon',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdtSolanaToBtc: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'BTC',
    depositNetwork: 'solana',
    settleNetwork: 'bitcoin',
  ),
  ShiftPair.usdtSolanaToLiquidBtc: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'BTC',
    depositNetwork: 'solana',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcAvaxToBtc: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'BTC',
    depositNetwork: 'avax',
    settleNetwork: 'bitcoin',
  ),
  ShiftPair.usdcAvaxToLiquidBtc: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'BTC',
    depositNetwork: 'avax',
    settleNetwork: 'liquid',
  ),
};

/// Parameters for a shift, including deposit and settle coin/network
class ShiftParams {
  final String depositCoin;
  final String settleCoin;
  final String depositNetwork;
  final String settleNetwork;

  ShiftParams({
    required this.depositCoin,
    required this.settleCoin,
    required this.depositNetwork,
    required this.settleNetwork,
  });
}

/// State notifier for managing a list of SideShift objects
class SideShiftShiftsNotifier extends StateNotifier<List<SideShift>> {
  SideShiftShiftsNotifier() : super([]) {
    _loadShifts();
  }

  /// Retrieves a shift by its ID
  SideShift getShiftById(String id) {
    return state.firstWhere((shift) => shift.id == id, orElse: () => throw 'Shift not found');
  }

  /// Loads shifts from Hive and sets up a listener for updates
  Future<void> _loadShifts() async {
    final box = await Hive.openBox<SideShift>('sideShiftShifts');
    box.watch().listen((event) => _updateShifts());
    _updateShifts();
  }

  /// Updates the state with sorted shifts from Hive
  void _updateShifts() {
    final box = Hive.box<SideShift>('sideShiftShifts');
    final shifts = box.values.toList();
    shifts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = shifts;
  }

  /// Adds a new shift to Hive
  Future<void> addShift(SideShift shift) async {
    final box = Hive.box<SideShift>('sideShiftShifts');
    await box.put(shift.id, shift);
    _updateShifts();
  }

  /// Updates an existing shift in Hive
  Future<void> updateShift(SideShift updatedShift) async {
    final box = Hive.box<SideShift>('sideShiftShifts');
    await box.put(updatedShift.id, updatedShift);
    _updateShifts();
  }

  /// Deletes a shift from Hive by ID
  Future<void> deleteShift(String id) async {
    final box = Hive.box<SideShift>('sideShiftShifts');
    await box.delete(id);
    _updateShifts();
  }

  /// Merges a single shift from server data into local storage
  Future<void> mergeShift(SideShift serverData) async {
    final box = Hive.box<SideShift>('sideShiftShifts');
    final existingShift = box.get(serverData.id);

    if (existingShift == null) {
      await box.put(serverData.id, serverData);
      _updateShifts();
      return;
    }

    final updatedShift = existingShift.copyWith(
      depositCoin: serverData.depositCoin ?? existingShift.depositCoin,
      depositNetwork: serverData.depositNetwork ?? existingShift.depositNetwork,
      settleCoin: serverData.settleCoin ?? existingShift.settleCoin,
      settleNetwork: serverData.settleNetwork ?? existingShift.settleNetwork,
      depositAddress: serverData.depositAddress ?? existingShift.depositAddress,
      depositMemo: serverData.depositMemo ?? existingShift.depositMemo,
      depositAmount: serverData.depositAmount ?? existingShift.depositAmount,
      settleAmount: serverData.settleAmount ?? existingShift.settleAmount,
      status: serverData.status ?? existingShift.status,
      timestamp: serverData.timestamp ?? existingShift.timestamp,
      settleAddress: serverData.settleAddress ?? existingShift.settleAddress,
      depositMin: serverData.depositMin ?? existingShift.depositMin,
      depositMax: serverData.depositMax ?? existingShift.depositMax,
      type: serverData.type ?? existingShift.type,
      expiresAt: serverData.expiresAt ?? existingShift.expiresAt,
      averageShiftSeconds: serverData.averageShiftSeconds ?? existingShift.averageShiftSeconds,
      settleCoinNetworkFee: serverData.settleCoinNetworkFee ?? existingShift.settleCoinNetworkFee,
      networkFeeUsd: serverData.networkFeeUsd ?? existingShift.networkFeeUsd,
      settleMemo: serverData.settleMemo ?? existingShift.settleMemo,
      refundAddress: serverData.refundAddress ?? existingShift.refundAddress,
      refundMemo: serverData.refundMemo ?? existingShift.refundMemo,
    );

    if (existingShift == updatedShift) {
      return;
    }

    await box.put(serverData.id, updatedShift);
    _updateShifts();
  }

  /// Merges multiple shifts from server data into local storage
  Future<void> mergeShifts(List<SideShift> serverDatas) async {
    final box = Hive.box<SideShift>('sideShiftShifts');

    for (final serverData in serverDatas) {
      final existingShift = box.get(serverData.id);

      final updatedShift = existingShift?.copyWith(
        depositCoin: serverData.depositCoin ?? existingShift.depositCoin,
        depositNetwork: serverData.depositNetwork ?? existingShift.depositNetwork,
        settleCoin: serverData.settleCoin ?? existingShift.settleCoin,
        settleNetwork: serverData.settleNetwork ?? existingShift.settleNetwork,
        depositAddress: serverData.depositAddress ?? existingShift.depositAddress,
        depositMemo: serverData.depositMemo ?? existingShift.depositMemo,
        depositAmount: serverData.depositAmount ?? existingShift.depositAmount,
        settleAmount: serverData.settleAmount ?? existingShift.settleAmount,
        status: serverData.status ?? existingShift.status,
        timestamp: serverData.timestamp ?? existingShift.timestamp,
        settleAddress: serverData.settleAddress ?? existingShift.settleAddress,
        depositMin: serverData.depositMin ?? existingShift.depositMin,
        depositMax: serverData.depositMax ?? existingShift.depositMax,
        type: serverData.type ?? existingShift.type,
        expiresAt: serverData.expiresAt ?? existingShift.expiresAt,
        averageShiftSeconds: serverData.averageShiftSeconds ?? existingShift.averageShiftSeconds,
        settleCoinNetworkFee: serverData.settleCoinNetworkFee ?? existingShift.settleCoinNetworkFee,
        networkFeeUsd: serverData.networkFeeUsd ?? existingShift.networkFeeUsd,
        settleMemo: serverData.settleMemo ?? existingShift.settleMemo,
        refundAddress: serverData.refundAddress ?? existingShift.refundAddress,
        refundMemo: serverData.refundMemo ?? existingShift.refundMemo,
      ) ?? serverData;

      if (existingShift == null || existingShift != updatedShift) {
        await box.put(serverData.id, updatedShift);
      }
    }

    _updateShifts();
  }
}

/// Request object for creating a shift
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

  /// Converts the request to JSON
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

  /// Factory constructors for common shift requests
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

  factory SideShiftShiftRequest.liquidUsdtToUsdt({
    required String settleAddress,
    required String refundAddress,
    required String settleNetwork,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDT',
      depositNetwork: 'liquid',
      settleNetwork: settleNetwork,
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.liquidUsdtToUsdc({
    required String settleAddress,
    required String refundAddress,
    required String settleNetwork,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDC',
      depositNetwork: 'liquid',
      settleNetwork: settleNetwork,
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.liquidUsdtToUsdtBsc({
    required String settleAddress,
    required String refundAddress,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDT',
      depositNetwork: 'liquid',
      settleNetwork: 'bsc',
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.liquidUsdtToUsdtEth({
    required String settleAddress,
    required String refundAddress,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDT',
      depositNetwork: 'liquid',
      settleNetwork: 'ethereum',
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.liquidUsdtToUsdtSol({
    required String settleAddress,
    required String refundAddress,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDT',
      depositNetwork: 'liquid',
      settleNetwork: 'solana',
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.liquidUsdtToUsdtPolygon({
    required String settleAddress,
    required String refundAddress,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDT',
      depositNetwork: 'liquid',
      settleNetwork: 'polygon',
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.liquidUsdtToUsdcEth({
    required String settleAddress,
    required String refundAddress,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDC',
      depositNetwork: 'liquid',
      settleNetwork: 'ethereum',
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.liquidUsdtToUsdcTron({
    required String settleAddress,
    required String refundAddress,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'USDC',
      depositNetwork: 'liquid',
      settleNetwork: 'tron',
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.usdtToBtc({
    required String settleAddress,
    required String refundAddress,
    required String depositNetwork,
    required String settleNetwork,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDT',
      settleCoin: 'BTC',
      depositNetwork: depositNetwork,
      settleNetwork: settleNetwork,
      affiliateId: affiliateId,
    );
  }

  factory SideShiftShiftRequest.usdcToBtc({
    required String settleAddress,
    required String refundAddress,
    required String depositNetwork,
    required String settleNetwork,
    required String affiliateId,
  }) {
    return SideShiftShiftRequest(
      settleAddress: settleAddress,
      refundAddress: refundAddress,
      depositCoin: 'USDC',
      settleCoin: 'BTC',
      depositNetwork: depositNetwork,
      settleNetwork: settleNetwork,
      affiliateId: affiliateId,
    );
  }
}

/// Model representing a SideShift shift, annotated for Hive storage
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
  @HiveField(22)
  final String shiftFee;

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
    required this.shiftFee,
  });

  /// Creates a SideShift instance from JSON data
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
      shiftFee: json['shiftFee']?.toString() ?? '0',
    );
  }

  /// Creates a copy of the SideShift instance with updated fields
  SideShift copyWith({
    String? id,
    String? depositCoin,
    String? depositNetwork,
    String? settleCoin,
    String? settleNetwork,
    String? depositAddress,
    String? depositMemo,
    String? depositAmount,
    String? settleAmount,
    String? status,
    int? timestamp,
    String? settleAddress,
    String? depositMin,
    String? depositMax,
    String? type,
    String? expiresAt,
    String? averageShiftSeconds,
    String? settleCoinNetworkFee,
    String? networkFeeUsd,
    String? settleMemo,
    String? refundAddress,
    String? refundMemo,
    String? shiftFee,
  }) {
    return SideShift(
      id: id ?? this.id,
      depositCoin: depositCoin ?? this.depositCoin,
      depositNetwork: depositNetwork ?? this.depositNetwork,
      settleCoin: settleCoin ?? this.settleCoin,
      settleNetwork: settleNetwork ?? this.settleNetwork,
      depositAddress: depositAddress ?? this.depositAddress,
      depositMemo: depositMemo ?? this.depositMemo,
      depositAmount: depositAmount ?? this.depositAmount,
      settleAmount: settleAmount ?? this.settleAmount,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      settleAddress: settleAddress ?? this.settleAddress,
      depositMin: depositMin ?? this.depositMin,
      depositMax: depositMax ?? this.depositMax,
      type: type ?? this.type,
      expiresAt: expiresAt ?? this.expiresAt,
      averageShiftSeconds: averageShiftSeconds ?? this.averageShiftSeconds,
      settleCoinNetworkFee: settleCoinNetworkFee ?? this.settleCoinNetworkFee,
      networkFeeUsd: networkFeeUsd ?? this.networkFeeUsd,
      settleMemo: settleMemo ?? this.settleMemo,
      refundAddress: refundAddress ?? this.refundAddress,
      refundMemo: refundMemo ?? this.refundMemo,
      shiftFee: shiftFee ?? this.shiftFee,
    );
  }
}

/// Service class for interacting with the SideShift API
class SideShiftService {
  /// Creates a new shift
  static Future<Result<SideShift>> createShift(SideShiftShiftRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('https://sideshift.ai/api/v2/shifts/variable'),
        body: jsonEncode(request.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        return Result(data: SideShift.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: '${jsonDecode(response.body)["error"]["message"]}');
      }
    } catch (e) {
      return Result(error: 'An error occurred. Please try again later');
    }
  }

  /// Retrieves shifts by their IDs
  static Future<Result<List<SideShift>>> getShiftsByIds(List<String> ids) async {
    try {
      final response = await http.get(
        Uri.parse('https://sideshift.ai/api/v2/shifts?ids=${ids.join(',')}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> shiftsJson = jsonDecode(response.body);
        final shifts = shiftsJson.map((json) => SideShift.fromJson(json)).toList();
        return Result(data: shifts);
      } else {
        return Result(error: 'Failed to retrieve shifts');
      }
    } catch (e) {
      return Result(error: 'An error occurred. Please try again later');
    }
  }

  /// Sets a refund address for a shift
  static Future<Result<SideShift>> setRefundAddress(String shiftId, String refundAddress) async {
    try {
      final response = await http.post(
        Uri.parse('https://sideshift.ai/api/v2/shifts/$shiftId/set-refund-address'),
        body: jsonEncode({'address': refundAddress}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        return Result(data: SideShift.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: 'Failed to set refund address');
      }
    } catch (e) {
      return Result(error: 'An error occurred. Please try again later');
    }
  }

  /// Fetches a quote for a shift
  static Future<Result<SideShiftQuote>> getQuote(SideShiftQuoteRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('https://sideshift.ai/api/v2/quotes'),
        body: jsonEncode(request.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        return Result(data: SideShiftQuote.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: '${jsonDecode(response.body)["error"]["message"]}');
      }
    } catch (e) {
      return Result(error: 'An error occurred. Please try again later');
    }
  }
}

/// Represents a SideShift asset
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

/// Represents a pair of SideShift assets
class SideshiftAssetPair {
  final SideshiftAsset from;
  final SideshiftAsset to;

  SideshiftAssetPair({required this.from, required this.to});
}

/// Model representing a SideShift quote
class SideShiftQuote {
  final String id;
  final int createdAt;
  final String depositCoin;
  final String settleCoin;
  final String depositNetwork;
  final String settleNetwork;
  final int expiresAt;
  final String depositAmount;
  final String settleAmount;
  final String rate;
  final String affiliateId;

  SideShiftQuote({
    required this.id,
    required this.createdAt,
    required this.depositCoin,
    required this.settleCoin,
    required this.depositNetwork,
    required this.settleNetwork,
    required this.expiresAt,
    required this.depositAmount,
    required this.settleAmount,
    required this.rate,
    required this.affiliateId,
  });

  /// Creates a SideShiftQuote instance from JSON data
  factory SideShiftQuote.fromJson(Map<String, dynamic> json) {
    return SideShiftQuote(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).millisecondsSinceEpoch ~/ 1000,
      depositCoin: json['depositCoin'] as String,
      settleCoin: json['settleCoin'] as String,
      depositNetwork: json['depositNetwork'] as String,
      settleNetwork: json['settleNetwork'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String).millisecondsSinceEpoch ~/ 1000,
      depositAmount: json['depositAmount'] as String,
      settleAmount: json['settleAmount'] as String,
      rate: json['rate'] as String,
      affiliateId: json['affiliateId'] as String,
    );
  }
}

/// Request object for fetching a SideShift quote
class SideShiftQuoteRequest {
  final String depositCoin;
  final String depositNetwork;
  final String settleCoin;
  final String settleNetwork;
  final String? depositAmount;
  final String? settleAmount;
  final String affiliateId;

  SideShiftQuoteRequest({
    required this.depositCoin,
    required this.depositNetwork,
    required this.settleCoin,
    required this.settleNetwork,
    this.depositAmount,
    this.settleAmount,
    required this.affiliateId,
  });

  /// Converts the request to JSON
  Map<String, dynamic> toJson() => {
    'depositCoin': depositCoin,
    'depositNetwork': depositNetwork,
    'settleCoin': settleCoin,
    'settleNetwork': settleNetwork,
    if (depositAmount != null) 'depositAmount': depositAmount,
    if (settleAmount != null) 'settleAmount': settleAmount,
    'affiliateId': affiliateId,
  };
}