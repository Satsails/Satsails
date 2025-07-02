import 'package:boltz/boltz.dart';
import 'package:hive/hive.dart';

part 'boltz_model.g.dart';

// Existing adapters remain unchanged for brevity
class KeyPairAdapter extends TypeAdapter<KeyPair> {
  @override
  final typeId = 19;

  @override
  KeyPair read(BinaryReader reader) {
    String secretKey = reader.readString();
    String publicKey = reader.readString();
    return KeyPair(secretKey: secretKey, publicKey: publicKey);
  }

  @override
  void write(BinaryWriter writer, KeyPair obj) {
    writer.writeString(obj.secretKey);
    writer.writeString(obj.publicKey);
  }
}

class SwapTypeAdapter extends TypeAdapter<SwapType> {
  @override
  final typeId = 17;

  @override
  SwapType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SwapType.submarine;
      case 1:
        return SwapType.reverse;
      default:
        throw Exception('Unknown SwapType');
    }
  }

  @override
  void write(BinaryWriter writer, SwapType obj) {
    switch (obj) {
      case SwapType.submarine:
        writer.writeByte(0);
        break;
      case SwapType.reverse:
        writer.writeByte(1);
        break;
      case SwapType.chain:
        writer.writeByte(2);
        break;
    }
  }
}

class ChainAdapter extends TypeAdapter<Chain> {
  @override
  final typeId = 18;

  @override
  Chain read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Chain.bitcoin;
      case 1:
        return Chain.bitcoinTestnet;
      case 2:
        return Chain.liquid;
      case 3:
        return Chain.liquidTestnet;
      default:
        throw Exception('Unknown Chain');
    }
  }

  @override
  void write(BinaryWriter writer, Chain obj) {
    switch (obj) {
      case Chain.bitcoin:
        writer.writeByte(0);
        break;
      case Chain.bitcoinTestnet:
        writer.writeByte(1);
        break;
      case Chain.liquid:
        writer.writeByte(2);
        break;
      case Chain.liquidTestnet:
        writer.writeByte(3);
        break;
    }
  }
}

class PreImageAdapter extends TypeAdapter<PreImage> {
  @override
  final typeId = 20;

  @override
  PreImage read(BinaryReader reader) {
    String value = reader.readString();
    String sha256 = reader.readString();
    String hash160 = reader.readString();
    return PreImage(value: value, sha256: sha256, hash160: hash160);
  }

  @override
  void write(BinaryWriter writer, PreImage obj) {
    writer.writeString(obj.value);
    writer.writeString(obj.sha256);
    writer.writeString(obj.hash160);
  }
}

class LBtcSwapScriptV2StrAdapter extends TypeAdapter<LBtcSwapScriptStr> {
  @override
  final typeId = 21;

  @override
  LBtcSwapScriptStr read(BinaryReader reader) {
    SwapType swapType = SwapType.values[reader.readByte()];
    String? fundingAddrs = reader.readString();
    String hashlock = reader.readString();
    String receiverPubkey = reader.readString();
    int locktime = reader.readInt();
    String senderPubkey = reader.readString();
    String blindingKey = reader.readString();
    return LBtcSwapScriptStr(
      swapType: swapType,
      fundingAddrs: fundingAddrs ?? '',
      hashlock: hashlock,
      receiverPubkey: receiverPubkey,
      locktime: locktime,
      senderPubkey: senderPubkey,
      blindingKey: blindingKey,
    );
  }

  @override
  void write(BinaryWriter writer, LBtcSwapScriptStr obj) {
    writer.writeByte(obj.swapType.index);
    writer.writeString(obj.fundingAddrs ?? '');
    writer.writeString(obj.hashlock);
    writer.writeString(obj.receiverPubkey);
    writer.writeInt(obj.locktime);
    writer.writeString(obj.senderPubkey);
    writer.writeString(obj.blindingKey);
  }
}

@HiveType(typeId: 15)
class ExtendedLbtcLnV2Swap {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final SwapType kind;
  @HiveField(2)
  final Chain network;
  @HiveField(3)
  final KeyPair keys;
  @HiveField(4)
  final BigInt keyIndex;
  @HiveField(5)
  final PreImage preimage;
  @HiveField(6)
  final LBtcSwapScriptStr swapScript;
  @HiveField(7)
  final String invoice;
  @HiveField(8)
  final int outAmount;
  @HiveField(9)
  final String scriptAddress;
  @HiveField(10)
  final String blindingKey;
  @HiveField(11)
  final String electrumUrl;
  @HiveField(12)
  final String boltzUrl;

