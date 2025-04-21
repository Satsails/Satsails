// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sideswap_exchange_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SideswapCompletedSwapAdapter extends TypeAdapter<SideswapCompletedSwap> {
  @override
  final int typeId = 11;

  @override
  SideswapCompletedSwap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SideswapCompletedSwap(
      txid: fields[0] as String,
      sendAsset: fields[1] as String,
      sendAmount: fields[2] as num,
      recvAsset: fields[3] as String,
      recvAmount: fields[4] as num,
      quoteId: fields[5] as int,
      timestamp: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SideswapCompletedSwap obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.txid)
      ..writeByte(1)
      ..write(obj.sendAsset)
      ..writeByte(2)
      ..write(obj.sendAmount)
      ..writeByte(3)
      ..write(obj.recvAsset)
      ..writeByte(4)
      ..write(obj.recvAmount)
      ..writeByte(5)
      ..write(obj.quoteId)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideswapCompletedSwapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
