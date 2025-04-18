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
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.w,           // Scaled horizontal spacing
      mainAxisSpacing: 10.h,            // Scaled vertical spacing
      childAspectRatio: 1.0,            // Square buttons
      padding: EdgeInsets.symmetric(horizontal: 20.w), // Scaled padding
      children: [
        for (int i = 1; i <= 9; i++)
          ElevatedButton(
            onPressed: () => onDigitPressed(i.toString()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r), // Scaled radius
              ),
              minimumSize: const Size(0, 0), // Allow grid to control size
            ),
            child: Text(
              i.toString(),
              style: TextStyle(fontSize: 24.sp), // Scaled font size
            ),
          ),
        const SizedBox(), // Empty space for bottom-left corner
        ElevatedButton(
          onPressed: () => onDigitPressed('0'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            minimumSize: const Size(0, 0),
          ),
          child: Text(
            '0',
            style: TextStyle(fontSize: 24.sp),
          ),
        ),
        ElevatedButton(
          onPressed: onBackspacePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            minimumSize: const Size(0, 0),
          ),
          child: Icon(
            Icons.backspace,
            size: 24.sp, // Scaled icon size
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}