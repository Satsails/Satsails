// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boltz_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtendedLbtcLnV2SwapAdapter extends TypeAdapter<ExtendedLbtcLnV2Swap> {
  @override
  final int typeId = 15;

  @override
  ExtendedLbtcLnV2Swap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtendedLbtcLnV2Swap(
      id: fields[0] as String,
      kind: fields[1] as SwapType,
      network: fields[2] as Chain,
      keys: fields[3] as KeyPair,
      keyIndex: fields[4] as BigInt,
      preimage: fields[5] as PreImage,
      swapScript: fields[6] as LBtcSwapScriptStr,
      invoice: fields[7] as String,
      outAmount: fields[8] as int,
      scriptAddress: fields[9] as String,
      blindingKey: fields[10] as String,
      electrumUrl: fields[11] as String,
      boltzUrl: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExtendedLbtcLnV2Swap obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kind)
      ..writeByte(2)
      ..write(obj.network)
      ..writeByte(3)
      ..write(obj.keys)
      ..writeByte(4)
      ..write(obj.keyIndex)
      ..writeByte(5)
      ..write(obj.preimage)
      ..writeByte(6)
      ..write(obj.swapScript)
      ..writeByte(7)
      ..write(obj.invoice)
      ..writeByte(8)
      ..write(obj.outAmount)
      ..writeByte(9)
      ..write(obj.scriptAddress)
      ..writeByte(10)
      ..write(obj.blindingKey)
      ..writeByte(11)
      ..write(obj.electrumUrl)
      ..writeByte(12)
      ..write(obj.boltzUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtendedLbtcLnV2SwapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LbtcBoltzAdapter extends TypeAdapter<LbtcBoltz> {
  @override
  final int typeId = 16;

  @override
  LbtcBoltz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LbtcBoltz(
      swap: fields[0] as ExtendedLbtcLnV2Swap,
      keys: fields[1] as KeyPair,
      preimage: fields[2] as PreImage,
      swapScript: fields[3] as LBtcSwapScriptStr,
      timestamp: fields[4] as int,
      completed: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, LbtcBoltz obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.swap)
      ..writeByte(1)
      ..write(obj.keys)
      ..writeByte(2)
      ..write(obj.preimage)
      ..writeByte(3)
      ..write(obj.swapScript)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LbtcBoltzAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
