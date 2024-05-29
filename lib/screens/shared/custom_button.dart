import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(0.0),
        padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(screenWidth * 0.02)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenHeight * 0.05)
          ),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.redAccent, Colors.orangeAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
            borderRadius: BorderRadius.circular(screenHeight * 0.05)
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(maxWidth: screenWidth * 0.75, minHeight: screenHeight * 0.075),
          child: Text(
            text,
            style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
          ),
        ),
      ),
    );
  }
}