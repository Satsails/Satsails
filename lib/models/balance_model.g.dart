// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletBalanceAdapter extends TypeAdapter<WalletBalance> {
  @override
  final int typeId = 26;

  @override
  WalletBalance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletBalance(
      onChainBtcBalance: fields[0] as int,
      liquidBtcBalance: fields[1] as int,
      liquidUsdtBalance: fields[2] as int,
      liquidEuroxBalance: fields[3] as int,
      liquidDepixBalance: fields[4] as int,
      sparkBitcoinbalance: fields[5] as int?,
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
