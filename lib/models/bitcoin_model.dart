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

  int getAddress() {
    final address = config.wallet.getAddress(addressIndex: const AddressIndex.lastUnused());
    return address.index;
  }

  String getAddressString() {
    final address = config.wallet.getAddress(addressIndex: const AddressIndex.lastUnused());
    return address.address.asString();
  }

  String getCurrentAddress(int index) {
    final address = config.wallet.getAddress(addressIndex: AddressIndex.peek(index: index));
    return address.address.asString();
  }

  AddressInfo getAddressInfo(int index) {
    final address = config.wallet.getAddress(addressIndex: AddressIndex.peek(index: index));
    return address;
  }

  Input getPsbtInput(LocalUtxo utxo, bool onlyWitnessUtxo) {
    final input = config.wallet.getPsbtInput(utxo: utxo, onlyWitnessUtxo: onlyWitnessUtxo);
    return input;
  }

  List<TransactionDetails> getTransactions() {
    final res = config.wallet.listTransactions(includeRaw: true);
    return res;
  }

  Balance getBalance() {
    final res = config.wallet.getBalance();
    return res;
  }

  List<LocalUtxo> listUnspend() {
    final res = config.wallet.listUnspent();
    return res;
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

  bool signBitcoinTransaction((PartiallySignedTransaction, TransactionDetails) txBuilderResult) {
    return config.wallet.sign(psbt: txBuilderResult.$1);
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
