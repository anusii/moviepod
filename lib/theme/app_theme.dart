/// Theme configuration for the Movie Star application.
///
// Time-stamp: <Thursday 2025-04-10 11:47:48 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Kevin Wang

import 'package:flutter/material.dart';

/// Theme configuration for the Movie Star application.

class AppTheme {
  /// Primary color for the application.

  static const Color primaryColor = Colors.red;

  /// Background color for the application.

  static const Color backgroundColor = Colors.black;

  /// Text color for primary text.

  static const Color primaryTextColor = Colors.white;

  /// Text color for secondary text.

  static const Color secondaryTextColor = Colors.grey;

  /// Color for selected items in navigation.

  static const Color selectedItemColor = Colors.white;

  /// Color for unselected items in navigation.

  static const Color unselectedItemColor = Colors.grey;

  /// Default padding for content.

  static const double defaultPadding = 16.0;

  /// Default border radius for rounded corners.

  static const double defaultBorderRadius = 8.0;

  /// Creates the light theme for the application.

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: primaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: primaryTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: primaryTextColor, fontSize: 14),
        labelLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: secondaryTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: primaryTextColor,
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
    );
  }

  /// Creates the dark theme for the application.

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: primaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: primaryTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: primaryTextColor, fontSize: 14),
        labelLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: secondaryTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: primaryTextColor,
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
    );
  }
}
