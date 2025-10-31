// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletBalanceAdapter extends TypeAdapter<WalletBalance> {
  @override
  final typeId = 26;

  @override
  WalletBalance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletBalance(
      onChainBtcBalance: (fields[0] as num).toInt(),
      liquidBtcBalance: (fields[1] as num).toInt(),
      liquidUsdtBalance: (fields[2] as num).toInt(),
      liquidEuroxBalance: (fields[3] as num).toInt(),
      liquidDepixBalance: (fields[4] as num).toInt(),
      sparkBitcoinbalance: (fields[5] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, WalletBalance obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.onChainBtcBalance)
      ..writeByte(1)
      ..write(obj.liquidBtcBalance)
      ..writeByte(2)
      ..write(obj.liquidUsdtBalance)
      ..writeByte(3)
      ..write(obj.liquidEuroxBalance)
      ..writeByte(4)
      ..write(obj.liquidDepixBalance)
      ..writeByte(5)
      ..write(obj.sparkBitcoinbalance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletBalanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
