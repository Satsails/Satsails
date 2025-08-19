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
    // FIX: Reverted to a square shape with a visible border by using a Container.
    // The InkWell's splash effect is now constrained by a RoundedRectangleBorder.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
      ),
      // The Material and InkWell are placed inside the container.
      child: Material(
        color: Colors.transparent,
        // The shape of the Material widget is set to match the container's border radius.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: InkWell(
          onTap: onPressed,
          // This ensures the ripple effect is also contained within the rounded corners.
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
        ),
      ),
    );
  }
}

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
    // FIX: Redesigned with AnimatedSwitcher for a "cooler" pop-and-fade effect
    // and an outlined style for empty digits.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDigits, (index) {
        final isFilled = index < currentLength;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<bool>(isFilled), // Key to trigger the animation
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? Colors.white : Colors.transparent,
              border: isFilled
                  ? null
                  : Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}