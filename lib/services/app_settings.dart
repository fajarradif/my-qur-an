import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _prayerNotifKey = 'prayer_notif_enabled';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhotoKey = 'user_photo';

  String _language = 'id';
  bool _prayerNotifEnabled = true;
  String _userName = 'MyQuran User';
  String _userEmail = 'user@myquran.com';
  String? _userPhotoPath;

  String get language => _language;
  bool get prayerNotifEnabled => _prayerNotifEnabled;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get userPhotoPath => _userPhotoPath;

  String t(String id, String en) => _language == 'en' ? en : id;

  AppSettings() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_languageKey) ?? 'id';
    _prayerNotifEnabled = prefs.getBool(_prayerNotifKey) ?? true;
    _userName = prefs.getString(_userNameKey) ?? 'MyQuran User';
    _userEmail = prefs.getString(_userEmailKey) ?? 'user@myquran.com';
    _userPhotoPath = prefs.getString(_userPhotoKey);
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

  Future<void> updateProfile({required String name, required String email, String? photoPath}) async {
    _userName = name;
    _userEmail = email;
    if (photoPath != null) _userPhotoPath = photoPath;
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userNameKey, name);
    prefs.setString(_userEmailKey, email);
    if (photoPath != null) prefs.setString(_userPhotoKey, photoPath);
  }
}
