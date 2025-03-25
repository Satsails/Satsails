import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/address_receive_provider.dart';

class AmountInput extends ConsumerWidget {
  final TextEditingController controller;

  const AmountInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinInput = ref.watch(isBitcoinInputProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;

    return Column(
      children: [
        TextFormField(
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
            fontSize: dynamicFontSize * 3,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '0',
            hintStyle: TextStyle(color: Colors.white),
          ),
          // Removed the onChanged callback
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Text(
              "Select Currency",
              style: TextStyle(fontSize: dynamicFontSize / 2.7, color: Colors.white),
            ),
            dropdownColor: const Color(0xFF2B2B2B),
            value: ref.watch(inputCurrencyProvider),
            items: const [
              DropdownMenuItem(
                value: 'BTC',
                child: Center(
                  child: Text('BTC', style: TextStyle(color: Color(0xFFD98100))),
                ),
              ),
              DropdownMenuItem(
                value: 'USD',
                child: Center(
                  child: Text('USD', style: TextStyle(color: Color(0xFFD98100))),
                ),
              ),
              DropdownMenuItem(
                value: 'EUR',
                child: Center(
                  child: Text('EUR', style: TextStyle(color: Color(0xFFD98100))),
                ),
              ),
              DropdownMenuItem(
                value: 'BRL',
                child: Center(
                  child: Text('BRL', style: TextStyle(color: Color(0xFFD98100))),
                ),
              ),
              DropdownMenuItem(
                value: 'Sats',
                child: Center(
                  child: Text('Sats', style: TextStyle(color: Color(0xFFD98100))),
                ),
              ),
            ],
            onChanged: (value) {
              ref.read(inputCurrencyProvider.notifier).state = value!;
              if (value == 'Sats' || value == 'BTC') {
                ref.read(isBitcoinInputProvider.notifier).state = true;
              } else {
                ref.read(isBitcoinInputProvider.notifier).state = false;
              }
            },
          ),
        ),
      ],
    );
  }
}
