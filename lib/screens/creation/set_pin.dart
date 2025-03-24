import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          margin: EdgeInsets.symmetric(horizontal: 8.w), // Scaled margin
          width: 16.w, // Scaled width
          height: 16.h, // Scaled height
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
          'Set PIN'.i18n,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PinProgressIndicator(currentLength: pin.length, totalDigits: 6),
                SizedBox(height: 40.h),
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
                SizedBox(height: 40.h),
                CustomButton(
                  text: 'Next'.i18n,
                  onPressed: () {
                    ref
                        .read(pinProvider.notifier)
                        .state = pin;
                    context.push('/confirm_pin');
                  },
                  primaryColor: Colors.green,
                  secondaryColor: Colors.green,
                ),
                SizedBox(height: 20.h), // Extra space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}