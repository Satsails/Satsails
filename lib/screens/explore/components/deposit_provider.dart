import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/providers/deposit_type_provider.dart' as helpers;
import 'package:i18n_extension/default.i18n.dart';

class DepositProvider extends ConsumerWidget {
  const DepositProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableDepositProviders =
    ref.watch(helpers.depositProviderBasedOnMethodProvider);

    final List<_DepositProviderOption> allProviders = [
      _DepositProviderOption(
        title: "Eulen".i18n,
        provider: helpers.DepositProvider.Eulen,
      ),
      _DepositProviderOption(
        title: "NoxPay".i18n,
        provider: helpers.DepositProvider.NoxPay,
      ),
      _DepositProviderOption(
        title: "Chimera".i18n,
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
    Key? key,
    required this.title,
    required this.provider,
  }) : super(key: key);

  @override
  ConsumerState<_DepositProviderOption> createState() =>
      _DepositProviderOptionState();
}

class _DepositProviderOptionState extends ConsumerState<_DepositProviderOption> {
  bool _isExpanded = false;

  /// Trigger navigation when the main area of the card is tapped.
  void _handleNavigation() {
    context.push(
        '/home/explore/deposit_type/deposit_method/deposit_provider/deposit_pix_eulen');
  }

  @override
  Widget build(BuildContext context) {
    final acceptedCurrencies =
    ref.watch(helpers.depositCurrencyBasedOnProvider);
    final acceptedCurrenciesText = acceptedCurrencies
        .map((currency) => currency.toString().split('.').last)
        .join(', ');

    // Provider details (for Eulen, appended with two extra disadvantage items).
    final Map<helpers.DepositProvider, ProviderDetails> providerDetails = {
      helpers.DepositProvider.Eulen: ProviderDetails(
        advantages: [
          "Maximum purchase per person: 6000 BRL per day",
          "Near-instant deposits",
          "No documentation required",
          "Minimum purchase per person: 1 BRL",
        ],
        disadvantages: [
          "If a user sends more than 6000 BRL per day, refunds are not automatic and may take several hours",
          "Depix token purchases are reported and registered with the Brazilian federal revenue agency under the payer's name",
          "Not possible to send documentation and unlock higher purchase amounts. ",
          "You will need to convert DEPIX into bitcoin manually",
          "Maximum of 5000 BRL per single transaction",
          "A purchase history is required to gradually unlock the maximum transaction limit: starting at 500 BRL, then increasing to 1000 BRL and 2000 BRL, eventually unlocking up to 5000 BRL per transaction.",
        ],
      ),
      helpers.DepositProvider.NoxPay: ProviderDetails(
        advantages: [
          // Add NoxPay advantages here.
        ],
        disadvantages: [
          // Add NoxPay disadvantages here.
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
          advantages: ["Details not available"],
          disadvantages: ["Details not available"],
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
                Container(
                  height: 60.h,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              _getAssetForProvider(widget.provider),
                              width: 30,
                              height: 30,
                            ),
                            if (widget.provider != helpers.DepositProvider.Eulen)
                              Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: Text(
                                  widget.title,
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
                // Summary section (with check icons) in the middle.
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow("No KYC needed"),
                      _buildSummaryRow("Only accepts BRL"),
                      _buildSummaryRow("Max 6000 per day"),
                    ],
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
                                "Accepted Currencies: $acceptedCurrenciesText".i18n,
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
                                  Icons.check, // using consistent check icon
                                  size: 16.sp,
                                  color: Colors.greenAccent,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    advantage,
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
                                  Icons.close, // using a consistent "close" icon
                                  size: 16.sp,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    disadvantage,
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
        return 'lib/assets/noxpay-logo.svg';
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
