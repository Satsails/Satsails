import 'dart:typed_data';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:Satsails/models/liquid_config_model.dart';
import 'dart:convert';
import 'package:http/http.dart';

class LiquidModel {
  final Liquid config;

  LiquidModel(this.config);

  Future<Address> getAddress() async {
    final address = await config.liquid.wallet.addressLastUnused();
    return address;
  }

  Future<String> getNextAddress() async {
    final lastUnused = await config.liquid.wallet.addressLastUnused();
    final address = await config.liquid.wallet.address(index: lastUnused.index + 1);
    return address.confidential;
  }

  Future<bool> sync() async {
    await config.liquid.wallet.sync(electrumUrl: config.electrumUrl);
    return true;
  }

  Future<Balances> balance() async {
    final Balances balance = await config.liquid.wallet.balances();
    return balance;
  }

  Future<List<Tx>> txs() async {
    final txs = await config.liquid.wallet.txs();
    return txs;
  }

  Future<List<TxOut>> listUnspent() async {
    final utxos = await config.liquid.wallet.utxos();
    return utxos;
  }

  Future<String> buildLbtcTx(TransactionBuilder params) async {
    try {
      final pset = await config.liquid.wallet.buildLbtcTx(
        sats: params.amount,
        outAddress: params.outAddress,
        feeRate: params.fee * 1000,
      );
      return pset;
    } catch (e) {
      if (e.toString().contains("InsufficientFunds")) {
        throw "Insufficient funds";
      }
      throw e.toString();
    }
  }

  Future<String> buildDrainWalletTx(TransactionBuilder params) async {
    var amount = params.amount;
    while (true) {
      try {
        final pset = await config.liquid.wallet.buildLbtcTx(
          sats: amount,
          outAddress: params.outAddress,
          feeRate: params.fee * 1000,
        );
        return pset;
      } catch (e) {
        if (amount > 0) {
          amount -= 1000;
        } else {
          if (e.toString().contains("InsufficientFunds")) {
            throw "Insufficient funds";
          }
          throw e.toString();
        }
      }
    }
  }


  Future<String> buildAssetTx(TransactionBuilder params) async {
    try {
    final pset = await config.liquid.wallet.buildAssetTx(
      sats: params.amount,
      outAddress: params.outAddress,
      feeRate: params.fee * 1000,
      asset: params.assetId,
    );
    return pset;
    } catch (e) {
      if (e.toString().contains("InsufficientFunds")) {
        throw "Insufficient funds";
      }
      throw e.toString();
    }
  }

  Future<PsetAmounts> decode(String pset) async {
    final decodedPset = await config.liquid.wallet.decodeTx(pset: pset);
    return decodedPset;
  }

  Future<Uint8List> sign(SignParams params) async {
    try {
      final signedTxBytes =
      await config.liquid.wallet.signTx(network: config.liquid.network, pset: params.pset, mnemonic: params.mnemonic);

      return signedTxBytes;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> signedPsetString(SignParams params) async {
    try {
      final pset = '';
      // await config.liquid.wallet.signedPsetWithExtraDetails(network: config.liquid.network, pset: params.pset, mnemonic: params.mnemonic);


      return pset;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> broadcast(Uint8List signedTxBytes) async {
    try {
      final tx = await Wallet.broadcastTx(electrumUrl: config.electrumUrl, txBytes: signedTxBytes);
      return tx;
    } catch (e) {
      throw e.toString();
    }
  }


  Future<double> getLiquidFees(int blocks) async {
    try {
      Response response =
      await get(Uri.parse('https://blockstream.info/liquid/api/fee-estimates'));
      Map data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data[blocks.toString()];
      } else {
        throw Exception("Getting estimated fees is not successful.");
      }
    } catch (_) {
      rethrow;
    }
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

class TransactionBuilder {
  final int amount;
  final String outAddress;
  final double fee;
  final String assetId;

  TransactionBuilder({
    required this.amount,
    required this.outAddress,
    required this.fee,
    required this.assetId,
  });
}

class SignParams {
  final String pset;
  final String mnemonic;

  SignParams({
    required this.pset,
    required this.mnemonic,
  });
}