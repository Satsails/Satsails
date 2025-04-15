import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';

enum DepositType { Depix, Bitcoin, LightningBitcoin, USDT, LiquidBitcoin }
enum DepositMethod { PIX, ApplePay, GooglePay, BankTransfer, CreditCard }
enum DepositProvider { Eulen, Nox, Chimera, Meld }
enum CurrencyDeposit { USD, EUR, BRL, CHF, GBP }

final selectedModeProvider = StateProvider<String>((ref) => 'Purchase from Providers');
final selectedCurrencyProvider = StateProvider<CurrencyDeposit>((ref) => CurrencyDeposit.BRL);
final selectedPaymentMethodProvider = StateProvider<DepositMethod?>((ref) => DepositMethod.PIX);
final selectedCryptoTypeProvider = StateProvider<DepositType>((ref) => DepositType.Depix);
final selectedDepositProvider = StateProvider<DepositProvider>((ref) => DepositProvider.Eulen);

final availablePaymentMethodsProvider = Provider<List<DepositMethod>>((ref) {
  final currency = ref.watch(selectedCurrencyProvider);
  if (currency == CurrencyDeposit.BRL) {
    return [DepositMethod.PIX]; // Return all DepositMethod values for BRL
  } else {
    return DepositMethod.values.where((method) => method != DepositMethod.PIX).toList();
  }
});

final availableDepositTypesProvider = Provider<List<DepositType>>((ref) {
  final currency = ref.watch(selectedCurrencyProvider);
  if (currency == CurrencyDeposit.BRL) {
    return [DepositType.Depix, DepositType.Bitcoin, DepositType.LightningBitcoin];
  } else {
    return DepositType.values.where((type) => type != DepositType.Depix).toList();
  }
});

class ProviderDetails {
  final List<String> advantages;
  final List<String> disadvantages;

  ProviderDetails({required this.advantages, required this.disadvantages});
}

final Map<DepositProvider, ProviderDetails> providerDetails = {
  DepositProvider.Eulen: ProviderDetails(
    advantages: [
      "Near-instant deposits",
      "No documentation required",
      "Minimum purchase: 1 BRL",
      "Onboarding made by pix metadata on first purchase",
      "Cashback available"
    ],
    disadvantages: [
      "Depix token purchases are reported and registered with the Brazilian federal revenue agency under the payer's name",
      "Depix token purchases are returned to the sender bank if CPF/CNPJ diverges for the one registered",
      "Not possible to send documentation and unlock higher purchase amounts.",
      "Maximum of 5000 BRL per single transaction",
    ],
  ),
  DepositProvider.Nox: ProviderDetails(
    advantages: [
      "Purchase bitcoin directly".i18n,
      "Near unlimited purchase amounts".i18n,
    ],
    disadvantages: [
      "You have to KYC with the provider".i18n,
      "Purchases reported to the Brazilian federal revenue agency under the payer's name".i18n,
    ],
  ),
  DepositProvider.Chimera: ProviderDetails(
    advantages: ["To be defined".i18n],
    disadvantages: ["To be defined".i18n],
  ),
  DepositProvider.Meld: ProviderDetails(
    advantages: ["To be defined".i18n],
    disadvantages: ["To be defined".i18n],
  ),
};

// Dropdown options (unchanged)
final List<String> modes = ['P2P (No KYC)', 'Purchase from Providers'];
final List<CurrencyDeposit> currencies = CurrencyDeposit.values;

// Currency flags (unchanged)
final Map<CurrencyDeposit, Widget> currencyFlags = {
  CurrencyDeposit.EUR: Flag(Flags.european_union),
  CurrencyDeposit.BRL: Flag(Flags.brazil),
  CurrencyDeposit.USD: Flag(Flags.united_states_of_america),
  CurrencyDeposit.CHF: Flag(Flags.switzerland),
  CurrencyDeposit.GBP: Flag(Flags.united_kingdom),
};

// Payment method icons (unchanged)
final Map<DepositMethod, IconData> paymentMethodIcons = {
  DepositMethod.PIX: Icons.pix,
  DepositMethod.BankTransfer: Icons.account_balance,
  DepositMethod.ApplePay: Icons.apple,
  DepositMethod.GooglePay: Icons.android,
  DepositMethod.CreditCard: Icons.credit_card,
};

// Asset images (unchanged)
Widget getAssetImage(DepositType asset) {
  const Map<DepositType, String> assetImages = {
    DepositType.Depix: 'lib/assets/depix.png',
    DepositType.Bitcoin: 'lib/assets/bitcoin-logo.png',
    DepositType.LightningBitcoin: 'lib/assets/Bitcoin_lightning_logo.png',
    DepositType.USDT: 'lib/assets/tether.png',
    DepositType.LiquidBitcoin: 'lib/assets/l-btc.png',
  };
  return Image.asset(
    assetImages[asset] ?? 'lib/assets/default.png',
    width: 28.sp,
    height: 28.sp,
    errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.white, size: 28.sp),
  );
}

String formatEnumName(String name) {
  String result = '';
  for (int i = 0; i < name.length; i++) {
    if (i > 0 &&
        ((name[i].toUpperCase() == name[i] && name[i - 1].toLowerCase() == name[i - 1]) ||
            (name[i].toUpperCase() == name[i] && i + 1 < name.length && name[i + 1].toLowerCase() == name[i + 1]))) {
      result += ' ';
    }
    result += name[i];
  }
  return result;
}