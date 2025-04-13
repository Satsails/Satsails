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
          style: TextStyle(
              color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              // Mode Selector Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
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
                    items: ['P2P (No KYC)', 'Purchase from Providers']
                        .map((mode) => DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode,
                          style: TextStyle(
                              color: Colors.white, fontSize: 16.sp)),
                    ))
                        .toList(),
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade900,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Main Card with dropdowns and Buy button
              Card(
                color: Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: selectedMode == 'P2P (No KYC)'
                      ? Center(
                      child: Text('Coming soon'.i18n,
                          style: TextStyle(
                              color: Colors.white, fontSize: 20.sp)))
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Currency Dropdown
                      _buildDropdown(
                        label: 'Pay in'.i18n,
                        value: selectedCurrency,
                        items: CurrencyDeposit.values,
                        getImage: (currency) =>
                        currencyFlags[currency] ??
                            Icon(Icons.flag,
                                color: Colors.white, size: 28.sp),
                        getText: (currency) => currency.name,
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(selectedCurrencyProvider.notifier).state = value;
                          }
                        },
                      ),
                      SizedBox(height: 14.h),
                      // Payment Method Dropdown
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
                      // Deposit Type Dropdown
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
                      // Buy Button
                      ElevatedButton(
                        onPressed: isConditionMet
                            ? () {
                          context.pushNamed('DepositPixEulen');
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isConditionMet ? Colors.green : Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          isConditionMet ? 'Buy'.i18n : 'Coming soon'.i18n,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Provider Details Card (expandable)
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
            color: Colors.grey.shade900,
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
              dropdownColor: Colors.grey.shade900,
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
    final selectedProvider = ref.watch(selectedDepositProvider);
    final details = providerDetails[selectedProvider]!;

    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r), // Revert to original radius
      ),
      elevation: 6,
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r), // Ensure clipping for rounded corners
        child: ExpansionTile(
          title: Text(
            'Provider: ${formatEnumName(selectedProvider.name)}'.i18n,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          backgroundColor: Colors.grey.shade900,
          collapsedBackgroundColor: Colors.grey.shade900,
          children: [
            Padding(
              padding: EdgeInsets.all(20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.greenAccent,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Advantages'.i18n,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...details.advantages.map(
                        (advantage) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h, left: 12.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            color: Colors.greenAccent,
                            size: 12.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              advantage,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14.sp,
                                height: 1.4,
                              ),
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
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orangeAccent,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Disadvantages'.i18n,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...details.disadvantages.map(
                        (disadvantage) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h, left: 12.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            color: Colors.orangeAccent,
                            size: 12.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              disadvantage,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14.sp,
                                height: 1.4,
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
    );
  }
}