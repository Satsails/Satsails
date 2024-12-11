// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coinos_ln_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoinosPaymentAdapter extends TypeAdapter<CoinosPayment> {
  @override
  final int typeId = 27;

  @override
  CoinosPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinosPayment(
      id: fields[0] as String?,
      hash: fields[1] as String?,
      amount: fields[2] as int?,
      uid: fields[3] as String?,
      rate: fields[4] as double?,
      currency: fields[5] as String?,
      memo: fields[6] as String?,
      ref: fields[7] as String?,
      tip: fields[8] as int?,
      type: fields[9] as String?,
      confirmed: fields[10] as bool?,
      created: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CoinosPayment obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.hash)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.uid)
      ..writeByte(4)
      ..write(obj.rate)
      ..writeByte(5)
      ..write(obj.currency)
      ..writeByte(6)
      ..write(obj.memo)
      ..writeByte(7)
      ..write(obj.ref)
      ..writeByte(8)
      ..write(obj.tip)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.confirmed)
      ..writeByte(11)
      ..write(obj.created);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinosPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
