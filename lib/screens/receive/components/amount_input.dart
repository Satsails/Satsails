import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:i18n_extension/default.i18n.dart';

class AmountInput extends ConsumerWidget {
  final TextEditingController controller;
  final String label;

  const AmountInput({
    super.key,
    required this.controller,
    this.label = '(Optional)',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinInput = ref.watch(isBitcoinInputProvider);
    final currencies = ['BTC', 'USD', 'EUR', 'BRL', 'Sats'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the input
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            'Amount'.i18n,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        // Stack for layering dropdown above input
        Stack(
          alignment: Alignment.topRight,
          children: [
            // Input field with updated styling
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2B2B),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: bitcoinInput
                    ? [
                  CommaTextInputFormatter(),
                  DecimalTextInputFormatter(decimalRange: 8),
                ]
                    : [
                  CommaTextInputFormatter(),
                  DecimalTextInputFormatter(decimalRange: 2),
                ],
                style: TextStyle(
                  fontSize: 16.sp, // Slightly bigger font size
                  color: Colors.white,
                  fontWeight: FontWeight.bold, // Bold text
                ),
                textAlign: TextAlign.left, // Left-aligned text
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: label.i18n,
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  isDense: true,
                ),
              ),
            ),
            // Dropdown positioned in top-right corner
            Positioned(
              top: 8,
              right: 0,
              child: SizedBox(
                width: 80.w,
                child: DropdownButton<String>(
                  value: ref.watch(inputCurrencyProvider),
                  items: currencies.map((String currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.w),
                        child: Text(
                          currency,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold

                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(inputCurrencyProvider.notifier).state = value!;
                    if (value == 'Sats' || value == 'BTC') {
                      ref.read(isBitcoinInputProvider.notifier).state = true;
                    } else {
                      ref.read(isBitcoinInputProvider.notifier).state = false;
                    }
                  },
                  dropdownColor: const Color(0xFF212121),
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
                  underline: const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}