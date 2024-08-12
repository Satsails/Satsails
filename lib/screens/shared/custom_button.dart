import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color secondaryColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.primaryColor = Colors.redAccent,
    this.secondaryColor = Colors.orangeAccent,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: MaterialStateProperty.all<double>(0.0),
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(screenWidth * 0.02)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenHeight * 0.05),
          ),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(screenHeight * 0.01),
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints(maxWidth: screenWidth * 0.65, minHeight: screenHeight * 0.075),
          child: Text(
            text,
            style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
