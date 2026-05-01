import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _keySurah = 'last_surah';
  static const String _keySurahName = 'last_surah_name';
  static const String _keyAyat = 'last_ayat';

  /// Simpan posisi terakhir yang dibaca
  static Future<void> saveLastRead({
    required int surah,
    required String surahName,
    required int ayat,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySurah, surah);
    await prefs.setString(_keySurahName, surahName);
    await prefs.setInt(_keyAyat, ayat);
  }

  /// Ambil posisi terakhir yang disimpan
  static Future<Map<String, dynamic>> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_keySurah) ?? 0;
    final surahName = prefs.getString(_keySurahName) ?? 'Belum Ada';
    final ayat = prefs.getInt(_keyAyat) ?? 0;
    return {
      'surah': surah,
      'surahName': surahName,
      'ayat': ayat,
    };
  }

  /// Hapus posisi terakhir (jika di-unmark)
  static Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySurah);
    await prefs.remove(_keySurahName);
    await prefs.remove(_keyAyat);
  }
}


