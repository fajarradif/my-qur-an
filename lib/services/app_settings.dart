import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _fontSizeKey = 'quran_font_size';
  static const String _prayerNotifKey = 'prayer_notif_enabled';

  double _quranFontSize = 28.0;
  bool _prayerNotifEnabled = true;

  double get quranFontSize => _quranFontSize;
  bool get prayerNotifEnabled => _prayerNotifEnabled;

  AppSettings() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _quranFontSize = prefs.getDouble(_fontSizeKey) ?? 28.0;
    _prayerNotifEnabled = prefs.getBool(_prayerNotifKey) ?? true;
    notifyListeners();
  }

  Future<void> setQuranFontSize(double size) async {
    _quranFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_fontSizeKey, size);
  }

  Future<void> setPrayerNotifEnabled(bool value) async {
    _prayerNotifEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_prayerNotifKey, value);
  }
}
