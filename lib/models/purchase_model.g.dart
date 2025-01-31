// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseAdapter extends TypeAdapter<Purchase> {
  @override
  final int typeId = 28;

  @override
  Purchase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Purchase(
      id: fields[0] as int,
      transferId: fields[1] as String,
      originalAmount: fields[3] as double,
      failed: fields[8] as bool,
      completedTransfer: fields[6] as bool,
      userId: fields[12] as int?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      receivedAmount: fields[15] as double,
      pixKey: fields[16] as String,
      paymentGateway: fields[17] as String?,
      status: fields[18] as String?,
      paymentMethod: fields[19] as String?,
      assetPurchased: fields[20] as String?,
      currencyOfPayment: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Purchase obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transferId)
      ..writeByte(3)
      ..write(obj.originalAmount)
      ..writeByte(6)
      ..write(obj.completedTransfer)
      ..writeByte(8)
      ..write(obj.failed)
      ..writeByte(12)
      ..write(obj.userId)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.receivedAmount)
      ..writeByte(16)
      ..write(obj.pixKey)
      ..writeByte(17)
      ..write(obj.paymentGateway)
      ..writeByte(18)
      ..write(obj.status)
      ..writeByte(19)
      ..write(obj.paymentMethod)
      ..writeByte(20)
      ..write(obj.assetPurchased)
      ..writeByte(21)
      ..write(obj.currencyOfPayment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
