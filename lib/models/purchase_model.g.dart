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
      sentAmount: fields[2] as double,
      originalAmount: fields[3] as double,
      mintFees: fields[4] as double,
      processingStatus: fields[7] as bool,
      failed: fields[8] as bool,
      paymentId: fields[5] as String,
      completedTransfer: fields[6] as bool,
      receivedTxid: fields[10] as String,
      sentToHotWallet: fields[9] as bool,
      sentTxid: fields[11] as String?,
      userId: fields[12] as int?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      receivedAmount: fields[15] as double,
      pixKey: fields[16] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Purchase obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transferId)
      ..writeByte(2)
      ..write(obj.sentAmount)
      ..writeByte(3)
      ..write(obj.originalAmount)
      ..writeByte(4)
      ..write(obj.mintFees)
      ..writeByte(5)
      ..write(obj.paymentId)
      ..writeByte(6)
      ..write(obj.completedTransfer)
      ..writeByte(7)
      ..write(obj.processingStatus)
      ..writeByte(8)
      ..write(obj.failed)
      ..writeByte(9)
      ..write(obj.sentToHotWallet)
      ..writeByte(10)
      ..write(obj.receivedTxid)
      ..writeByte(11)
      ..write(obj.sentTxid)
      ..writeByte(12)
      ..write(obj.userId)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.receivedAmount)
      ..writeByte(16)
      ..write(obj.pixKey);
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
