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
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(0.0),
        padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(10)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
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
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(maxWidth: 300.0, minHeight: 60.0),
          child: Text(
            text,
            style: const TextStyle(fontSize: 18.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
}