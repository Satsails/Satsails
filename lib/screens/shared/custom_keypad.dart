import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomKeypad extends StatelessWidget {
  final ValueSetter<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback? onBiometricPressed; // Now optional

  const CustomKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.onBiometricPressed, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20.h,
      crossAxisSpacing: 20.w,
      children: [
        ...List.generate(9, (index) {
          final digit = (index + 1).toString();
          return KeypadButton(
            text: digit,
            onPressed: () => onDigitPressed(digit),
          );
        }),
        // Conditionally render the biometric button or an empty space
        if (onBiometricPressed != null)
          KeypadButton(
            icon: Icons.fingerprint,
            onPressed: onBiometricPressed!,
            iconColor: Colors.orange,
          )
        else
          Container(), // Empty container to maintain grid alignment
        KeypadButton(
          text: '0',
          onPressed: () => onDigitPressed('0'),
        ),
        KeypadButton(
          icon: Icons.backspace_outlined,
          onPressed: onBackspacePressed,
        ),
      ],
    );
  }
}


class KeypadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  const KeypadButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.iconColor,
  }) : assert(text != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24.r),
      child: Center(
        child: text != null
            ? Text(
          text!,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.w400,
          ),
        )
            : Icon(
          icon,
          color: iconColor ?? Colors.white70,
          size: 32.w,
        ),
      ),
    );
  }}


class PinProgressIndicator extends StatelessWidget {
  final int currentLength;
  final int totalDigits;

  const PinProgressIndicator({
    super.key,
    required this.currentLength,
    this.totalDigits = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDigits, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentLength
                ? Colors.white
                : Colors.white.withOpacity(0.2),
          ),
        );
      }),
    );
  }
}

