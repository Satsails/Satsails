extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}


String formatLimit(double value) {
  if (value == value.floor()) {
    return value.toInt().toString();
  } else {
    return value.toStringAsFixed(2);
  }
}