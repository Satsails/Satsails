import 'dart:typed_data';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:satsails/models/liquid_config_model.dart';

class LiquidModel {
  final Liquid config;

  LiquidModel(this.config);

  Future<String> getAddress() async {
    final address = await config.liquid.wallet.lastUnusedAddress();
    return address.confidential;
  }

  Future<bool> sync() async {
    await config.liquid.wallet.sync(config.electrumUrl);
    return true;
  }

  Future<Balances> balance() async {
    final Balances balance = await config.liquid.wallet.balance();
    return balance;
  }

  Future<List<Tx>> txs() async {
    final txs = await config.liquid.wallet.txs();
    return txs;
  }

  Future<String> build(TransactionBuilder params) async {
    final pset = await config.liquid.wallet.build(
      sats: params.sats,
      outAddress: params.outAddress,
      absFee: params.fee,
    );
    return pset;
  }

  Future<DecodedPset> decode(Wallet wallet, String pset) async {
    final decodedPset = await wallet.decode(pset: pset);
    decodedPset.balances.forEach((balance) {
      // implement
      print('Balance: ${balance}');
    });
    // placeholder
    return DecodedPset(amount: 1, fee: decodedPset.fee);
  }

  Future<Uint8List> sign(String pset, String mnemonic) async {
    final signedTxBytes =
    await  config.liquid.wallet.sign(network: config.liquid.network, pset: pset, mnemonic: mnemonic);

    return signedTxBytes;
  }

  Future<String> broadcast(Wallet wallet,
      Uint8List signedTxBytes) async {
    final tx = await wallet.broadcast(
        electrumUrl: config.electrumUrl, txBytes: signedTxBytes);
    return tx;
  }
}

class Liquid {
  final LiquidConfig liquid;
  final String electrumUrl;

  Liquid({
    required this.liquid,
    required this.electrumUrl,
  });
}

class DecodedPset{
  final int amount;
  final int fee;

  DecodedPset({required this.amount, required this.fee});
}

class TransactionBuilder {
  final int sats;
  final String outAddress;
  final double fee;

  TransactionBuilder({
    required this.sats,
    required this.outAddress,
    required this.fee,
  });
}