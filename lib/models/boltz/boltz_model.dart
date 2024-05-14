import 'package:boltz_dart/boltz_dart.dart';
import 'package:hive/hive.dart';

part 'boltz_model.g.dart';

@HiveType(typeId: 12)
class ExtendedKeyPair {
  @HiveField(0)
  final KeyPair keyPair;

  ExtendedKeyPair(this.keyPair);

  ExtendedKeyPair.raw({
    @HiveField(1)
    required String secretKey,
    @HiveField(2)
    required String publicKey,
  }) : keyPair = KeyPair.raw(
    secretKey: secretKey,
    publicKey: publicKey,
  );
}

@HiveType(typeId: 13)
class ExtendedPreImage {
  @HiveField(0)
  final PreImage preImage;

  ExtendedPreImage(this.preImage);

  ExtendedPreImage.raw({
    @HiveField(1)
    required String value,
    @HiveField(2)
    required String sha256,
    @HiveField(3)
    required String hash160,
  }) : preImage = PreImage.raw(
    value: value,
    sha256: sha256,
    hash160: hash160,
  );
}

@HiveType(typeId: 14)
class ExtendedLBtcSwapScriptV2Str {
  @HiveField(0)
  final LBtcSwapScriptV2Str swapScript;

  ExtendedLBtcSwapScriptV2Str(this.swapScript);

  ExtendedLBtcSwapScriptV2Str.raw({
    @HiveField(1)
    required SwapType swapType,
    @HiveField(2)
    String? fundingAddrs,
    @HiveField(3)
    required String hashlock,
    @HiveField(4)
    required String receiverPubkey,
    @HiveField(5)
    required int locktime,
    @HiveField(6)
    required String senderPubkey,
    @HiveField(7)
    required String blindingKey,
  }) : swapScript = LBtcSwapScriptV2Str.raw(
    swapType: swapType,
    fundingAddrs: fundingAddrs,
    hashlock: hashlock,
    receiverPubkey: receiverPubkey,
    locktime: locktime,
    senderPubkey: senderPubkey,
    blindingKey: blindingKey,
  );
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
class Boltz {
  @HiveField(0)
  final ExtendedLbtcLnV2Swap swap;
  @HiveField(1)
  final ExtendedKeyPair keys;
  @HiveField(2)
  final ExtendedPreImage preimage;
  @HiveField(3)
  final ExtendedLBtcSwapScriptV2Str swapScript;

  Boltz({
    required this.swap,
    required this.keys,
    required this.preimage,
    required this.swapScript,
  });

  static Future<Boltz> createBoltzReceive({
    required AllFees fees,
    required String mnemonic,
    required String address,
    required int amount,
    required int index,
  }) async {

    if(amount == 0){
      throw 'Set an amount to create an invoice';
    }

    if (fees.lbtcLimits.minimal > amount){
      throw 'Amount is below the minimal limit';
    }
    if (fees.lbtcLimits.maximal < amount){
      throw 'Amount is above the maximal limit';
    }
    final result = await LbtcLnV2Swap.newReverse(
        mnemonic: mnemonic,
        index: index,
        outAddress: address,
        outAmount: amount,
        network: Chain.liquid,
        electrumUrl: 'blockstream.info:995',
        boltzUrl: 'https://api.boltz.exchange/v2'
    );


    final extendedPreImage = ExtendedPreImage.raw(
      value: result.preimage.value,
      sha256: result.preimage.sha256,
      hash160: result.preimage.hash160,
    );

    final extendedKeyPair = ExtendedKeyPair.raw(
      secretKey: result.keys.secretKey,
      publicKey: result.keys.publicKey,
    );

    final extendedLBtcSwapScriptV2Str = ExtendedLBtcSwapScriptV2Str.raw(
      swapType: result.swapScript.swapType,
      fundingAddrs: result.swapScript.fundingAddrs,
      hashlock: result.swapScript.hashlock,
      receiverPubkey: result.swapScript.receiverPubkey,
      locktime: result.swapScript.locktime,
      senderPubkey: result.swapScript.senderPubkey,
      blindingKey: result.swapScript.blindingKey,
    );

    final extendedSwap = ExtendedLbtcLnV2Swap(
      id: result.id,
      kind: result.kind,
      network: result.network,
      keys: extendedKeyPair.keyPair,
      preimage: extendedPreImage.preImage,
      swapScript: extendedLBtcSwapScriptV2Str.swapScript,
      invoice: result.invoice,
      outAmount: result.outAmount,
      scriptAddress: result.scriptAddress,
      blindingKey: result.blindingKey,
      electrumUrl: result.electrumUrl,
      boltzUrl: result.boltzUrl,
    );

    return Boltz(
      swap: extendedSwap,
      keys: extendedKeyPair,
      preimage: extendedPreImage,
      swapScript: extendedLBtcSwapScriptV2Str,
    );
  }

