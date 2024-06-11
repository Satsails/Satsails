import 'package:boltz_dart/boltz_dart.dart';
import 'package:hive/hive.dart';

part 'boltz_model.g.dart';

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

class LBtcSwapScriptV2StrAdapter extends TypeAdapter<LBtcSwapScriptV2Str> {
  @override
  final typeId = 21;

  @override
  LBtcSwapScriptV2Str read(BinaryReader reader) {
    SwapType swapType = SwapType.values[reader.readByte()];
    String? fundingAddrs = reader.readString();
    String hashlock = reader.readString();
    String receiverPubkey = reader.readString();
    int locktime = reader.readInt();
    String senderPubkey = reader.readString();
    String blindingKey = reader.readString();
    return LBtcSwapScriptV2Str(
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
  void write(BinaryWriter writer, LBtcSwapScriptV2Str obj) {
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
  final PreImage preimage;
  @HiveField(5)
  final LBtcSwapScriptV2Str swapScript;
  @HiveField(6)
  final String invoice;
  @HiveField(7)
  final int outAmount;
  @HiveField(8)
  final String scriptAddress;
  @HiveField(9)
  final String blindingKey;
  @HiveField(10)
  final String electrumUrl;
  @HiveField(11)
  final String boltzUrl;

  ExtendedLbtcLnV2Swap({
    required this.id,
    required this.kind,
    required this.network,
    required this.keys,
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
  final LBtcSwapScriptV2Str swapScript;

  LbtcBoltz({
    required this.swap,
    required this.keys,
    required this.preimage,
    required this.swapScript,
  });

  static Future<LbtcBoltz> createBoltzReceive({
    required AllFees fees,
    required String mnemonic,
    required String address,
    required int amount,
    required int index,
  }) async {
    if (amount == 0) {
      throw 'Set an amount to create an invoice';
    }

    if (fees.lbtcLimits.minimal > amount) {
      throw 'Amount is below the minimal limit';
    }
    if (fees.lbtcLimits.maximal < amount) {
      throw 'Amount is above the maximal limit';
    }

    LbtcLnV2Swap result;
    try {
      result = await LbtcLnV2Swap.newReverse(
        mnemonic: mnemonic,
        index: index,
        outAddress: address,
        outAmount: amount,
        network: Chain.liquid,
        electrumUrl: 'blockstream.info:995',
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
      preimage: result.preimage,
      swapScript: result.swapScript,
      invoice: result.invoice,
      outAmount: result.outAmount,
      scriptAddress: result.scriptAddress,
      blindingKey: result.blindingKey,
      electrumUrl: result.electrumUrl,
      boltzUrl: result.boltzUrl,
    );

    return LbtcBoltz(
      swap: extendedSwap,
      keys: result.keys,
      preimage: result.preimage,
      swapScript: result.swapScript,
    );
  }

  Future<bool> claimBoltzTransaction({
    required String receiveAddress,
    required AllFees fees,
  }) async {
    try {
      final claimToInvoice = await LbtcLnV2Swap.newInstance(
        id: swap.id,
        kind: swap.kind,
        network: swap.network,
        keys: keys,
        preimage: preimage,
        outAmount: swap.outAmount,
        swapScript: swapScript,
        invoice: swap.invoice,
        outAddress: swap.scriptAddress,
        blindingKey: swap.blindingKey,
        electrumUrl: swap.electrumUrl,
        boltzUrl: swap.boltzUrl,
        referralId: 'satsails',
      );
      await claimToInvoice.claim(outAddress: receiveAddress, absFee: fees.lbtcReverse.claimFeesEstimate, tryCooperate: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<LbtcBoltz> createBoltzPay({
    required AllFees fees,
    required String mnemonic,
    required String invoice,
    required int amount,
    required int index,
  }) async {
    if (amount == 0) {
      throw 'Amount cannot be 0';
    }

    if (fees.lbtcLimits.minimal >= amount) {
      throw 'Amount is below the minimal limit';
    }

    if (fees.lbtcLimits.maximal <= amount) {
      throw 'Amount is above the maximal limit';
    }

    LbtcLnV2Swap result;

    try {
      result = await LbtcLnV2Swap.newSubmarine(
        mnemonic: mnemonic,
        index: index,
        invoice: invoice,
        network: Chain.liquid,
        electrumUrl: 'blockstream.info:995',
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
      preimage: result.preimage,
      swapScript: result.swapScript,
      invoice: result.invoice,
      outAmount: result.outAmount,
      scriptAddress: result.scriptAddress,
      blindingKey: result.blindingKey,
      electrumUrl: result.electrumUrl,
      boltzUrl: result.boltzUrl,
    );

    return LbtcBoltz(
      swap: extendedSwap,
      keys: result.keys,
      preimage: result.preimage,
      swapScript: result.swapScript,
    );
  }

  Future<bool> refund({
    required String outAddress,
    required AllFees fees,
    required bool tryCooperate,
  }) async {
    try {
      final refund = await LbtcLnV2Swap.newInstance(
        id: swap.id,
        kind: swap.kind,
        network: swap.network,
        keys: keys,
        preimage: preimage,
        swapScript: swapScript,
        invoice: swap.invoice,
        outAmount: swap.outAmount,
        outAddress: swap.scriptAddress,
        blindingKey: swap.blindingKey,
        electrumUrl: swap.electrumUrl,
        boltzUrl: swap.boltzUrl,
      );
      await refund.refund(outAddress: outAddress, absFee: fees.lbtcSubmarine.lockupFeesEstimate, tryCooperate: tryCooperate);
      return true;
    } catch (e) {
      return false;
    }
  }
}

@HiveType(typeId: 24)
class BtcSwapScriptV2StrAdapter extends TypeAdapter<BtcSwapScriptV2Str> {
  @override
  final typeId = 25;

  @override
  BtcSwapScriptV2Str read(BinaryReader reader) {
    SwapType swapType = SwapType.values[reader.readByte()];
    String fundingAddrs = reader.readString();
    String hashlock = reader.readString();
    String receiverPubkey = reader.readString();
    int locktime = reader.readInt();
    String senderPubkey = reader.readString();
    return BtcSwapScriptV2Str(
      swapType: swapType,
      fundingAddrs: fundingAddrs?? '',
      hashlock: hashlock,
      receiverPubkey: receiverPubkey,
      locktime: locktime,
      senderPubkey: senderPubkey,
    );
  }

  @override
  void write(BinaryWriter writer, BtcSwapScriptV2Str obj) {
    writer.writeByte(obj.swapType.index);
    writer.writeString(obj.fundingAddrs?? '',);
    writer.writeString(obj.hashlock);
    writer.writeString(obj.receiverPubkey);
    writer.writeInt(obj.locktime);
    writer.writeString(obj.senderPubkey);
  }
}

@HiveType(typeId: 23)
class ExtendedBtcLnV2Swap {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final SwapType kind;
  @HiveField(2)
  final Chain network;
  @HiveField(3)
  final KeyPair keys;
  @HiveField(4)
  final PreImage preimage;
  @HiveField(5)
  final BtcSwapScriptV2Str swapScript;
  @HiveField(6)
  final String invoice;
  @HiveField(7)
  final int outAmount;
  @HiveField(8)
  final String scriptAddress;
  @HiveField(9)
  final String electrumUrl;
  @HiveField(10)
  final String boltzUrl;

  ExtendedBtcLnV2Swap({
    required this.id,
    required this.kind,
    required this.network,
    required this.keys,
    required this.preimage,
    required this.swapScript,
    required this.invoice,
    required this.outAmount,
    required this.scriptAddress,
    required this.electrumUrl,
    required this.boltzUrl,
  });
}

@HiveType(typeId: 22)
class BtcBoltz {
  @HiveField(0)
  final ExtendedBtcLnV2Swap swap;
  @HiveField(1)
  final KeyPair keys;
  @HiveField(2)
  final PreImage preimage;
  @HiveField(3)
  final BtcSwapScriptV2Str swapScript;

  BtcBoltz({
    required this.swap,
    required this.keys,
    required this.preimage,
    required this.swapScript,
  });

  static Future<BtcBoltz> createBoltzReceive({
    required AllFees fees,
    required String mnemonic,
    required String address,
    required int amount,
    required int index,
  }) async {
    if (amount == 0) {
      throw 'Set an amount to create an invoice';
    }

    if (fees.btcLimits.minimal > amount) {
      throw 'Amount is below the minimal limit';
    }
    if (fees.btcLimits.maximal < amount) {
      throw 'Amount is above the maximal limit';
    }

    BtcLnV2Swap result;
    try {
      result = await BtcLnV2Swap.newReverse(
        mnemonic: mnemonic,
        index: index,
        outAmount: amount,
        outAddress: address,
        network: Chain.bitcoin,
        electrumUrl: 'electrum.blockstream.info:50002',
        boltzUrl: 'https://api.boltz.exchange/v2',
      );
    } catch (e) {
      throw 'Error creating swap';
    }

    final extendedSwap = ExtendedBtcLnV2Swap(
      id: result.id,
      kind: result.kind,
      network: result.network,
      keys: result.keys,
      preimage: result.preimage,
      swapScript: result.swapScript,
      invoice: result.invoice,
      outAmount: result.outAmount,
      scriptAddress: result.scriptAddress,
      electrumUrl: result.electrumUrl,
      boltzUrl: result.boltzUrl,
    );

    return BtcBoltz(
      swap: extendedSwap,
      keys: result.keys,
      preimage: result.preimage,
      swapScript: result.swapScript,
    );
  }

  Future<bool> claimBoltzTransaction({
    required String receiveAddress,
    required AllFees fees,
  }) async {
    try {
      final claimToInvoice = await BtcLnV2Swap.newInstance(
        id: swap.id,
        kind: swap.kind,
        network: swap.network,
        keys: keys,
        preimage: preimage,
        swapScript: swapScript,
        invoice: swap.invoice,
        scriptAddress: swap.scriptAddress,
        outAmount: swap.outAmount,
        electrumUrl: swap.electrumUrl,
        boltzUrl: swap.boltzUrl,
      );
      await claimToInvoice.claim(outAddress: receiveAddress, absFee: fees.btcReverse.claimFeesEstimate, tryCooperate: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<BtcBoltz> createBoltzPay({
    required AllFees fees,
    required String mnemonic,
    required String invoice,
    required int amount,
    required int index,
  }) async {
    if (amount == 0) {
      throw 'Amount cannot be 0';
    }

    if (fees.btcLimits.minimal >= amount) {
      throw 'Amount is below the minimal limit';
    }

    if (fees.btcLimits.maximal <= amount) {
      throw 'Amount is above the maximal limit';
    }

    BtcLnV2Swap result;

    try {
      result = await BtcLnV2Swap.newSubmarine(
        mnemonic: mnemonic,
        index: index,
        invoice: invoice,
        network: Chain.bitcoin,
        electrumUrl: 'electrum.blockstream.info:50002',
        boltzUrl: 'https://api.boltz.exchange/v2',
      );
    } catch (e) {
      throw 'Error creating swap';
    }

    final extendedSwap = ExtendedBtcLnV2Swap(
      id: result.id,
      kind: result.kind,
      network: result.network,
      keys: result.keys,
      preimage: result.preimage,
      swapScript: result.swapScript,
      invoice: result.invoice,
      outAmount: result.outAmount,
      scriptAddress: result.scriptAddress,
      electrumUrl: result.electrumUrl,
      boltzUrl: result.boltzUrl,
    );

    return BtcBoltz(
      swap: extendedSwap,
      keys: result.keys,
      preimage: result.preimage,
      swapScript: result.swapScript,
    );
  }

  Future<bool> refund({
    required String outAddress,
    required AllFees fees,
    required bool tryCooperate,
  }) async {
    try {
      final refund = await BtcLnV2Swap.newInstance(
        id: swap.id,
        kind: swap.kind,
        network: swap.network,
        keys: keys,
        preimage: preimage,
        swapScript: swapScript,
        invoice: swap.invoice,
        outAmount: swap.outAmount,
        scriptAddress: swap.scriptAddress,
        electrumUrl: swap.electrumUrl,
        boltzUrl: swap.boltzUrl,
      );
      await refund.refund(outAddress: outAddress, absFee: fees.btcSubmarine.lockupFeesEstimate, tryCooperate: tryCooperate);
      return true;
    } catch (e) {
      return false;
    }
  }
}
