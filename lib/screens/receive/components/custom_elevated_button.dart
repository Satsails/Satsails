import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final TextEditingController controller;
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  final double borderRadius;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.controller,
    this.fontSize = 16.0,
    this.backgroundColor = const Color(0xFFFFA726),
    this.textColor = Colors.black,
    this.elevation = 0.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
        elevation: WidgetStateProperty.all<double>(elevation),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            vertical: height * 0.015,
            horizontal: width * 0.15,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
    );
  }
}