  ExtendedLbtcLnV2Swap({
    required this.id,
    required this.kind,
    required this.network,
    required this.keys,
    required this.keyIndex,
    required this.preimage,
    required this.swapScript,
    required this.invoice,
    required this.outAmount,
    required this.scriptAddress,
    required this.blindingKey,
    required this.electrumUrl,
    required this.boltzUrl,
  });
}

@HiveType(typeId: 16)
class LbtcBoltz {
  @HiveField(0)
  final ExtendedLbtcLnV2Swap swap;
  @HiveField(1)
  final KeyPair keys;
  @HiveField(2)
  final PreImage preimage;
  @HiveField(3)
  final LBtcSwapScriptStr swapScript;
  @HiveField(4)
  final int timestamp;
  @HiveField(5)
  final bool? completed;

  LbtcBoltz({
    required this.swap,
    required this.keys,
    required this.preimage,
    required this.swapScript,
    required this.timestamp,
    this.completed = false,
  });

  // Added copyWith method to align with EulenTransfer functionality
  LbtcBoltz copyWith({
    ExtendedLbtcLnV2Swap? swap,
    KeyPair? keys,
    PreImage? preimage,
    LBtcSwapScriptStr? swapScript,
    int? timestamp,
    bool? completed,
  }) {
    return LbtcBoltz(
      swap: swap ?? this.swap,
      keys: keys ?? this.keys,
      preimage: preimage ?? this.preimage,
      swapScript: swapScript ?? this.swapScript,
      timestamp: timestamp ?? this.timestamp,
      completed: completed ?? this.completed,
    );
  }

  static Future<LbtcBoltz> createBoltzReceive({
    required ReverseFeesAndLimits fees,
    required String mnemonic,
    required String address,
    required int amount,
    required int index,
    required String electrumUrl,
  }) async {
    if (amount == 0) {
      throw 'Set an amount to create a lightning invoice';
    }

    if (fees.lbtcLimits.minimal > BigInt.from(amount)) {
      throw 'Amount is below the minimal limit';
    }
    if (fees.lbtcLimits.maximal < BigInt.from(amount)) {
      throw 'Amount is above the maximal limit';
    }

    LbtcLnSwap result;
    try {
      result = await LbtcLnSwap.newReverse(
        mnemonic: mnemonic,
        index: BigInt.from(index),
        outAddress: address,
        outAmount: BigInt.from(amount),
        network: Chain.liquid,
        electrumUrl: electrumUrl,
        boltzUrl: 'https://api.boltz.exchange/v2',
        referralId: 'satsails',
      );
    } catch (e) {
      throw 'Error creating swap';
    }

    final extendedSwap = ExtendedLbtcLnV2Swap(
      id: result.id,
      kind: result.kind,
      network: result.network,
      keys: result.keys,
      keyIndex: result.keyIndex,
      preimage: result.preimage,
      swapScript: result.swapScript,
      invoice: result.invoice,
      outAmount: result.outAmount.toInt(),
      scriptAddress: result.scriptAddress,
      blindingKey: result.blindingKey,
      electrumUrl: electrumUrl,
      boltzUrl: result.boltzUrl,

    );

    return LbtcBoltz(
      swap: extendedSwap,
      keys: result.keys,
      preimage: result.preimage,
      swapScript: result.swapScript,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      completed: false,
    );
  }

