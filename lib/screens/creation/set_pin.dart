import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Assuming these are your project's imports for i18n and custom button
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/screens/shared/custom_button.dart';

final pinProvider = StateProvider<String>((ref) => '');

// Widget for PIN progress circles
class PinProgressIndicator extends StatelessWidget {
  final int currentLength;
  final int totalDigits;

  const PinProgressIndicator({
    Key? key,
    required this.currentLength,
    required this.totalDigits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDigits, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentLength ? Colors.white : Colors.grey[600],
          ),
        );
      }),
    );
  }
}

// Main SetPin screen
class SetPin extends ConsumerStatefulWidget {
  const SetPin({super.key});

  @override
  _SetPinState createState() => _SetPinState();
}

class _SetPinState extends ConsumerState<SetPin> {
  String pin = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Set PIN'.i18n, // Changed from 'Digite o PIN'
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose a 6-digit PIN'.i18n, // Changed from 'Digite o PIN de 6 dígitos'
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 20),
              PinProgressIndicator(currentLength: pin.length, totalDigits: 6),
              const SizedBox(height: 40),
              CustomKeypad(
                onDigitPressed: (digit) {
                  if (pin.length < 6) {
                    setState(() => pin += digit);
                  }
                },
                onBackspacePressed: () {
                  if (pin.isNotEmpty) {
                    setState(() => pin = pin.substring(0, pin.length - 1));
                  }
                },
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Next'.i18n, // Already in English, no change needed
                onPressed: () {
                  ref.read(pinProvider.notifier).state = pin;
                  context.push('/confirm_pin');
                },
                primaryColor: Colors.green,
                secondaryColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}