import 'dart:async';
import 'dart:convert';
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

  Future<int> getAddress() async {
    final address = await config.wallet.getAddress(addressIndex: const AddressIndex.lastUnused());
    return address.index;
  }

  Future<String> getAddressString() async {
    final address = await config.wallet.getAddress(addressIndex: const AddressIndex.lastUnused());
    return address.address.asString();
  }

  Future<String> getCurrentAddress(int index) async {
    final address = await config.wallet.getAddress(addressIndex: AddressIndex.peek(index: index));
    return address.address.asString();
  }

  Future<AddressInfo> getAddressInfo(int index) async {
    final address = await config.wallet.getAddress(addressIndex: AddressIndex.peek(index: index));
    return address;
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

  Future<List<LocalUtxo>> listUnspent() async {
    final res = await config.wallet.listUnspent();
    return res;
  }

  Future<bool> signBitcoinTransaction((PartiallySignedTransaction, TransactionDetails) txBuilderResult) async {
    return config.wallet.sign(psbt: txBuilderResult.$1);
  }


  Future<BitcoinFeeModel> estimateFeeRate() async {
    try {
      Response response = await get(Uri.parse('https://mempool.space/api/v1/fees/recommended'));
      Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final fastestFee = data['fastestFee'].toDouble();
        final halfHourFee = data['halfHourFee'].toDouble();
        final hourFee = data['hourFee'].toDouble();
        final economyFee = data['economyFee'].toDouble();
        final minimumFee = data['minimumFee'].toDouble();

        return BitcoinFeeModel(fastestFee, halfHourFee, hourFee, economyFee, minimumFee);
      } else {
        throw Exception("Getting estimated fees is not successful.");
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<(PartiallySignedTransaction, TransactionDetails)> buildBitcoinTransaction(
      TransactionBuilder transaction) async {
    try {
      final txBuilder = TxBuilder();
      final address = await Address.fromString(s: transaction.outAddress, network: config.network);
      final script = address.scriptPubkey();
      final txBuilderResult = await txBuilder
          .addRecipient(script, BigInt.from(transaction.amount))
          .feeRate(transaction.fee)
          .enableRbf()
          .finish(config.wallet);
      return txBuilderResult;
    } on GenericException catch (e) {
      throw e.message!;
    } on InsufficientFundsException {
      throw "Insufficient funds";
    } on OutputBelowDustLimitException catch (_) {
      throw 'Amount is too small';
    } on AddressException catch (_) {
      throw 'Address is invalid';
    }
  }

  Future<(PartiallySignedTransaction, TransactionDetails)> drainWalletBitcoinTransaction(
      TransactionBuilder transaction) async {
    try {
      final txBuilder = TxBuilder();
      final address = await Address.fromString(s: transaction.outAddress, network: config.network);
      final script = address.scriptPubkey();
      final txBuilderResult = await txBuilder
          .drainWallet()
          .drainTo(script)
          .feeRate(transaction.fee)
          .enableRbf()
          .finish(config.wallet);
      return txBuilderResult;
    } on GenericException catch (e) {
      throw e.message!;
    } on InsufficientFundsException catch (_) {
      throw "Insufficient funds for a transaction this fast";
    } on OutputBelowDustLimitException catch (_) {
      throw 'Amount is too small';
    } on AddressException catch (_) {
      throw 'Address is invalid';
    }
  }

  Future<(PartiallySignedTransaction, TransactionDetails)> bumpFeeTransaction(
      BumpFeeTransactionBuilder transaction) async {
    try {
      final txBuilder = BumpFeeTxBuilder(
        txid: transaction.txid,
        feeRate: transaction.fee,
      );

      final txBuilderResult = await txBuilder
          .enableRbf()
          .finish(config.wallet);

      return txBuilderResult;

    } on GenericException catch (e) {
      // Handle specific BDK errors
      if (e.message!.contains("Transaction not found")) {
        throw "Original transaction not found in the wallet. Make sure it has been synced.";
      }
      if (e.message!.contains("transaction is already confirmed")) {
        throw "Cannot bump fee: The transaction is already confirmed.";
      }
      throw e.message!;
    } on InsufficientFundsException catch (_) {
      throw "Insufficient funds to pay for the new fee rate.";
    } on AddressException catch (_) {
      throw 'Invalid address encountered.';
    } catch (e) {
      rethrow;
    }
  }

  Future<String> broadcastBitcoinTransaction(
      (PartiallySignedTransaction, TransactionDetails) signedPsbt) async {
    try {
      final tx = signedPsbt.$1.extractTx();
      return await config.blockchain!.broadcast(transaction: tx);
    } on GenericException catch (e) {
      throw e.message!;
    } on InsufficientFundsException catch (_) {
      throw "Insufficient funds for a transaction this fast";
    } on OutputBelowDustLimitException catch (_) {
      throw 'Amount is too small';
    } catch (e) {
      throw e.toString();
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

class BumpFeeTransactionBuilder {
  final String txid;
  final double fee;

  BumpFeeTransactionBuilder({required this.txid, required this.fee});
}

class BitcoinFeeModel {
  final double fastestFee;
  final double halfHourFee;
  final double hourFee;
  final double economyFee;
  final double minimumFee;

  BitcoinFeeModel(this.fastestFee, this.halfHourFee, this.hourFee, this.economyFee, this.minimumFee);
}
