// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eulen_transfer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EulenTransferAdapter extends TypeAdapter<EulenTransfer> {
  @override
  final typeId = 28;

  @override
  EulenTransfer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EulenTransfer(
      id: (fields[0] as num).toInt(),
      transactionId: fields[1] as String,
      originalAmount: (fields[2] as num).toDouble(),
      completed: fields[3] as bool,
      failed: fields[4] as bool,
      userId: (fields[5] as num?)?.toInt(),
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      receivedAmount: (fields[8] as num).toDouble(),
      pixKey: fields[9] == null ? '' : fields[9] as String,
      status: fields[10] == null ? 'unknown' : fields[10] as String?,
      paymentMethod: fields[11] == null ? 'unknown' : fields[11] as String?,
      to_currency: fields[12] == null ? 'unknown' : fields[12] as String?,
      from_currency: fields[13] == null ? 'unknown' : fields[13] as String?,
      transactionType: fields[14] == null ? 'BUY' : fields[14] as String?,
      provider: fields[15] == null ? 'Eulen' : fields[15] as String?,
      price: fields[16] == null ? 0.0 : (fields[16] as num?)?.toDouble(),
      cashback: fields[17] == null ? 0.0 : (fields[17] as num?)?.toDouble(),
      cashbackPayed: fields[18] == null ? false : fields[18] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, EulenTransfer obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transactionId)
      ..writeByte(2)
      ..write(obj.originalAmount)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.failed)
      ..writeByte(5)
      ..write(obj.userId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.receivedAmount)
      ..writeByte(9)
      ..write(obj.pixKey)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.paymentMethod)
      ..writeByte(12)
      ..write(obj.to_currency)
      ..writeByte(13)
      ..write(obj.from_currency)
      ..writeByte(14)
      ..write(obj.transactionType)
      ..writeByte(15)
      ..write(obj.provider)
      ..writeByte(16)
      ..write(obj.price)
      ..writeByte(17)
      ..write(obj.cashback)
      ..writeByte(18)
      ..write(obj.cashbackPayed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EulenTransferAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
