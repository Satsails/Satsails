import 'package:flutter/material.dart';

// Widget for the custom numeric keypad
class CustomKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspacePressed;

  const CustomKeypad({
    Key? key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0, // Square buttons
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        for (int i = 1; i <= 9; i++)
          ElevatedButton(
            onPressed: () => onDigitPressed(i.toString()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(i.toString(), style: const TextStyle(fontSize: 24)),
          ),
        const SizedBox(), // Empty space
        ElevatedButton(
          onPressed: () => onDigitPressed('0'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('0', style: TextStyle(fontSize: 24)),
        ),
        ElevatedButton(
            onPressed: onBackspacePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.backspace, size: 24, color: Colors.white)
        ),
      ],
    );
  }
}

