import 'dart:convert';

import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:boltz_dart/boltz_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final boltzFeesProvider = FutureProvider.autoDispose<AllFees>((ref) async {
      return await AllFees.fetch(boltzUrl: 'https://api.boltz.exchange');
});

final boltzReceiveProvider = FutureProvider.autoDispose<LbtcLnV2Swap>((ref) async {
      try{
            const FlutterSecureStorage _storage = FlutterSecureStorage();
            final fees = await ref.read(boltzFeesProvider.future).then((value) => value);
            final authModel = ref.read(authModelProvider);
            final mnemonic = await authModel.getMnemonic().then((value) => value);
            final address = await ref.read(liquidAddressProvider.future).then((value) => value);
            final amount = await ref.read(lnAmountProvider.future).then((value) => value);
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
                boltzUrl: 'api.boltz.exchange/v2'
            );

            return val;
      } catch (e) {
            throw e;
      }
});

final claimBoltzTransactionProvider = FutureProvider.autoDispose<void>((ref) async {
      final authModel = ref.read(authModelProvider);
      final mnemonic = await authModel.getMnemonic().then((value) => value);
      final swap = await ref.watch(boltzReceiveProvider.future).then((value) => value);
});