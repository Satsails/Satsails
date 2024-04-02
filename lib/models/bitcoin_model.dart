import 'dart:convert';
import 'dart:isolate';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BitcoinModel extends StateNotifier<Bitcoin> {
  BitcoinModel(Bitcoin state) : super(state);

  Future<void> sync(Wallet wallet, Blockchain blockchain) async {
    try {
      Isolate.run(() async => {await wallet.sync(blockchain)});
    } on FormatException catch (e) {
      debugPrint(e.message);
    }
  }

  Future<AddressInfo> getAddress() async {
    final address =
    await state.wallet!.getAddress(addressIndex: const AddressIndex());
    return address;
  }

  Future<Input> getPsbtInput(
      LocalUtxo utxo, bool onlyWitnessUtxo) async {
    final input = await state.wallet!.getPsbtInput(
        utxo: utxo, onlyWitnessUtxo: onlyWitnessUtxo);
    return input;
  }

  Future<List<TransactionDetails>> getUnConfirmedTransactions() async {
    List<TransactionDetails> unConfirmed = [];
    final res = await state.wallet!.listTransactions(true);
    for (var e in res) {
      if (e.confirmationTime == null) unConfirmed.add(e);
    }
    return unConfirmed;
  }

  Future<List<TransactionDetails>> getConfirmedTransactions() async {
    List<TransactionDetails> confirmed = [];
    final res = await state.wallet!.listTransactions(true);

    for (var e in res) {
      if (e.confirmationTime != null) confirmed.add(e);
    }
    return confirmed;
  }

  Future<Balance> getBalance() async {
    if (state.wallet == null) return const Balance(total: 0, confirmed: 0, spendable: 0, immature: 0, trustedPending: 0, untrustedPending: 0);

    final res = await state.wallet!.getBalance();
    return res;
  }

  Future<List<LocalUtxo>> listUnspend() async {
    final res = await state.wallet!.listUnspent();
    return res;
  }

  Future<FeeRate> estimateFeeRate(
      int blocks,
      ) async {
    final feeRate = await state.blockchain!.estimateFee(blocks);
    return feeRate;
  }

  getInputOutPuts(
      TxBuilderResult txBuilderResult,
      Blockchain blockchain,
      ) async {
    final serializedPsbtTx = await txBuilderResult.psbt.jsonSerialize();
    final jsonObj = json.decode(serializedPsbtTx);
    final outputs = jsonObj["unsigned_tx"]["output"] as List;
    final inputs = jsonObj["inputs"][0]["non_witness_utxo"]["output"] as List;
    debugPrint("=========Inputs=====");
    for (var e in inputs) {
      debugPrint("amount: ${e["value"]}");
      debugPrint("script_pubkey: ${e["script_pubkey"]}");
    }
    debugPrint("=========Outputs=====");
    for (var e in outputs) {
      debugPrint("amount: ${e["value"]}");
      debugPrint("script_pubkey: ${e["script_pubkey"]}");
    }
  }

  sendBitcoin(
      Blockchain blockchain, Wallet wallet, String addressStr) async {
    try {
      final txBuilder = TxBuilder();
      final address = await Address.create(address: addressStr);

      final script = await address.scriptPubKey();
      final feeRate = await estimateFeeRate(25);
      final txBuilderResult = await txBuilder
          .addRecipient(script, 750)
          .feeRate(feeRate.asSatPerVb())
          .finish(wallet);
      getInputOutPuts(txBuilderResult, blockchain);
      final aliceSbt = await wallet.sign(psbt: txBuilderResult.psbt);
      final tx = await aliceSbt.extractTx();
      Isolate.run(() async => {await blockchain.broadcast(tx)});
    } on Exception catch (_) {
      rethrow;
    }
  }
}

class Bitcoin {
  Wallet wallet;
  Blockchain blockchain;

  Bitcoin(this.wallet, this.blockchain);

  Bitcoin copyWith({
    Wallet? wallet,
    Blockchain? blockchain,
  }) {
    return Bitcoin(
      wallet ?? this.wallet,
      blockchain ?? this.blockchain,
    );
  }
}