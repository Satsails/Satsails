extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}


String formatLimit(double value) {
  if (value == value.floor()) {
    return value.toInt().toString(); // If it's a whole number, display it as an integer
  } else {
    return value.toStringAsFixed(2); // Otherwise, show with two decimal places
  }
}