  static Future<LbtcBoltz> createBoltzPay({
    required SubmarineFeesAndLimits fees,
    required String mnemonic,
    required String invoice,
    required int amount,
    required int index,
    required String electrumUrl,
  }) async {
    if (amount == 0) {
      throw 'Amount cannot be 0';
    }

    if (fees.lbtcLimits.minimal > BigInt.from(amount)) {
      throw 'Amount is below the minimal limit';
    }

    if (fees.lbtcLimits.maximal < BigInt.from(amount)) {
      throw 'Amount is above the maximal limit';
    }

    LbtcLnSwap result;
    try {
      result = await LbtcLnSwap.newSubmarine(
        mnemonic: mnemonic,
        index: BigInt.from(index),
        invoice: invoice,
        network: Chain.liquid,
        electrumUrl: electrumUrl,
        boltzUrl: 'https://api.boltz.exchange/v2',
        referralId: 'satsails',
      );
    } catch (e) {
      throw 'Error creating swap';
    }

    final extendedSwap = ExtendedLbtcLnV2Swap(
      id: result.id,
      kind: result.kind,
      network: result.network,
      keys: result.keys,
      keyIndex: result.keyIndex,
      preimage: result.preimage,
      swapScript: result.swapScript,
      invoice: result.invoice,
      outAmount: result.outAmount.toInt(),
      scriptAddress: result.scriptAddress,
      blindingKey: result.blindingKey,
      electrumUrl: electrumUrl,
      boltzUrl: result.boltzUrl,
    );

    return LbtcBoltz(
      swap: extendedSwap,
      keys: result.keys,
      preimage: result.preimage,
      swapScript: result.swapScript,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      completed: false,
    );
  }

  Future<bool> claimBoltzTransaction({
    required String receiveAddress,
    required ReverseFeesAndLimits fees,
    required String electrumUrl,
  }) async {
    LbtcLnSwap? claimToInvoice;
    try {
      claimToInvoice = await LbtcLnSwap.newInstance(
          id: swap.id,
          kind: swap.kind,
          network: swap.network,
          keyIndex: swap.keyIndex,
          keys: keys,
          preimage: preimage,
          swapScript: swapScript,
          invoice: swap.invoice,
          outAmount: BigInt.from(swap.outAmount),
          outAddress: swap.scriptAddress,
          blindingKey: swap.blindingKey,
          electrumUrl: electrumUrl,
          boltzUrl: swap.boltzUrl,
          referralId: 'satsails'
      );
      final hex = await claimToInvoice.claim(
        outAddress: receiveAddress,
        minerFee: TxFee.absolute(fees.lbtcFees.minerFees.claim),
        tryCooperate: true,
      );
      await claimToInvoice.broadcastBoltz(signedHex: hex);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> refund({
    required String outAddress,
    required SubmarineFeesAndLimits fees,
    required String electrumUrl,
  }) async {
    try {
      // Initialize the swap instance for the refund
      final LbtcLnSwap refundSwap = await LbtcLnSwap.newInstance(
        id: swap.id,
        kind: swap.kind,
        network: swap.network,
        keyIndex: swap.keyIndex,
        keys: keys,
        preimage: preimage,
        swapScript: swapScript,
        invoice: swap.invoice,
        outAmount: BigInt.from(swap.outAmount),
        outAddress: swap.scriptAddress,
        blindingKey: swap.blindingKey,
        electrumUrl: electrumUrl,
        boltzUrl: swap.boltzUrl,
        referralId: 'satsails',
      );

      // First, attempt a cooperative refund.
      try {
        final String hex = await refundSwap.refund(
          outAddress: outAddress,
          minerFee: TxFee.absolute(fees.lbtcFees.minerFees),
          tryCooperate: true,
        );
        await refundSwap.broadcastBoltz(signedHex: hex);
        return true;
      } catch (e) {
        final String hex = await refundSwap.refund(
          outAddress: outAddress,
          minerFee: TxFee.absolute(fees.lbtcFees.minerFees),
          tryCooperate: false,
        );
        await refundSwap.broadcastBoltz(signedHex: hex);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> coopCloseSubmarineSwap({
    required String electrumUrl,
  }) async {
    if (swap.kind != SwapType.submarine) {
      throw 'Not a submarine swap';
    }
    final lbtcLnSwap = await LbtcLnSwap.newInstance(
        id: swap.id,
        kind: swap.kind,
        network: swap.network,
        keys: keys,
        keyIndex: swap.keyIndex,
        preimage: preimage,
        swapScript: swapScript,
        invoice: swap.invoice,
        outAmount: BigInt.from(swap.outAmount),
        outAddress: swap.scriptAddress,
        blindingKey: swap.blindingKey,
        electrumUrl: electrumUrl,
        boltzUrl: swap.boltzUrl,
        referralId: 'satsails'
    );
    await lbtcLnSwap.coopCloseSubmarine();
  }
}