import 'package:lwk/lwk.dart';
import 'package:Satsails/models/liquid_config_model.dart';
import 'dart:convert';
import 'package:http/http.dart';

class LiquidModel {
  final Liquid config;

  LiquidModel(this.config);

  Future<int> getAddress() async {
    final address = await config.liquid.wallet.addressLastUnused();
    return address.index!;
  }

  Future<String> getLatestAddress() async {
    final address = await config.liquid.wallet.addressLastUnused();
    return address.confidential;
  }

  Future<Address> getAddressOfIndex(int index) async {
    final address = await config.liquid.wallet.address(index: index);
    return address;
  }

  Future<String> getAddressOfIndexString(int index) async {
    final address = await config.liquid.wallet.address(index: index);
    return address.confidential;
  }

  Future<bool> sync() async {
    await config.liquid.wallet.sync_(electrumUrl: config.electrumUrl, validateDomain: true);
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
        sats: BigInt.from(params.amount),
        outAddress: params.outAddress,
        feeRate: params.fee * 100 < 104 ? 104 : params.fee * 100,
        drain: false,
      );
      return pset;
    } catch (e) {
      if ((e as dynamic).msg.toString().contains("InsufficientFunds") || (e as dynamic).msg.toString().contains("InvalidAmount") || (e as dynamic).msg.toString().contains("insufficient funds")) {
        throw "Insufficient funds";
      } else if ((e as dynamic).msg.toString().contains("Base58(TooShort(TooShortError { length: 0 }))") || (e as dynamic).msg.toString().contains("InvalidChecksum") || (e as dynamic).msg.toString().contains("InvalidLength")){
        throw "Address is invalid";
      }
      throw (e as dynamic).msg;
    }
  }

  Future<String> buildDrainWalletTx(TransactionBuilder params) async {
    try {
      final pset = await config.liquid.wallet.buildLbtcTx(
        sats: BigInt.from(params.amount),
        outAddress: params.outAddress,
        feeRate: params.fee * 100 < 104 ? 104 : params.fee * 100,
        drain: true,
      );
      return pset;
    } catch (e) {
      if ((e as dynamic).msg.toString().contains("InsufficientFunds") || (e as dynamic).msg.toString().contains("InvalidAmount") || (e as dynamic).msg.toString().contains("insufficient funds")) {
        throw "Insufficient funds";
      } else if ((e as dynamic).msg.toString().contains("Base58(TooShort(TooShortError { length: 0 }))") || (e as dynamic).msg.toString().contains("InvalidChecksum") || (e as dynamic).msg.toString().contains("InvalidLength")){
        throw "Address is invalid";
      }
      throw (e as dynamic).msg;
    }
  }


  Future<String> buildAssetTx(TransactionBuilder params) async {
    try {
      final pset = await config.liquid.wallet.buildAssetTx(
        sats: BigInt.from(params.amount),
        outAddress: params.outAddress,
        feeRate: params.fee * 100 < 104 ? 104 : params.fee * 100,
        asset: params.assetId,
      );
      return pset;
    } catch (e) {
      if ((e as dynamic).msg.toString().contains("InsufficientFunds") || (e as dynamic).msg.toString().contains("InvalidAmount") || (e as dynamic).msg.toString().contains("insufficient funds")) {
        throw "Insufficient funds, or not enough liquid bitcoin to pay fees.";
      } else if ((e as dynamic).msg.toString().contains("Base58(TooShort(TooShortError { length: 0 }))") || (e as dynamic).msg.toString().contains("InvalidChecksum") || (e as dynamic).msg.toString().contains("InvalidLength")){
        throw "Address is invalid";
      }
      throw (e as dynamic).msg;
    }
  }

  Future<PayjoinTx> buildPayjoinAssetTx(TransactionBuilder params) async {
    try {
      final pset = await config.liquid.wallet.buildPayjoinTx(
          sats: BigInt.from(params.amount),
          outAddress: params.outAddress,
          asset: params.assetId,
          network: config.liquid.network
      );
      return pset;
    } catch (e) {
      if ((e as dynamic).msg.toString().contains("InsufficientFunds") || (e as dynamic).msg.toString().contains("InvalidAmount") || (e as dynamic).msg.toString().contains("insufficient funds")) {
        throw "Insufficient funds to pay fees, try a lower amount to cover network fees";
      } else if ((e as dynamic).msg.toString().contains("Base58(TooShort(TooShortError { length: 0 }))") || (e as dynamic).msg.toString().contains("InvalidChecksum") || (e as dynamic).msg.toString().contains("InvalidLength")){
        throw "Address is invalid";
      }
      throw 'Error building payjoin asset transaction';
    }
  }

  Future<PsetAmounts> decode(String pset) async {
    final decodedPset = await config.liquid.wallet.decodeTx(pset: pset);
    return decodedPset;
  }

  Future<String> sign(SignParams params) async {
    try {
      final signedTxBytes =
      await config.liquid.wallet.signTx(network: config.liquid.network, pset: params.pset, mnemonic: params.mnemonic);

      return signedTxBytes;
    } catch (e) {
      throw (e as dynamic).msg.toString();
    }
  }

  Future<String> signedPsetString(SignParams params) async {
    try {
      final pset =
      await config.liquid.wallet.signedPsetWithExtraDetails(network: config.liquid.network, pset: params.pset, mnemonic: params.mnemonic);

      return pset;
    } catch (e) {
      throw (e as dynamic).msg.toString();
    }
  }

  Future<String> broadcast(String pset) async {
    try {
      final tx = await Blockchain.broadcastSignedPset(electrumUrl: config.electrumUrl, signedPset: pset);
      return tx;
    } catch (e) {
      throw (e as dynamic).msg.toString();
    }
  }

  Future<double> getLiquidFees(int blocks) async {
    try {
      final response = await get(Uri.parse('https://blockstream.info/liquid/api/fee-estimates'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey(blocks.toString())) {
          return data[blocks.toString()];
        } else {
          throw Exception("Estimated fees for the specified blocks not found.");
        }
      } else {
        throw Exception("Getting estimated fees is not successful.");
      }
    } catch (e) {
      throw Exception("Error: ${(e as dynamic).msg.toString()}");
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