import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primaryColor  = const Color(0xFFFF5722),
    this.secondaryColor = const Color(0xFFFF9800),
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.symmetric(horizontal: 0.05.sw, vertical: 0.02.sh),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: 18.sp, color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
