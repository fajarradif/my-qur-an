import 'package:flutter/material.dart';

class AppColors {
  // ============ LIGHT THEME ============
  static const Color primaryGreen = Color(0xFF1D5C42);
  static const Color deepGreen = Color(0xFF0B3D2E);
  static const Color deepForestGreen = Color(0xFF072A1F);
  static const Color emeraldGreen = Color(0xFF1D5C42);
  static const Color secondaryGreen = Color(0xFF2A7A56);

  static const Color mutedGreen = Color(0xFF7A9386);
  static const Color iconBgGreen = Color(0xFFE8F0EC);
  
  static const Color primaryYellow = Color(0xFFF9B42A);
  static const Color royalGold = Color(0xFFD4AF37);
  
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  
  static const Color textDark = Color(0xFF1A211D);
  static const Color textLight = Colors.white;

  // ============ DARK THEME ============
  static const Color darkBackground = Color(0xFF0F1A14);
  static const Color darkSurface = Color(0xFF1A2B22);
  static const Color darkCard = Color(0xFF213830);
  static const Color darkTextPrimary = Color(0xFFE8F0EC);
  static const Color darkTextSecondary = Color(0xFF8BA898);
  static const Color darkMutedGreen = Color(0xFF5A7A6A);
  static const Color darkIconBg = Color(0xFF2A4035);
  static const Color darkPrimaryGreen = Color(0xFF3DA67A);
  static const Color darkGold = Color(0xFFFFCC4D);

  // ============ ADAPTIVE HELPERS ============
  // Pakai ini di widget supaya otomatis ikut tema
  
  static Color bg(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkBackground : background;

  static Color sf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static Color card(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkCard : surface;

  static Color green(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkPrimaryGreen : primaryGreen;

  static Color gold(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkGold : primaryYellow;

  static Color muted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkMutedGreen : mutedGreen;

  static Color text1(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : textDark;

  static Color text2(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : mutedGreen;

  static Color iconBg(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkIconBg : iconBgGreen;

  static bool isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;
}
