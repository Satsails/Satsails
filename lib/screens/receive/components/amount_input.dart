import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/address_receive_provider.dart';

class AmountInput extends ConsumerWidget {
  const AmountInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinInput = ref.watch(isBitcoinInputProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final TextEditingController controller = TextEditingController();
    final inputAmount = ref.watch(inputAmountProvider);
    controller.text = inputAmount == '0.0' ? '' : inputAmount;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton(
            dropdownColor: Colors.white,
            value: ref.watch(inputCurrencyProvider),
            items: const [
              DropdownMenuItem(
                value: 'BTC',
                child: Text('BTC'),
              ),
              DropdownMenuItem(
                value: 'USD',
                child: Text('USD'),
              ),
              DropdownMenuItem(
                value: 'EUR',
                child: Text('EUR'),
              ),
              DropdownMenuItem(
                value: 'BRL',
                child: Text('BRL'),
              ),
              DropdownMenuItem(value: 'Sats', child: Text('Sats')),
              DropdownMenuItem(value: 'mBTC', child: Text('mBTC')),
              DropdownMenuItem(value: 'bits', child: Text('bits')),
            ],
            onChanged: (value) {
              ref.read(inputAmountProvider.notifier).state = '0.0';
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
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: bitcoinInput ? [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()] : [DecimalTextInputFormatter(decimalRange: 2), CommaTextInputFormatter()],
            style: TextStyle(fontSize: dynamicFontSize * 3),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '0',
            ),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.deepOrangeAccent),
            elevation: WidgetStateProperty.all<double>(4),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          onPressed: () {
            String inputValue = controller.text;
            ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;
          },
          child: Text('Create Address'.i18n(ref), style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }
}