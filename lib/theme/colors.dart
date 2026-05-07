import 'package:flutter/material.dart';
import '../main.dart'; // Import main.dart buat akses MyQuranApp.of

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
  // Sekarang nembak langsung ke MyQuranApp.of(context) biar instan!
  
  static Color bg(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkBackground : background;

  static Color sf(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkSurface : surface;

  static Color card(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkCard : surface;

  static Color green(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkPrimaryGreen : primaryGreen;

  static Color gold(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkGold : primaryYellow;

  static Color muted(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkMutedGreen : mutedGreen;

  static Color text1(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkTextPrimary : textDark;

  static Color text2(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkTextSecondary : mutedGreen;

  static Color iconBg(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode ? darkIconBg : iconBgGreen;

  static bool isDark(BuildContext context) =>
    MyQuranApp.of(context).isDarkMode;
}
