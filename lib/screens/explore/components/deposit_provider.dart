import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/providers/deposit_type_provider.dart' as helpers;

class DepositProvider extends ConsumerWidget {
  const DepositProvider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableDepositProviders =
    ref.watch(helpers.depositProviderBasedOnMethodProvider);

    final List<_DepositProviderOption> allProviders = [
      const _DepositProviderOption(
        title: "Eulen",
        provider: helpers.DepositProvider.Eulen,
      ),
      const _DepositProviderOption(
        title: "NoxPay",
        provider: helpers.DepositProvider.NoxPay,
      ),
      const _DepositProviderOption(
        title: "Chimera",
        provider: helpers.DepositProvider.Chimera,
      ),
    ];

    // Filter only the available providers.
    final availableProviders = allProviders
        .where((provider) =>
        availableDepositProviders.contains(provider.provider))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Provider".i18n,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        // Using a ListView to allow scrolling if there are many cards.
        child: ListView(
          children: availableProviders
              .map(
                (provider) => Padding(
              padding: EdgeInsets.only(bottom: 0.02.sh),
              child: provider,
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

class _DepositProviderOption extends ConsumerStatefulWidget {
  final String title;
  final helpers.DepositProvider provider;

  const _DepositProviderOption({
    required this.title,
    required this.provider,
  });

  @override
  ConsumerState<_DepositProviderOption> createState() =>
      _DepositProviderOptionState();
}

class _DepositProviderOptionState extends ConsumerState<_DepositProviderOption> {
  bool _isExpanded = false;

  /// Trigger navigation when the main area of the card is tapped.
  void _handleNavigation() {
    if (widget.provider == helpers.DepositProvider.Eulen) {
      context.push(
          '/home/explore/deposit_type/deposit_method/deposit_provider/deposit_pix_eulen');
    }
    if (widget.provider == helpers.DepositProvider.NoxPay) {
      context.push(
          '/home/explore/deposit_type/deposit_method/deposit_provider/deposit_pix_nox');
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the provider is NoxPay, override accepted currencies to "BRL".
    final acceptedCurrenciesFromProvider =
    ref.watch(helpers.depositCurrencyBasedOnProvider);
    final acceptedCurrenciesText =
    widget.provider == helpers.DepositProvider.NoxPay
        ? "BRL".i18n
        : acceptedCurrenciesFromProvider
        .map((currency) => currency.toString().split('.').last)
        .join(', ');

    // Define summary texts based on provider.
    final List<String> summaryTexts =
    widget.provider == helpers.DepositProvider.NoxPay
        ? ["Enrollment process required".i18n, "No limit purchases".i18n]
        : ["Only accepts BRL".i18n, "Max 6000 BRL per day".i18n];

    // Provider details for each deposit provider.
    final Map<helpers.DepositProvider, ProviderDetails> providerDetails = {
      helpers.DepositProvider.Eulen: ProviderDetails(
        advantages: [
          "Near-instant deposits",
          "No documentation required",
          "Minimum purchase: 1 BRL",
          "Onboarding made by pix metadata on first purchase",
        ],
        disadvantages: [
          "Depix token purchases are reported and registered with the Brazilian federal revenue agency under the payer's name",
          "Depix token purchases are returned to the sender bank if CPF/CNPJ diverges for the one registered",
          "Not possible to send documentation and unlock higher purchase amounts.",
          "Maximum of 5000 BRL per single transaction",
        ],
      ),
      helpers.DepositProvider.NoxPay: ProviderDetails(
        advantages: [
          "Purchase bitcoin directly".i18n,
          "Near unlimited purchase amounts".i18n,
        ],
        disadvantages: [
          "You have to KYC with the provider".i18n,
          "Purchases reported to the Brazilian federal revenue agency under the payer's name".i18n,
        ],
      ),
      helpers.DepositProvider.Chimera: ProviderDetails(
        advantages: [
          // Add Chimera advantages here.
        ],
        disadvantages: [
          // Add Chimera disadvantages here.
        ],
      ),
    };

    final details = providerDetails[widget.provider] ??
        ProviderDetails(
          advantages: ["Details not available".i18n],
          disadvantages: ["Details not available".i18n],
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main area: tapping anywhere here (except on the toggle) triggers navigation.
          InkWell(
            onTap: _handleNavigation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with provider logo, title (if applicable), and arrow on the right.
                SizedBox(
                  height: 60.h,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_getAssetForProvider(widget.provider).isNotEmpty)
                              SvgPicture.asset(
                                _getAssetForProvider(widget.provider),
                                width: 30,
                                height: 30,
                              ),
                            if (widget.provider != helpers.DepositProvider.Eulen)
                              Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: Text(
                                  widget.title.i18n,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Arrow on the right.
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.chevron_right,
                          size: 25.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Summary section.
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summaryTexts
                        .map((text) => _buildSummaryRow(text))
                        .toList(),
                  ),
                ),
                // Expanded details section (if expanded).
                if (_isExpanded)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Accepted Currencies with a money icon.
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 18.sp,
                              color: Colors.amberAccent,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                "Accepted Currencies: $acceptedCurrenciesText"
                                    .i18n,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Advantages section.
                        Text(
                          "Advantages:".i18n,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        ...details.advantages.map(
                              (advantage) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: Colors.greenAccent,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    advantage.i18n,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Disadvantages section.
                        Text(
                          "Disadvantages:".i18n,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        ...details.disadvantages.map(
                              (disadvantage) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 16.sp,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    disadvantage.i18n,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // "See details" toggle at the bottom center.
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _isExpanded ? "Hide details".i18n : "See details".i18n,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a summary row with a check icon and text.
  Widget _buildSummaryRow(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: Colors.greenAccent,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getAssetForProvider(helpers.DepositProvider provider) {
    switch (provider) {
      case helpers.DepositProvider.Eulen:
        return 'lib/assets/eulen-logo.svg';
      case helpers.DepositProvider.NoxPay:
        return ''; // No asset for NoxPay
      case helpers.DepositProvider.Chimera:
        return 'lib/assets/chimera-logo.svg';
      default:
        return 'lib/assets/default-logo.svg';
    }
  }
}

/// A helper class to hold details for each deposit provider.
class ProviderDetails {
  final List<String> advantages;
  final List<String> disadvantages;

  ProviderDetails({
    required this.advantages,
    required this.disadvantages,
  });
}
