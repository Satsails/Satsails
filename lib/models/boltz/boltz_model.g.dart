// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boltz_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtendedKeyPairAdapter extends TypeAdapter<ExtendedKeyPair> {
  @override
  final int typeId = 12;

  @override
  ExtendedKeyPair read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtendedKeyPair(
      fields[0] as KeyPair,
    );
  }

  @override
  void write(BinaryWriter writer, ExtendedKeyPair obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.keyPair);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtendedKeyPairAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExtendedPreImageAdapter extends TypeAdapter<ExtendedPreImage> {
  @override
  final int typeId = 13;

  @override
  ExtendedPreImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtendedPreImage(
      fields[0] as PreImage,
    );
  }

  @override
  void write(BinaryWriter writer, ExtendedPreImage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.preImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtendedPreImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExtendedLBtcSwapScriptV2StrAdapter
    extends TypeAdapter<ExtendedLBtcSwapScriptV2Str> {
  @override
  final int typeId = 14;

  @override
  ExtendedLBtcSwapScriptV2Str read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtendedLBtcSwapScriptV2Str(
      fields[0] as LBtcSwapScriptV2Str,
    );
  }

  @override
  void write(BinaryWriter writer, ExtendedLBtcSwapScriptV2Str obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.swapScript);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtendedLBtcSwapScriptV2StrAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      swapScript: fields[5] as LBtcSwapScriptV2Str,
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

class BoltzAdapter extends TypeAdapter<Boltz> {
  @override
  final int typeId = 16;

  @override
  Boltz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Boltz(
      swap: fields[0] as ExtendedLbtcLnV2Swap,
      keys: fields[1] as ExtendedKeyPair,
      preimage: fields[2] as ExtendedPreImage,
      swapScript: fields[3] as ExtendedLBtcSwapScriptV2Str,
    );
  }

  @override
  void write(BinaryWriter writer, Boltz obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.swap)
      ..writeByte(1)
      ..write(obj.keys)
      ..writeByte(2)
      ..write(obj.preimage)
      ..writeByte(3)
      ..write(obj.swapScript);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoltzAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
