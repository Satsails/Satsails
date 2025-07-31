// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lnurl_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LnurlAdapter extends TypeAdapter<Lnurl> {
  @override
  final int typeId = 31;

  @override
  Lnurl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lnurl(
      pubkey: fields[0] as String,
      username: fields[1] as String?,
      webhookUrl: fields[2] as String?,
      offer: fields[3] as String?,
      registeredAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Lnurl obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.pubkey)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.webhookUrl)
      ..writeByte(3)
      ..write(obj.offer)
      ..writeByte(4)
      ..write(obj.registeredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LnurlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
