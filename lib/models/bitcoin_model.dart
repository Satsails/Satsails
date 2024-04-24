import 'dart:convert';
import 'dart:isolate';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:http/http.dart';

class BitcoinModel {
  final Bitcoin config;

  BitcoinModel(this.config);

  Future<void> sync() async {
    try {
      await config.wallet.sync(blockchain: config.blockchain!);
    } on FormatException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<String> getAddress() async {
    final address = await config.wallet.getAddress(addressIndex: const AddressIndex.lastUnused());
    return await address.address.asString();
  }

  Future<String> getAddressWithAmount(int? amount) async {
    final address = await config.wallet.getAddress(addressIndex: const AddressIndex.lastUnused());
    if (amount == null) {
      return await address.address.asString();
    } else {
      final amountInBtc = amount / 1e8;
      return 'bitcoin:${address.address}?amount=$amountInBtc';
    }
  }

  Future<Input> getPsbtInput(LocalUtxo utxo, bool onlyWitnessUtxo) async {
    final input = await config.wallet.getPsbtInput(utxo: utxo, onlyWitnessUtxo: onlyWitnessUtxo);
    return input;
  }

  Future<List<TransactionDetails>> getTransactions() async {
    final res = await config.wallet.listTransactions(includeRaw: true);
    return res;
  }

  Future<Balance> getBalance() async {
    final res = await config.wallet.getBalance();
    return res;
  }

  Future<List<LocalUtxo>> listUnspend() async {
    final res = await config.wallet.listUnspent();
    return res;
  }

  Future<double> estimateFeeRate(int blocks) async {
    try {
      Response response =
      await get(Uri.parse('https://mempool.space/api/v1/fees/recommended'));
      Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        switch (blocks) {
          case 1:
            return data['fastestFee'].toDouble();
          case 2:
            return data['halfHourFee'].toDouble();
          case 3:
            return data['hourFee'].toDouble();
          case 4:
            return data['economyFee'].toDouble();
          case 5:
            return data['minimumFee'].toDouble();
          default:
            throw Exception("Invalid number of blocks.");
        }
      } else {
        throw Exception("Getting estimated fees is not successful.");
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<(PartiallySignedTransaction, TransactionDetails)> buildBitcoinTransaction(TransactionBuilder transaction) async {
    try{
      final txBuilder = TxBuilder();
      final address = await Address.fromString(s: transaction.outAddress, network: config.network);
      final script = await address.scriptPubkey();
      final txBuilderResult = await txBuilder
          .addRecipient(script, transaction.amount!)
          .feeRate(transaction.fee)
          .finish(config.wallet);
      return txBuilderResult;
    } on GenericException catch (e) {
      throw e.message!;
    } on InsufficientFundsException catch (e) {
      throw "Insufficient funds";
    } on OutputBelowDustLimitException catch (_) {
      throw 'Amount is too small';
    }
  }

  Future<(PartiallySignedTransaction, TransactionDetails)> drainWalletBitcoinTransaction(TransactionBuilder transaction) async {
    try{
      final txBuilder = TxBuilder();
      final address = await Address.fromString(s: transaction.outAddress, network: config.network);
      final script = await address.scriptPubkey();
      final txBuilderResult = await txBuilder.drainWallet().feeRate(transaction.fee).drainTo(script).finish(config.wallet);
      return txBuilderResult;
    } on GenericException catch (e) {
      throw e.message!;
    } on InsufficientFundsException catch (_) {
      throw "Insufficient funds for a transaction this fast";
    } on OutputBelowDustLimitException catch (_) {
      throw 'Amount is too small';
    }
  }

  Future<bool> signBitcoinTransaction((PartiallySignedTransaction, TransactionDetails) txBuilderResult) async {
    return config.wallet.sign(psbt: txBuilderResult.$1);
  }

  Future<void> broadcastBitcoinTransaction((PartiallySignedTransaction, TransactionDetails) signedPsbt) async {
    try {
      final tx = await signedPsbt.$1.extractTx();
      await config.blockchain!.broadcast(transaction: tx);
    } on GenericException catch (e) {
      throw e.message!;
    } on InsufficientFundsException catch (_) {
      throw "Insufficient funds for a transaction this fast";
    } on OutputBelowDustLimitException catch (_) {
      throw 'Amount is too small';
    }
  }
}

class Bitcoin {
  final Wallet wallet;
  final Blockchain? blockchain;
  final Network network;

  Bitcoin(this.wallet, this.blockchain, this.network);
}

class TransactionBuilder {
  final int amount;
  final String outAddress;
  final double fee;

  TransactionBuilder(this.amount, this.outAddress, this.fee);
}