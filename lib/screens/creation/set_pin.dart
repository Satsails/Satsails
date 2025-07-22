import 'package:Satsails/screens/shared/custom_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final pinProvider = StateProvider<String>((ref) => '');

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            // We removed the fixed-height SizedBox and will use SizedBox for spacing instead of Spacer.
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Create a PIN'.i18n,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50.h), // Replaced Spacer
                PinProgressIndicator(currentLength: pin.length),
                SizedBox(height: 50.h), // Replaced Spacer(flex: 2)
                CustomKeypad(
                  onDigitPressed: (digit) {
                    if (pin.length < 6) {
                      HapticFeedback.lightImpact();
                      setState(() => pin += digit);
                    }
                  },
                  onBackspacePressed: () {
                    if (pin.isNotEmpty) {
                      HapticFeedback.lightImpact();
                      setState(() => pin = pin.substring(0, pin.length - 1));
                    }
                  },
                ),
                SizedBox(height: 30.h), // Replaced Spacer
                AnimatedOpacity(
                  opacity: pin.length == 6 ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: CustomButton(
                    text: 'Next'.i18n,
                    onPressed: pin.length == 6
                        ? () {
                      ref.read(pinProvider.notifier).state = pin;
                      context.push('/confirm_pin');
                    }
                        : () {},
                    primaryColor: Colors.green,
                    secondaryColor: Colors.green,
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}