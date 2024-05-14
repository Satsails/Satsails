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

class BoltzReceiveAdapter extends TypeAdapter<BoltzReceive> {
  @override
  final int typeId = 15;

  @override
  BoltzReceive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoltzReceive(
      keys: fields[1] as ExtendedKeyPair,
      preimage: fields[2] as ExtendedPreImage,
      swapScript: fields[3] as ExtendedLBtcSwapScriptV2Str,
    );
  }

  @override
  void write(BinaryWriter writer, BoltzReceive obj) {
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
      other is BoltzReceiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
