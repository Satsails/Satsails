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
      preimage: fields[4] as PreImage,
      swapScript: fields[5] as LBtcSwapScriptStr,
      invoice: fields[6] as String,
      outAmount: fields[7] as int,
      scriptAddress: fields[8] as String,
      blindingKey: fields[9] as String,
      electrumUrl: fields[10] as String,
      boltzUrl: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExtendedLbtcLnV2Swap obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kind)
      ..writeByte(2)
      ..write(obj.network)
      ..writeByte(3)
      ..write(obj.keys)
      ..writeByte(4)
      ..write(obj.preimage)
      ..writeByte(5)
      ..write(obj.swapScript)
      ..writeByte(6)
      ..write(obj.invoice)
      ..writeByte(7)
      ..write(obj.outAmount)
      ..writeByte(8)
      ..write(obj.scriptAddress)
      ..writeByte(9)
      ..write(obj.blindingKey)
      ..writeByte(10)
      ..write(obj.electrumUrl)
      ..writeByte(11)
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
    );
  }

  @override
  void write(BinaryWriter writer, LbtcBoltz obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.swap)
      ..writeByte(1)
      ..write(obj.keys)
      ..writeByte(2)
      ..write(obj.preimage)
      ..writeByte(3)
      ..write(obj.swapScript)
      ..writeByte(4)
      ..write(obj.timestamp);
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

class BtcSwapScriptV2StrAdapterAdapter
    extends TypeAdapter<BtcSwapScriptV2StrAdapter> {
  @override
  final int typeId = 24;

  @override
  BtcSwapScriptV2StrAdapter read(BinaryReader reader) {
    return BtcSwapScriptV2StrAdapter();
  }

  @override
  void write(BinaryWriter writer, BtcSwapScriptV2StrAdapter obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BtcSwapScriptV2StrAdapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExtendedBtcLnV2SwapAdapter extends TypeAdapter<ExtendedBtcLnV2Swap> {
  @override
  final int typeId = 23;

  @override
  ExtendedBtcLnV2Swap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtendedBtcLnV2Swap(
      id: fields[0] as String,
      kind: fields[1] as SwapType,
      network: fields[2] as Chain,
      keys: fields[3] as KeyPair,
      preimage: fields[4] as PreImage,
      swapScript: fields[5] as BtcSwapScriptStr,
      invoice: fields[6] as String,
      outAmount: fields[7] as int,
      scriptAddress: fields[8] as String,
      electrumUrl: fields[9] as String,
      boltzUrl: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExtendedBtcLnV2Swap obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kind)
      ..writeByte(2)
      ..write(obj.network)
      ..writeByte(3)
      ..write(obj.keys)
      ..writeByte(4)
      ..write(obj.preimage)
      ..writeByte(5)
      ..write(obj.swapScript)
      ..writeByte(6)
      ..write(obj.invoice)
      ..writeByte(7)
      ..write(obj.outAmount)
      ..writeByte(8)
      ..write(obj.scriptAddress)
      ..writeByte(9)
      ..write(obj.electrumUrl)
      ..writeByte(10)
      ..write(obj.boltzUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtendedBtcLnV2SwapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BtcBoltzAdapter extends TypeAdapter<BtcBoltz> {
  @override
  final int typeId = 22;

  @override
  BtcBoltz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BtcBoltz(
      swap: fields[0] as ExtendedBtcLnV2Swap,
      keys: fields[1] as KeyPair,
      preimage: fields[2] as PreImage,
      swapScript: fields[3] as BtcSwapScriptStr,
      timestamp: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BtcBoltz obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.swap)
      ..writeByte(1)
      ..write(obj.keys)
      ..writeByte(2)
      ..write(obj.preimage)
      ..writeByte(3)
      ..write(obj.swapScript)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BtcBoltzAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
