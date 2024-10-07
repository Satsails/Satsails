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
      btcBalance: fields[0] as int,
      liquidBalance: fields[1] as int,
      usdBalance: fields[2] as int,
      eurBalance: fields[3] as int,
      brlBalance: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WalletBalance obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.btcBalance)
      ..writeByte(1)
      ..write(obj.liquidBalance)
      ..writeByte(2)
      ..write(obj.usdBalance)
      ..writeByte(3)
      ..write(obj.eurBalance)
      ..writeByte(4)
      ..write(obj.brlBalance);
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
