// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sideswap_peg_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SideswapPegAdapter extends TypeAdapter<SideswapPeg> {
  @override
  final int typeId = 8;

  @override
  SideswapPeg read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SideswapPeg(
      createdAt: fields[0] as int?,
      expiresAt: fields[1] as int?,
      orderId: fields[2] as String?,
      pegAddr: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SideswapPeg obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.expiresAt)
      ..writeByte(2)
      ..write(obj.orderId)
      ..writeByte(3)
      ..write(obj.pegAddr);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideswapPegAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SideswapPegStatusAdapter extends TypeAdapter<SideswapPegStatus> {
  @override
  final int typeId = 9;

  @override
  SideswapPegStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SideswapPegStatus(
      orderId: fields[0] as String?,
      addr: fields[1] as String?,
      addrRecv: fields[2] as String?,
      createdAt: fields[3] as int?,
      expiresAt: fields[4] as int?,
      pegIn: fields[5] as bool?,
      list: (fields[6] as List?)?.cast<SideswapPegStatusTransaction>(),
    );
  }

  @override
  void write(BinaryWriter writer, SideswapPegStatus obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.addr)
      ..writeByte(2)
      ..write(obj.addrRecv)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.expiresAt)
      ..writeByte(5)
      ..write(obj.pegIn)
      ..writeByte(6)
      ..write(obj.list);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideswapPegStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SideswapPegStatusTransactionAdapter
    extends TypeAdapter<SideswapPegStatusTransaction> {
  @override
  final int typeId = 10;

  @override
  SideswapPegStatusTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SideswapPegStatusTransaction(
      amount: fields[0] as int?,
      createdAt: fields[1] as int?,
      detectedConfs: fields[2] as dynamic,
      payout: fields[3] as dynamic,
      payoutTxid: fields[4] as String?,
      status: fields[5] as String?,
      totalConfs: fields[6] as dynamic,
      txHash: fields[7] as String?,
      txState: fields[8] as String?,
      txStateCode: fields[9] as int?,
      vout: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SideswapPegStatusTransaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.detectedConfs)
      ..writeByte(3)
      ..write(obj.payout)
      ..writeByte(4)
      ..write(obj.payoutTxid)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.totalConfs)
      ..writeByte(7)
      ..write(obj.txHash)
      ..writeByte(8)
      ..write(obj.txState)
      ..writeByte(9)
      ..write(obj.txStateCode)
      ..writeByte(10)
      ..write(obj.vout);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SideswapPegStatusTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