  Future<bool> claimBoltzTransaction({
    required String receiveAddress,
    required AllFees fees,
  }) async {
    try{
      final claimToInvoice = await LbtcLnV2Swap.newInstance(
        id: swap.id,
        kind: swap.kind,
        network: swap.network,
        keys: keys.keyPair,
        preimage: preimage.preImage,
        swapScript: swapScript.swapScript,
        invoice: swap.invoice,
        outAmount: swap.outAmount,
        outAddress: swap.scriptAddress,
        blindingKey: swap.blindingKey,
        electrumUrl: swap.electrumUrl,
        boltzUrl: swap.boltzUrl,
      );
      await claimToInvoice.claim(outAddress: receiveAddress, absFee: fees.lbtcReverse.claimFeesEstimate, tryCooperate: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Boltz> createBoltzPay({
    required AllFees fees,
    required String mnemonic,
    required String invoice,
    required int amount,
    required int index,
  }) async {

    if(amount == 0){
      throw 'Amount cannot be 0';
    }

    if (fees.lbtcLimits.minimal >= amount){
      throw 'Amount is below the minimal limit';
    }

    if (fees.lbtcLimits.maximal <= amount){
      throw 'Amount is above the maximal limit';
    }

    final result = await LbtcLnV2Swap.newSubmarine(
        mnemonic: mnemonic,
        index: index,
        invoice: invoice,
        network: Chain.liquid,
        electrumUrl: 'blockstream.info:995',
        boltzUrl: 'https://api.boltz.exchange/v2'
    );

    final extendedPreImage = ExtendedPreImage.raw(
      value: result.preimage.value,
      sha256: result.preimage.sha256,
      hash160: result.preimage.hash160,
    );

    final extendedKeyPair = ExtendedKeyPair.raw(
      secretKey: result.keys.secretKey,
      publicKey: result.keys.publicKey,
    );

    final extendedLBtcSwapScriptV2Str = ExtendedLBtcSwapScriptV2Str.raw(
      swapType: result.swapScript.swapType,
      fundingAddrs: result.swapScript.fundingAddrs,
      hashlock: result.swapScript.hashlock,
      receiverPubkey: result.swapScript.receiverPubkey,
      locktime: result.swapScript.locktime,
      senderPubkey: result.swapScript.senderPubkey,
      blindingKey: result.swapScript.blindingKey,
    );

    final extendedSwap = ExtendedLbtcLnV2Swap(
      id: result.id,
      kind: result.kind,
      network: result.network,
      keys: extendedKeyPair.keyPair,
      preimage: extendedPreImage.preImage,
      swapScript: extendedLBtcSwapScriptV2Str.swapScript,
      invoice: result.invoice,
      outAmount: result.outAmount,
      scriptAddress: result.scriptAddress,
      blindingKey: result.blindingKey,
      electrumUrl: result.electrumUrl,
      boltzUrl: result.boltzUrl,
    );

    return Boltz(
      swap: extendedSwap,
      keys: extendedKeyPair,
      preimage: extendedPreImage,
      swapScript: extendedLBtcSwapScriptV2Str,
    );
  }
}