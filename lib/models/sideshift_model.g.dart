// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sideshift_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SideShiftAdapter extends TypeAdapter<SideShift> {
  @override
  final int typeId = 30;

  @override
  SideShift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SideShift(
      id: fields[0] as String,
      depositCoin: fields[1] as String,
      depositNetwork: fields[2] as String,
      settleCoin: fields[3] as String,
      settleNetwork: fields[4] as String,
      depositAddress: fields[5] as String,
      depositMemo: fields[6] as String?,
      depositAmount: fields[7] as String,
      settleAmount: fields[8] as String,
      status: fields[9] as String,
      timestamp: fields[10] as int,
      settleAddress: fields[11] as String,
      depositMin: fields[12] as String,
      depositMax: fields[13] as String,
      type: fields[14] as String,
      expiresAt: fields[15] as String,
      averageShiftSeconds: fields[16] as String,
      settleCoinNetworkFee: fields[17] as String,
      networkFeeUsd: fields[18] as String,
      settleMemo: fields[19] as String?,
      refundAddress: fields[20] as String,
      refundMemo: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SideShift obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.depositCoin)
      ..writeByte(2)
      ..write(obj.depositNetwork)
      ..writeByte(3)
      ..write(obj.settleCoin)
      ..writeByte(4)
      ..write(obj.settleNetwork)
      ..writeByte(5)
      ..write(obj.depositAddress)
      ..writeByte(6)
      ..write(obj.depositMemo)
      ..writeByte(7)
      ..write(obj.depositAmount)
      ..writeByte(8)
      ..write(obj.settleAmount)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.timestamp)
      ..writeByte(11)
      ..write(obj.settleAddress)
      ..writeByte(12)
      ..write(obj.depositMin)
      ..writeByte(13)
      ..write(obj.depositMax)
      ..writeByte(14)
      ..write(obj.type)
      ..writeByte(15)
      ..write(obj.expiresAt)
      ..writeByte(16)
      ..write(obj.averageShiftSeconds)
      ..writeByte(17)
      ..write(obj.settleCoinNetworkFee)
      ..writeByte(18)
      ..write(obj.networkFeeUsd)
      ..writeByte(19)
      ..write(obj.settleMemo)
      ..writeByte(20)
      ..write(obj.refundAddress)
      ..writeByte(21)
      ..write(obj.refundMemo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideShiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
