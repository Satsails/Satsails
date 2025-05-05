import 'package:Satsails/helpers/deposit_type_helper.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DepositTypeScreen extends ConsumerWidget {
  const DepositTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(selectedModeProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final selectedPaymentMethod = ref.watch(selectedPaymentMethodProvider);
    final selectedAsset = ref.watch(selectedCryptoTypeProvider);
    final availablePaymentMethods = ref.watch(availablePaymentMethodsProvider);
    final availableDepositTypes = ref.watch(availableDepositTypesProvider);

    // Reset selected payment method if invalid
    if (selectedPaymentMethod != null && !availablePaymentMethods.contains(selectedPaymentMethod)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedPaymentMethodProvider.notifier).state =
        availablePaymentMethods.isNotEmpty ? availablePaymentMethods.first : null;
      });
    }

    // Reset selected deposit type if invalid
    if (!availableDepositTypes.contains(selectedAsset)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedCryptoTypeProvider.notifier).state =
        availableDepositTypes.isNotEmpty ? availableDepositTypes.first : DepositType.Bitcoin;
      });
    }

    bool isConditionMet = selectedCurrency == CurrencyDeposit.BRL &&
        selectedPaymentMethod == DepositMethod.PIX &&
        selectedAsset == DepositType.Depix &&
        selectedMode == 'Purchase from Providers';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Deposit Type".i18n,
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
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
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x333333).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMode,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(selectedModeProvider.notifier).state = value;
                      }
                    },
                    items: ['Purchase with P2P (No KYC)', 'Purchase from Providers']
                        .map((mode) => DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode.i18n,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                    ))
                        .toList(),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF212121),
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Card(
                color: const Color(0x333333).withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: selectedMode == 'Purchase with P2P (No KYC)'
                      ? Center(
                      child: Text('Coming soon'.i18n,
                          style: TextStyle(color: Colors.white, fontSize: 20.sp)))
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDropdown(
                        label: 'Pay in'.i18n,
                        value: selectedCurrency,
                        items: CurrencyDeposit.values,
                        getImage: (currency) =>
                        currencyFlags[currency] ??
                            Icon(Icons.flag, color: Colors.white, size: 28.sp),
                        getText: (currency) => currency.name,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(selectedCurrencyProvider.notifier).state = value;
                          }
                        },
                      ),
                      SizedBox(height: 14.h),
                      _buildDropdown(
                        label: 'Method of payment'.i18n,
                        value: availablePaymentMethods.contains(selectedPaymentMethod)
                            ? selectedPaymentMethod
                            : null,
                        items: availablePaymentMethods,
                        getImage: (method) => Icon(
                            paymentMethodIcons[method] ?? Icons.help_outline,
                            color: Colors.white,
                            size: 28.sp),
                        getText: (method) => formatEnumName(method.name),
                        onChanged: (value) {
                          ref.read(selectedPaymentMethodProvider.notifier).state = value;
                        },
                      ),
                      SizedBox(height: 14.h),
                      _buildDropdown(
                        label: 'Asset to receive'.i18n,
                        value: availableDepositTypes.contains(selectedAsset)
                            ? selectedAsset
                            : null,
                        items: availableDepositTypes,
                        getImage: getAssetImage,
                        getText: (asset) => formatEnumName(asset.name),
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(selectedCryptoTypeProvider.notifier).state = value;
                          }
                        },
                      ),
                      SizedBox(height: 32.h),
                      ElevatedButton(
                        onPressed: isConditionMet
                            ? () {
                          context.pushNamed('DepositPixEulen');
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConditionMet ? Colors.green : Colors.red,
                          disabledBackgroundColor: isConditionMet ? Colors.green : Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          isConditionMet ? 'Buy'.i18n : 'Coming soon'.i18n,
                          style: TextStyle(color: Colors.black, fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isConditionMet) ...[
                const ProviderDetails(),
              ],
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
                    Text(getText(item),
                        style: TextStyle(color: Colors.white, fontSize: 16.sp)),
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

class ProviderDetails extends ConsumerWidget {
  const ProviderDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hardcode to Eulen since only this condition is currently supported
    final selectedProvider = DepositProvider.Eulen;
    final providerDetail = providerDetails[selectedProvider]!;
    final kyc = kycAssessment[selectedProvider]!;

    // Define consistent text styles
    final sectionTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    );

    final listItemStyle = TextStyle(
      color: Colors.white70,
      fontSize: 14.sp,
      height: 1.4,
    );

    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: ExpansionTile(
          title: Text(
            'Provider: ${formatEnumName(selectedProvider.name)}'.i18n,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
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
                  // KYC Assessment Section
                  Text(
                    'KYC Assessment'.i18n,
                    style: sectionTitleStyle,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        Icon(
                          _getStarIcon(i, kyc.rating),
                          color: Colors.amber,
                          size: 20.sp,
                        ),
                      SizedBox(width: 8.w),
                      Text(
                        '${kyc.rating}/5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ...kyc.details.map(
                        (detail) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.fiber_manual_record, color: Colors.white, size: 12.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              detail.i18n,
                              style: listItemStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Divider(
                    color: Colors.grey.shade700,
                    thickness: 0.5,
                    indent: 12.w,
                    endIndent: 12.w,
                  ),
                  SizedBox(height: 20.h),
                  // Advantages Section
                  Text(
                    'Advantages'.i18n,
                    style: sectionTitleStyle,
                  ),
                  SizedBox(height: 12.h),
                  ...providerDetail.advantages.map(
                        (advantage) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: Colors.greenAccent, size: 16.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              advantage.i18n,
                              style: listItemStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Divider(
                    color: Colors.grey.shade700,
                    thickness: 0.5,
                    indent: 12.w,
                    endIndent: 12.w,
                  ),
                  SizedBox(height: 20.h),
                  // Disadvantages Section
                  Text(
                    'Disadvantages'.i18n,
                    style: sectionTitleStyle,
                  ),
                  SizedBox(height: 12.h),
                  ...providerDetail.disadvantages.map(
                        (disadvantage) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.remove_circle, color: Colors.orangeAccent, size: 16.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              disadvantage.i18n,
                              style: listItemStyle,
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