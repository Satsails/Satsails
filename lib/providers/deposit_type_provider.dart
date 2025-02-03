import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DepositType { depix, bitcoin, lightning_bitcoin, usdt }
enum DepositMethod { pix, credit_card, big_tech_pay, bank_transfer }
enum DepositProvider { Eulen, NoxPay, Chimera }
enum CurrencyDeposit { USD, EUR, BRL, CFH }

final depositTypeProvider = StateProvider.autoDispose<DepositType>(
      (ref) => DepositType.depix,
);

final depositMethodProvider = StateProvider.autoDispose<DepositMethod>(
      (ref) => DepositMethod.pix,
);

final depositProvider = StateProvider.autoDispose<DepositProvider>(
      (ref) => DepositProvider.Eulen,
);

final currencyTypeDeposit = StateProvider.autoDispose<CurrencyDeposit>(
      (ref) => CurrencyDeposit.EUR,
);


final depositMethodBasedOnTypeProvider = StateProvider<Set<DepositMethod>>((ref) {
  final depositType = ref.watch(depositTypeProvider);

  switch (depositType) {
    case DepositType.depix:
      return {DepositMethod.pix};
    case DepositType.bitcoin:
      return {DepositMethod.pix};
    case DepositType.lightning_bitcoin:
      return {DepositMethod.pix};
    case DepositType.usdt:
      return {DepositMethod.pix};
  }
});

final depositProviderBasedOnMethodProvider = StateProvider<Set<DepositProvider>>((ref) {
  final availableMethods = ref.watch(depositMethodBasedOnTypeProvider);
  final providers = <DepositProvider>{};
  for (final method in availableMethods) {
    switch (method) {
      case DepositMethod.pix:
          providers.addAll({DepositProvider.Eulen});
        break;
      case DepositMethod.credit_card:
        providers.add(DepositProvider.NoxPay);
        break;
      case DepositMethod.big_tech_pay:
        providers.add(DepositProvider.NoxPay);
        break;
      case DepositMethod.bank_transfer:
        providers.add(DepositProvider.NoxPay);
        break;
    }
  }

  return providers;
});

final depositCurrencyBasedOnProvider = StateProvider<Set<CurrencyDeposit>>((ref) {
  final availableMethods = ref.watch(depositProviderBasedOnMethodProvider);
  final currencies = <CurrencyDeposit>{};
  for (final method in availableMethods) {
    switch (method) {
      case DepositProvider.Eulen:
        currencies.add(CurrencyDeposit.BRL);
        break;
      case DepositProvider.NoxPay:
        currencies.add(CurrencyDeposit.BRL);
        break;
      case DepositProvider.Chimera:
        currencies.add(CurrencyDeposit.EUR);
        break;
    }
  }
    return currencies;
});
