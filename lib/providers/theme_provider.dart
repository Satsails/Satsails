import 'package:Satsails/models/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier()
      : super(AppTheme(
    lightTheme: ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardColor: Colors.white,
      scaffoldBackgroundColor: Colors.blue[50],
      appBarTheme: AppBarTheme(color: Colors.blue),
      // textTheme: TextTheme(headline1: TextStyle(color: Colors.black)),
    ),
    darkTheme: ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardColor: Colors.grey[800],
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(color: Colors.grey[900]),
      // textTheme: TextTheme(headline1: TextStyle(color: Colors.white)),
    ),
  ));

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
}
