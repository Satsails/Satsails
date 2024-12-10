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
      cpf: fields[2] as String,
      sentAmount: fields[3] as double,
      originalAmount: fields[4] as double,
      mintFees: fields[5] as double,
      processingStatus: fields[8] as bool,
      failed: fields[9] as bool,
      paymentId: fields[6] as String,
      completedTransfer: fields[7] as bool,
      receivedTxid: fields[11] as String,
      sentToHotWallet: fields[10] as bool,
      sentTxid: fields[12] as String?,
      receipt: fields[13] as String?,
      userId: fields[14] as int?,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      receivedAmount: fields[17] as double,
      pixKey: fields[18] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Purchase obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transferId)
      ..writeByte(2)
      ..write(obj.cpf)
      ..writeByte(3)
      ..write(obj.sentAmount)
      ..writeByte(4)
      ..write(obj.originalAmount)
      ..writeByte(5)
      ..write(obj.mintFees)
      ..writeByte(6)
      ..write(obj.paymentId)
      ..writeByte(7)
      ..write(obj.completedTransfer)
      ..writeByte(8)
      ..write(obj.processingStatus)
      ..writeByte(9)
      ..write(obj.failed)
      ..writeByte(10)
      ..write(obj.sentToHotWallet)
      ..writeByte(11)
      ..write(obj.receivedTxid)
      ..writeByte(12)
      ..write(obj.sentTxid)
      ..writeByte(13)
      ..write(obj.receipt)
      ..writeByte(14)
      ..write(obj.userId)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.receivedAmount)
      ..writeByte(18)
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
