import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'is_dark_mode';
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  void toggleTheme() {
    // Langsung ganti dulu biar instan, baru simpan di belakang layar
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    // Simpan ke memori secara async (nggak blocking UI)
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_key, _isDarkMode);
    });
  }
}
