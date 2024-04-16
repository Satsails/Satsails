import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:lwk_dart/lwk_dart.dart' as lwk;
import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class TransactionDetails {
  @HiveField(0)
  final String? serializedTx;

  @HiveField(1)
  final String txid;

  @HiveField(2)
  final int received;

  @HiveField(3)
  final int sent;

  @HiveField(4)
  final int? fee;

  @HiveField(5)
  final BlockTime? confirmationTime;

  const TransactionDetails({
    this.serializedTx,
    required this.txid,
    required this.received,
    required this.sent,
    this.fee,
    this.confirmationTime,
  });

  TransactionDetails.fromBdk(bdk.TransactionDetails bdkTransactionDetails)
      : serializedTx = bdkTransactionDetails.serializedTx,
        txid = bdkTransactionDetails.txid,
        received = bdkTransactionDetails.received,
        sent = bdkTransactionDetails.sent,
        fee = bdkTransactionDetails.fee,
        confirmationTime = bdkTransactionDetails.confirmationTime != null
            ? BlockTime.fromBdk(bdkTransactionDetails.confirmationTime!)
            : null;
}

@HiveType(typeId: 2)
class BlockTime {
  @HiveField(0)
  final int height;

  @HiveField(1)
  final int timestamp;

  const BlockTime({
    required this.height,
    required this.timestamp,
  });

  BlockTime.fromBdk(bdk.BlockTime bdkBlockTime)
      : height = bdkBlockTime.height,
        timestamp = bdkBlockTime.timestamp;
}

class TransactionDetailsAdapter extends TypeAdapter<TransactionDetails> {
  @override
  final int typeId = 1;

  @override
  TransactionDetails read(BinaryReader reader) {
    final serializedTx = reader.read();
    final txid = reader.read();
    final received = reader.read();
    final sent = reader.read();
    final fee = reader.read();
    final confirmationTime = BlockTimeAdapter().read(reader);

    return TransactionDetails(
      serializedTx: serializedTx,
      txid: txid,
      received: received,
      sent: sent,
      fee: fee,
      confirmationTime: confirmationTime,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionDetails obj) {
    writer.write(obj.serializedTx);
    writer.write(obj.txid);
    writer.write(obj.received);
    writer.write(obj.sent);
    writer.write(obj.fee);
    if (obj.confirmationTime != null) {
      BlockTimeAdapter().write(writer, obj.confirmationTime!);
    } else {
      writer.write(null);
    }
  }
}

class BlockTimeAdapter extends TypeAdapter<BlockTime> {
  @override
  final int typeId = 2;

  @override
  BlockTime read(BinaryReader reader) {
    final height = reader.read();
    final timestamp = reader.read();

    return BlockTime(
      height: height,
      timestamp: timestamp,
    );
  }

  @override
  void write(BinaryWriter writer, BlockTime obj) {
    writer.write(obj.height);
    writer.write(obj.timestamp);
  }
}

@HiveType(typeId: 3)

class Tx {
  @HiveField(0)
  final int timestamp;
  @HiveField(1)
  final String kind;
  @HiveField(2)
  final List<dynamic> balances;
  @HiveField(3)
  final String txid;
  @HiveField(4)
  final List<dynamic> outputs;
  @HiveField(5)
  final List<dynamic> inputs;
  @HiveField(6)
  final int fee;

  const Tx({
    required this.timestamp,
    required this.kind,
    required this.balances,
    required this.txid,
    required this.outputs,
    required this.inputs,
    required this.fee,
  });

  Tx.fromLwk(lwk.Tx lwkTx)
      : timestamp = lwkTx.timestamp,
        kind = lwkTx.kind,
        balances = lwkTx.balances.map((balance) => Balance.fromTuple(balance.assetId, balance.value)).toList(),
        txid = lwkTx.txid,
        outputs = lwkTx.outputs.map((txOut) => TxOut.fromLwk(txOut)).toList(),
        inputs = lwkTx.inputs.map((txOut) => TxOut.fromLwk(txOut)).toList(),
        fee = lwkTx.fee;
}

@HiveType(typeId: 4)
class TxOut {
  @HiveField(0)
  final String scriptPubkey;
  @HiveField(1)
  final OutPoint outpoint;
  @HiveField(2)
  final int? height;
  @HiveField(3)
  final TxOutSecrets unblinded;

  const TxOut({
    required this.scriptPubkey,
    required this.outpoint,
    this.height,
    required this.unblinded,
  });

