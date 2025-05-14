import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;

  const CustomKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width in pixels
    final screenWidth = MediaQuery.of(context).size.width;
    // Set keypad width to 80% of screen width, capped at 300 pixels
    final keypadWidth = (screenWidth * 0.8).clamp(0.0, 300.0);

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      minimumSize: const Size(0, 0),
    );

    return Center(
      child: SizedBox(
        width: keypadWidth,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.0,
          children: [
            for (int i = 1; i <= 9; i++)
              ElevatedButton(
                onPressed: () => onDigitPressed(i.toString()),
                style: buttonStyle,
                child: Text(
                  i.toString(),
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
            const SizedBox.shrink(),
            ElevatedButton(
              onPressed: () => onDigitPressed('0'),
              style: buttonStyle,
              child: Text(
                '0',
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
            ElevatedButton(
              onPressed: onBackspacePressed,
              style: buttonStyle,
              child: Icon(
                Icons.backspace,
                size: 24.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}