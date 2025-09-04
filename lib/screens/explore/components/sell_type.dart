
import 'package:Satsails/helpers/sell_type_helper.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SellTypeScreen extends ConsumerWidget {
  const SellTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrency = ref.watch(selectedCurrencySellProvider);
    final selectedSellMethod = ref.watch(selectedSellMethodProvider);
    final selectedAsset = ref.watch(selectedCryptoTypeSellProvider);
    final availableSellMethods = ref.watch(availableSellMethodsProvider);
    final availableSellTypes = ref.watch(availableSellTypesProvider);

    if (selectedSellMethod != null && !availableSellMethods.contains(selectedSellMethod)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedSellMethodProvider.notifier).state =
        availableSellMethods.isNotEmpty ? availableSellMethods.first : null;
      });
    }

    if (!availableSellTypes.contains(selectedAsset)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedCryptoTypeSellProvider.notifier).state =
        availableSellTypes.isNotEmpty ? availableSellTypes.first : SellType.Bitcoin;
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Sell Type".i18n,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: const Color(0x00333333).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDropdown(
                        label: 'Receive in'.i18n,
                        value: selectedCurrency,
                        items: CurrencySell.values,
                        getImage: (currency) =>
                        currencySellFlags[currency] ?? Icon(Icons.flag, color: Colors.white, size: 28.sp),
                        getText: (currency) => currency.name,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(selectedCurrencySellProvider.notifier).state = value;
                          }
                        },
                      ),
                      SizedBox(height: 14.h),
                      _buildDropdown(
                        label: 'Method of payout'.i18n,
                        value: availableSellMethods.contains(selectedSellMethod) ? selectedSellMethod : null,
                        items: availableSellMethods,
                        getImage: (method) =>
                            Icon(sellMethodIcons[method] ?? Icons.help_outline, color: Colors.white, size: 28.sp),
                        getText: (method) => formatEnumName(method.name),
                        onChanged: (value) {
                          ref.read(selectedSellMethodProvider.notifier).state = value;
                        },
                      ),
                      SizedBox(height: 14.h),
                      _buildDropdown(
                        label: 'Asset to sell'.i18n,
                        value: availableSellTypes.contains(selectedAsset) ? selectedAsset : null,
                        items: availableSellTypes,
                        getImage: getSellAssetImage,
                        getText: (asset) => formatEnumName(asset.name),
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(selectedCryptoTypeSellProvider.notifier).state = value;
                          }
                        },
                      ),
                      SizedBox(height: 32.h),
                      Builder(
                        builder: (context) {
                          final selectedProvider = ref.watch(computedSellProvider);
                          final isButtonEnabled = selectedProvider == SellProvider.Nox;
                          final buttonText = isButtonEnabled ? 'Sell'.i18n : 'Coming soon'.i18n;

                          return CustomButton(
                            text: buttonText,
                            onPressed: isButtonEnabled
                                ? () {
                              final route = 'SellPixNox';
                              context.pushNamed(route);
                            }
                                : () {},
                            primaryColor: isButtonEnabled ? Colors.green.shade700 : Colors.red.withOpacity(0.8),
                            secondaryColor: isButtonEnabled ? Colors.green.shade700 : Colors.red.withOpacity(0.6),
                            textColor: Colors.black,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  final selectedProvider = ref.watch(computedSellProvider);
                  if (selectedProvider != null) {
                    return SellProviderDetailsWidget(provider: selectedProvider);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Widget Function(T) getImage,
    required String Function(T) getText,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              onChanged: onChanged,
              items: items
                  .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Row(
                  children: [
                    getImage(item),
                    SizedBox(width: 8.w),
                    Text(
                      getText(item),
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ],
                ),
              ))
                  .toList(),
              isExpanded: true,
              dropdownColor: const Color(0xFF212121),
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class SellProviderDetailsWidget extends ConsumerWidget {
  final SellProvider provider;

  const SellProviderDetailsWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerDetail = sellProviderDetails[provider]!;
    final kyc = sellKycAssessment[provider]!;

    final sectionTitleStyle = TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold);
    final listItemStyle = TextStyle(color: Colors.white70, fontSize: 14.sp, height: 1.4);

    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: ExpansionTile(
          title: Text(
            'Provider: ${formatEnumName(provider.name)}'.i18n,
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          backgroundColor: const Color(0xFF333333).withOpacity(0.4),
          collapsedBackgroundColor: const Color(0xFF333333).withOpacity(0.4),
          children: [
            Padding(
              padding: EdgeInsets.all(20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KYC Assessment'.i18n, style: sectionTitleStyle),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        Icon(_getStarIcon(i, kyc.rating), color: Colors.amber, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text('${kyc.rating}/5',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ...kyc.details.map((detail) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.white, size: 12.sp),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(detail.i18n, style: listItemStyle)),
                      ],
                    ),
                  )),
                  SizedBox(height: 20.h),
                  Divider(color: Colors.grey.shade700, thickness: 0.5, indent: 12.w, endIndent: 12.w),
                  SizedBox(height: 20.h),
                  Text('Advantages'.i18n, style: sectionTitleStyle),
                  SizedBox(height: 12.h),
                  ...providerDetail.advantages.map((advantage) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: Colors.greenAccent, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(advantage.i18n, style: listItemStyle)),
                      ],
                    ),
                  )),
                  SizedBox(height: 20.h),
                  Divider(color: Colors.grey.shade700, thickness: 0.5, indent: 12.w, endIndent: 12.w),
                  SizedBox(height: 20.h),
                  Text('Disadvantages'.i18n, style: sectionTitleStyle),
                  SizedBox(height: 12.h),
                  ...providerDetail.disadvantages.map((disadvantage) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.remove_circle, color: Colors.orangeAccent, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(disadvantage.i18n, style: listItemStyle)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStarIcon(int index, double rating) {
    if (index <= rating.floor()) {
      return Icons.star;
    } else if (index - 0.5 <= rating) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }
}