import 'package:Satsails/providers/deposit_type_provider.dart' as helpers;
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

// Providers for state management
final selectedModeProvider = StateProvider<String>((ref) => 'Purchase from Providers');
final selectedCurrencyProvider = StateProvider<String?>((ref) => 'BRL');
final selectedPaymentMethodProvider = StateProvider<String?>((ref) => 'PIX');

class DepositType extends ConsumerStatefulWidget {
  const DepositType({super.key});

  @override
  _DepositTypeState createState() => _DepositTypeState();
}

class _DepositTypeState extends ConsumerState<DepositType> {
  // Local state for dropdowns
  String selectedCurrency = 'BRL';
  String selectedPaymentMethod = 'PIX';
  String selectedAsset = 'Depix';

  // Dropdown options
  final List<String> modes = ['P2P (No KYC)', 'Purchase from Providers'];
  final List<String> currencies = ['EUR', 'BRL', 'USD', 'CHF', 'GBP'];
  final List<String> paymentMethods = ['PIX', 'Bank Transfer', 'Apple Pay', 'Google Pay', 'Credit Card'];
  final List<String> assets = ['Depix', 'Bitcoin', 'Lightning Bitcoin', 'USDT', 'Liquid Bitcoin'];

  // Currency flags (using icons_plus for demo)
  final Map<String, Widget> currencyFlags = {
    'EUR': Flag(Flags.european_union),
    'BRL': Flag(Flags.brazil),
    'USD': Flag(Flags.united_states_of_america),
    'CHF': Flag(Flags.switzerland),
    'GBP': Flag(Flags.united_kingdom),
  };

  // Payment method icons
  final Map<String, IconData> paymentMethodIcons = {
    'PIX': Icons.pix,
    'Bank Transfer': Icons.account_balance,
    'Apple Pay': Icons.apple,
    'Google Pay': Icons.android,
    'Credit Card': Icons.credit_card,
  };

  // Asset images (simplified; replace with actual asset paths)
  Widget getAssetImage(String asset) {
    const Map<String, String> assetImages = {
      'Depix': 'lib/assets/depix.png',
      'Bitcoin': 'lib/assets/bitcoin-logo.png',
      'Lightning Bitcoin': 'lib/assets/Bitcoin_lightning_logo.png',
      'USDT': 'lib/assets/tether.png',
      'Liquid Bitcoin': 'lib/assets/l-btc.png',
    };
    return Image.asset(
      assetImages[asset] ?? 'lib/assets/default.png',
      width: 28.sp,
      height: 28.sp,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.white, size: 28.sp),
    );
  }

  helpers.DepositType getDepositTypeFromAsset(String asset) {
    switch (asset) {
      case 'Depix':
        return helpers.DepositType.depix;
      case 'Bitcoin':
        return helpers.DepositType.bitcoin;
      case 'Lightning Bitcoin':
        return helpers.DepositType.lightningBitcoin;
      case 'USDT':
        return helpers.DepositType.usdt;
      case 'Liquid Bitcoin':
        return helpers.DepositType.liquidBitcoin;
      default:
        throw Exception('Unknown asset');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMode = ref.watch(selectedModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Deposit Type".i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
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
                        setState(() {});
                      }
                    },
                    items: modes.map((mode) => DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                    )).toList(),
                    isExpanded: true,
                    dropdownColor: Colors.grey.shade900,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Card with conditional content
              Card(
                color: Colors.grey.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(30.w),
                  child: selectedMode == 'P2P (No KYC)'
                      ? Center(
                    child: Text(
                      'Coming soon'.i18n,
                      style: TextStyle(color: Colors.white, fontSize: 20.sp),
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Currency Dropdown (Pay in)
                      _buildDropdown(
                        label: 'Pay in'.i18n,
                        value: selectedCurrency,
                        items: currencies,
                        getImage: (currency) => currencyFlags[currency] ?? Icon(Icons.flag, color: Colors.white, size: 28.sp),
                        onChanged: (value) => setState(() => selectedCurrency = value!),
                      ),
                      SizedBox(height: 14.h),
                      // Payment Method Dropdown (Method of payment)
                      _buildDropdown(
                        label: 'Method of payment'.i18n,
                        value: selectedPaymentMethod,
                        items: paymentMethods,
                        getImage: (method) => Icon(paymentMethodIcons[method] ?? Icons.help_outline, color: Colors.white, size: 28.sp),
                        onChanged: (value) => setState(() => selectedPaymentMethod = value!),
                      ),
                      SizedBox(height: 14.h),
                      // Asset Dropdown (Asset to receive)
                      _buildDropdown(
                        label: 'Asset to receive'.i18n,
                        value: selectedAsset,
                        items: assets,
                        getImage: getAssetImage,
                        onChanged: (value) => setState(() => selectedAsset = value!),
                      ),
                      SizedBox(height: 32.h),
                      // Buy Button
                      ElevatedButton(
                        onPressed: () {
                          ref.read(selectedCurrencyProvider.notifier).state = selectedCurrency;
                          ref.read(selectedPaymentMethodProvider.notifier).state = selectedPaymentMethod;
                          final depositType = getDepositTypeFromAsset(selectedAsset);
                          context.push('/home/explore/deposit_type/deposit_method');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text('Buy'.i18n, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Widget Function(String) getImage,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  getImage(item),
                  SizedBox(width: 8.w),
                  Text(item, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ],
              ),
            )).toList(),
            isExpanded: true,
            dropdownColor: Colors.grey.shade900,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ],
    );
  }
}