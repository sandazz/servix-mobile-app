import 'package:flutter/material.dart';

/// App color palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryDark = Color(0xFF021841);
  static const Color primaryBlue = Color(0xFF002974);
  static const Color darkBlue = Color(0xFF0a1f3b);

  // Accent Colors
  static const Color accent = Color(0xFFFFC301); // Gold
  static const Color primaryButton = Color(0xFFb8921a);

  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFff4d4f);
  static const Color warning = Color(0xFFFFCC00);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Light Theme Colors
  static const Color lightText = Color(0xFF11181C);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightTint = Color(0xFF0a7ea4);
  static const Color lightIcon = Color(0xFF687076);
  static const Color lightTabIconDefault = Color(0xFF687076);
  static const Color lightTabIconSelected = Color(0xFF0a7ea4);

  // Dark Theme Colors
  static const Color darkText = Color(0xFFECEDEE);
  static const Color darkBackground = Color(0xFF151718);
  static const Color darkTint = Color(0xFFFFFFFF);
  static const Color darkIcon = Color(0xFF9BA1A6);
  static const Color darkTabIconDefault = Color(0xFF9BA1A6);
  static const Color darkTabIconSelected = Color(0xFFFFFFFF);

  // Gradient Colors
  static const List<Color> primaryGradient = [primaryDark, primaryBlue];

  // Input Field Colors
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusBorder = primaryBlue;
  static const Color inputErrorBorder = error;
  static const Color inputBackground = white;

  // Divider Color
  static const Color divider = Color(0xFFE0E0E0);
}
