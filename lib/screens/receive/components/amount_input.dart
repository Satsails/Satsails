import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:satsails/providers/address_receive_provider.dart';

class AmountInput extends ConsumerWidget {
  const AmountInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinInput = ref.watch(isBitcoinInputProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;

    String inputValue = '';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton(
            value: ref.watch(inputCurrencyProvider),
            items: const [
              DropdownMenuItem(
                child: Text('BTC'),
                value: 'BTC',
              ),
              DropdownMenuItem(
                child: Text('USD'),
                value: 'USD',
              ),
              DropdownMenuItem(
                child: Text('EUR'),
                value: 'EUR',
              ),
              DropdownMenuItem(
                child: Text('BRL'),
                value: 'BRL',
              ),
              DropdownMenuItem(child: Text('Sats'), value: 'Sats'),
              DropdownMenuItem(child: Text('mBTC'), value: 'mBTC'),
              DropdownMenuItem(child: Text('bits'), value: 'bits'),
            ],
            onChanged: (value) {
              ref.read(inputCurrencyProvider.notifier).state = value.toString();
              if (value == 'Sats' || value == 'Bitcoin') {
                ref.read(isBitcoinInputProvider.notifier).state = true;
              } else {
                ref.read(isBitcoinInputProvider.notifier).state = false;
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: bitcoinInput ? [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()] : [DecimalTextInputFormatter(decimalRange: 2), CommaTextInputFormatter()],
            style: TextStyle(fontSize: dynamicFontSize * 3),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
            ),
            onChanged: (value) {
              inputValue = value;
            },
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
            elevation: MaterialStateProperty.all<double>(4),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          onPressed: () {
            ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;
          },
          child: const Text('Set Amount', style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }
}