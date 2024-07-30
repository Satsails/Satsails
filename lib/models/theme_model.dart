import 'package:flutter/material.dart';

class AppTheme {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final bool isDarkMode;

  AppTheme({
    required this.lightTheme,
    required this.darkTheme,
    this.isDarkMode = false,
  });

  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  AppTheme copyWith({bool? isDarkMode}) {
    return AppTheme(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
