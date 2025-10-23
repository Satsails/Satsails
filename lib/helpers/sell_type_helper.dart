// lib/helpers/sell_type_helper.dart

import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';

// Enums for Selling
enum SellType { Bitcoin, LightningBitcoin, USDT, LiquidBitcoin, Depix }
enum SellMethod { PIX, BankTransfer }
enum SellProvider { Nox, Chimera, Meld, Eulen }
enum CurrencySell { USD, EUR, BRL, CHF, GBP }

// Providers for Selling state management
final selectedCurrencySellProvider = StateProvider<CurrencySell>((ref) => CurrencySell.BRL);
final selectedSellMethodProvider = StateProvider<SellMethod?>((ref) => SellMethod.PIX);
final selectedCryptoTypeSellProvider = StateProvider<SellType>((ref) => SellType.Bitcoin);

// Computed provider to determine the sell provider based on selections
final computedSellProvider = Provider<SellProvider?>((ref) {
  final paymentMethod = ref.watch(selectedSellMethodProvider);
  final asset = ref.watch(selectedCryptoTypeSellProvider);
  final currency = ref.watch(selectedCurrencySellProvider);

  if (currency == CurrencySell.BRL && paymentMethod == SellMethod.PIX) {
    if (asset == SellType.Bitcoin || asset == SellType.USDT || asset == SellType.LiquidBitcoin) {
      return SellProvider.Nox;
    }
  }
  return null;
});

// Provider for available payout methods based on selected currency
final availableSellMethodsProvider = Provider<List<SellMethod>>((ref) {
  final currency = ref.watch(selectedCurrencySellProvider);
  if (currency == CurrencySell.BRL) {
    return [SellMethod.PIX];
  } else {
    return [SellMethod.BankTransfer];
  }
});

// Provider for available assets to sell based on selected currency
final availableSellTypesProvider = Provider<List<SellType>>((ref) {
  final currency = ref.watch(selectedCurrencySellProvider);
  if (currency == CurrencySell.BRL) {
    return [SellType.Bitcoin];
  } else {
    return SellType.values.where((type) => type != SellType.Depix).toList();
  }
});

// Data models for provider details (reused class definitions)
class ProviderDetails {
  final List<String> advantages;
  final List<String> disadvantages;

  ProviderDetails({required this.advantages, required this.disadvantages});
}

class KYCAassessment {
  final List<String> details;
  final double rating;

  KYCAassessment({
    required this.details,
    required this.rating,
  });
}

// Data specific to selling providers
final Map<SellProvider, ProviderDetails> sellProviderDetails = {
  SellProvider.Nox: ProviderDetails(
    advantages: [
      "Near unlimited sale amounts".i18n,
      "Fast settlement".i18n,
    ],
    disadvantages: [
      "You have to KYC with the provider for big amounts".i18n,
      "Sales reported to the Brazilian federal revenue agency under the seller's name".i18n,
    ],
  ),
  SellProvider.Chimera: ProviderDetails(
    advantages: ["To be defined".i18n],
    disadvantages: ["To be defined".i18n],
  ),
  SellProvider.Meld: ProviderDetails(
    advantages: ["To be defined".i18n],
    disadvantages: ["To be defined".i18n],
  ),
  SellProvider.Eulen: ProviderDetails(
    advantages: ["To be defined".i18n],
    disadvantages: ["To be defined".i18n],
  ),
};

// KYC data specific to selling providers
final Map<SellProvider, KYCAassessment> sellKycAssessment = {
  SellProvider.Nox: KYCAassessment(
    details: [
      "Sales are reported to the Brazilian federal revenue agency under the seller's name".i18n,
      "*Always comply with the laws of your jurisdiction.".i18n
    ],
    rating: 4.0,
  ),
  SellProvider.Chimera: KYCAassessment(
    details: [
      "Sales up to 1000 BRL per person are KYC-free, requiring only an email and IP address.",
      "Beyond 1000 BRL, full KYC is required, and sales are reported to a Swiss institution under Swiss law.",
      "Does not automatically communicate with tax systems outside Switzerland.",
      "*Always comply with the laws of your jurisdiction."
    ],
    rating: 4.0,
  ),
  SellProvider.Meld: KYCAassessment(
    details: [
      "Uses various providers, primarily in the US, with KYC requirements varying by provider and sale amount.",
      "Specific KYC details depend on the chosen provider, which is selected based on price.",
      "*Always comply with the laws of your jurisdiction."
    ],
    rating: 3.0,
  ),
  SellProvider.Eulen: KYCAassessment(
    details: [
      "To be defined".i18n,
    ],
    rating: 0.0,
  ),
};

class FeeDetail {
  final IconData icon;
  final String title;
  final String details;

  FeeDetail({required this.icon, required this.title, required this.details});
}

final Map<SellProvider, List<FeeDetail>> sellFeesInformation = {
  SellProvider.Nox: [
    FeeDetail(
      icon: Icons.percent_rounded,
      title: "Total Fee: 2%",
      details: "A competitive rate combining our 1% fee with the provider's 1%.",
    ),
  ],
  SellProvider.Eulen: [
    FeeDetail(
      icon: Icons.stairs_rounded,
      title: "Standard Tier",
      // Note: Adapted text to "sale" instead of "purchase"
      details: "A 3% fee plus a 1 BRL fixed fee applies until your account's total sale history exceeds 3,500 USD.",
    ),
    FeeDetail(
      icon: Icons.workspace_premium_rounded,
      title: "Merchant Tier",
      // Note: Adapted text to "sale" instead of "purchase"
      details: "Once your lifetime sale history surpasses 3,500 USD, you are automatically upgraded, and fees drop to just 1%.",
    ),
    FeeDetail(
      icon: Icons.swap_horiz_rounded,
      title: "Crypto Swaps",
      details: "Fees are dynamic. We recommend simulating the transaction on the 'Swap' screen to see the exact cost before confirming.",
    ),
  ],
  SellProvider.Chimera: [], // Empty list signifies "To be defined"
  SellProvider.Meld: [],
};

// --- END ADDED FEE INFORMATION ---


// UI Helper Maps
final Map<CurrencySell, Widget> currencySellFlags = {
  CurrencySell.EUR: Flag(Flags.european_union),
  CurrencySell.BRL: Flag(Flags.brazil),
  CurrencySell.USD: Flag(Flags.united_states_of_america),
  CurrencySell.CHF: Flag(Flags.switzerland),
  CurrencySell.GBP: Flag(Flags.united_kingdom),
};

final Map<SellMethod, IconData> sellMethodIcons = {
  SellMethod.PIX: Icons.pix,
  SellMethod.BankTransfer: Icons.account_balance,
};

Widget getSellAssetImage(SellType asset) {
  const Map<SellType, String> assetImages = {
    SellType.Depix: 'lib/assets/depix.png',
    SellType.Bitcoin: 'lib/assets/bitcoin-logo.png',
    SellType.LightningBitcoin: 'lib/assets/Bitcoin_lightning_logo.png',
    SellType.USDT: 'lib/assets/tether.png',
    SellType.LiquidBitcoin: 'lib/assets/l-btc.png',
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
        ((name[i].toUpperCase() == name[i] && name[i-1].toLowerCase() == name[i-1]) ||
            (name[i].toUpperCase() == name[i] && i + 1 < name.length && name[i+1].toLowerCase() == name[i+1]))) {
      result += ' ';
    }
    result += name[i];
  }
  return result.i18n;
}