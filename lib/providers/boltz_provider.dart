import 'dart:convert';

import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:boltz_dart/boltz_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final boltzFeesProvider = FutureProvider.autoDispose<AllFees>((ref) async {
      return await AllFees.fetch(boltzUrl: 'https://api.boltz.exchange');
});

final boltzReceiveProvider = FutureProvider.autoDispose<LbtcLnV2Swap>((ref) async {
      try{
            final fees = await ref.read(boltzFeesProvider.future).then((value) => value);
            final authModel = ref.read(authModelProvider);
            final mnemonic = await authModel.getMnemonic().then((value) => value);
            final address = await ref.read(liquidAddressProvider.future).then((value) => value);
            final amount = await ref.watch(lnAmountProvider.future).then((value) => value);
            if (fees.lbtcLimits.minimal > amount){
                  throw 'Amount is below the minimal limit';
            }
            if (fees.lbtcLimits.maximal < amount){
                  throw 'Amount is above the maximal limit';
            }
            final val = await LbtcLnV2Swap.newReverse(
                mnemonic: mnemonic!,
                index: address.index,
                outAddress: address.confidential,
                outAmount: amount,
                network: Chain.liquid,
                electrumUrl: 'blockstream.info:995',
                boltzUrl: 'https://api.boltz.exchange/v2'
            );

            return val;
      } catch (e) {
            throw e;
      }
});

final periodicProvider = StreamProvider.autoDispose<int>((ref) {
      return Stream.periodic(Duration(seconds: 3), (i) => i);
});

final claimBoltzTransactionProvider = FutureProvider.autoDispose<bool>((ref) async {
      final receiveAddress = await ref.read(liquidAddressProvider.future).then((value) => value);
      final fees = await ref.read(boltzFeesProvider.future).then((value) => value);
      final invoice = await ref.watch(boltzReceiveProvider.future).then((value) => value);
      try{
            final claimToInvoice = await LbtcLnV2Swap.newInstance(
                  id: invoice.id,
                  kind: invoice.kind,
                  network: invoice.network,
                  keys: invoice.keys,
                  preimage: invoice.preimage,
                  swapScript: invoice.swapScript,
                  invoice: invoice.invoice,
                  outAmount: invoice.outAmount,
                  outAddress: receiveAddress.confidential,
                  blindingKey: invoice.blindingKey,
                  electrumUrl: invoice.electrumUrl,
                  boltzUrl: invoice.boltzUrl,
            );

            final claim = await claimToInvoice.claim(outAddress: receiveAddress.confidential, absFee: fees.lbtcReverse.claimFeesEstimate, tryCooperate: true).then((value) => value);
            return true;
      } catch (e) {
            throw e;
      }
});