  TxOut.fromLwk(lwk.TxOut lwkTxOut)
      : scriptPubkey = lwkTxOut.scriptPubkey,
        outpoint = OutPoint.fromLwk(lwkTxOut.outpoint),
        height = lwkTxOut.height,
        unblinded = TxOutSecrets.fromLwk(lwkTxOut.unblinded);
}

@HiveType(typeId: 5)
class TxOutSecrets {
  @HiveField(0)
  final int value;
  @HiveField(1)
  final String valueBf;
  @HiveField(2)
  final String asset;
  @HiveField(3)
  final String assetBf;

  const TxOutSecrets({
    required this.value,
    required this.valueBf,
    required this.asset,
    required this.assetBf,
  });

  TxOutSecrets.fromLwk(lwk.TxOutSecrets lwkTxOutSecrets)
      : value = lwkTxOutSecrets.value,
        valueBf = lwkTxOutSecrets.valueBf,
        asset = lwkTxOutSecrets.asset,
        assetBf = lwkTxOutSecrets.assetBf;
}

@HiveType(typeId: 6)
class OutPoint {
  @HiveField(0)
  final String txid;
  @HiveField(1)
  final int vout;

  const OutPoint({
    required this.txid,
    required this.vout,
  });

  OutPoint.fromLwk(lwk.OutPoint lwkOutPoint)
      : txid = lwkOutPoint.txid,
        vout = lwkOutPoint.vout;
}

class TxAdapter extends TypeAdapter<Tx> {
  @override
  final int typeId = 3;

  @override
  Tx read(BinaryReader reader) {
    final timestamp = reader.read();
    final kind = reader.read();
    final balances = reader.read();
    final txid = reader.read();
    final outputs = reader.read();
    final inputs = reader.read();
    final fee = reader.read();

    return Tx(
      timestamp: timestamp,
      kind: kind,
      balances: balances,
      txid: txid,
      outputs: outputs,
      inputs: inputs,
      fee: fee,
    );
  }

  @override
  void write(BinaryWriter writer, Tx obj) {
    writer.write(obj.timestamp);
    writer.write(obj.kind);
    writer.write(obj.balances);
    writer.write(obj.txid);
    writer.write(obj.outputs);
    writer.write(obj.inputs);
    writer.write(obj.fee);
  }
}

class TxOutAdapter extends TypeAdapter<TxOut> {
  @override
  final int typeId = 4;

  @override
  TxOut read(BinaryReader reader) {
    final scriptPubkey = reader.read();
    final outpoint = reader.read();
    final height = reader.read();
    final unblinded = reader.read();

    return TxOut(
      scriptPubkey: scriptPubkey,
      outpoint: outpoint,
      height: height,
      unblinded: unblinded,
    );
  }

  @override
  void write(BinaryWriter writer, TxOut obj) {
    writer.write(obj.scriptPubkey);
    writer.write(obj.outpoint);
    writer.write(obj.height);
    writer.write(obj.unblinded);
  }
}

class TxOutSecretsAdapter extends TypeAdapter<TxOutSecrets> {
  @override
  final int typeId = 5;

  @override
  TxOutSecrets read(BinaryReader reader) {
    final value = reader.read();
    final valueBf = reader.read();
    final asset = reader.read();
    final assetBf = reader.read();

    return TxOutSecrets(
      value: value,
      valueBf: valueBf,
      asset: asset,
      assetBf: assetBf,
    );
  }

  @override
  void write(BinaryWriter writer, TxOutSecrets obj) {
    writer.write(obj.value);
    writer.write(obj.valueBf);
    writer.write(obj.asset);
    writer.write(obj.assetBf);
  }
}

class OutPointAdapter extends TypeAdapter<OutPoint> {
  @override
  final int typeId = 6;

  @override
  OutPoint read(BinaryReader reader) {
    final txid = reader.read();
    final vout = reader.read();

    return OutPoint(
      txid: txid,
      vout: vout,
    );
  }

  @override
  void write(BinaryWriter writer, OutPoint obj) {
    writer.write(obj.txid);
    writer.write(obj.vout);
  }
}

@HiveType(typeId: 7)
class Balance {
  @HiveField(0)
  final String assetId;
  @HiveField(1)
  final int value;

  const Balance({
    required this.assetId,
    required this.value,
  });

  Balance.fromTuple(String liquidId, int balance)
      : assetId = liquidId,
        value = balance;
}

class BalanceAdapter extends TypeAdapter<Balance> {
  @override
  final int typeId = 7;

  @override
  Balance read(BinaryReader reader) {
    final key = reader.read();
    final value = reader.read();

    return Balance(
      assetId: key,
      value: value,
    );
  }

  @override
  void write(BinaryWriter writer, Balance obj) {
    writer.write(obj.assetId);
    writer.write(obj.value);
  }
}

