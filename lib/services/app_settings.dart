import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _prayerNotifKey = 'prayer_notif_enabled';

  String _language = 'id'; // 'id' = Indonesia, 'en' = English
  bool _prayerNotifEnabled = true;

  String get language => _language;
  bool get prayerNotifEnabled => _prayerNotifEnabled;

  // Helper untuk ambil teks sesuai bahasa
  String t(String id, String en) => _language == 'en' ? en : id;

  AppSettings() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_languageKey) ?? 'id';
    _prayerNotifEnabled = prefs.getBool(_prayerNotifKey) ?? true;
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_languageKey, lang);
  }

  Future<void> setPrayerNotifEnabled(bool value) async {
    _prayerNotifEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_prayerNotifKey, value);
  }
}
