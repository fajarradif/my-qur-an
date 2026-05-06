import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../models/surah.dart';
import '../models/surah_detail.dart';
import '../models/jadwal.dart';
import '../models/tahlil.dart';
import '../models/doa.dart';

class ApiService {
  static const String baseUrl = 'https://equran.id/api/v2';
  static const String muslimBaseUrl = 'https://api.myquran.com/v3';

  // 1. Mengambil API Daftar 114 Surat
  static Future<List<Surah>> getSuratList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surat'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['code'] == 200) {
          final List<dynamic> surasList = data['data'];
          return surasList.map((json) => Surah.fromJson(json)).toList();
        }
      }
      throw Exception('Gagal memuat daftar surat dari server');
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan atau koneksi API');
    }
  }

  // 2. Mengambil API Detail Surat (Termasuk Daftar Ayat di dalamnya)
  static Future<SurahDetail> getDetailSurat(int nomorSurat) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surat/$nomorSurat'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['code'] == 200) {
          return SurahDetail.fromJson(data['data']);
        }
      }
      throw Exception('Gagal memuat detail ayat surat');
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan atau koneksi API');
    }
  }
  
  // 3. Mengambil API Jadwal Sholat Hari Ini (API Muslim Indonesia)
  static Future<Jadwal> getJadwalSholat(String cityId) async {
    try {
      final response = await http.get(Uri.parse('$muslimBaseUrl/sholat/jadwal/$cityId/today'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          // Akses object tanggal pertama di dalam map "jadwal"
          final schedules = data['data']['jadwal'] as Map<String, dynamic>;
          final todaySchedule = schedules.values.first;
          return Jadwal.fromJson(todaySchedule);
        }
      }
      throw Exception('Gagal memuat jadwal sholat');
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi API Muslim');
    }
  }

  // Cari nama kota dari koordinat GPS menggunakan BigDataCloud API
  static Future<String?> getCityNameFromCoords(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String city = data['city'] ?? data['locality'] ?? '';
        
        // Bersihkan nama kota (misal: "Kota Jakarta Selatan" -> "Jakarta Selatan")
        city = city.replaceAll(RegExp(r'(Kota|Kabupaten)\s+', caseSensitive: false), '').trim();
        return city.isNotEmpty ? city : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Cari ID Kota di API MyQuran berdasarkan nama kota
  static Future<String?> searchCityId(String cityName) async {
    try {
      final response = await http.get(Uri.parse('$muslimBaseUrl/sholat/kota/cari/$cityName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null && data['data'].isNotEmpty) {
          return data['data'][0]['id'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Cari daftar kota untuk fitur manual
  static Future<List<Map<String, dynamic>>> searchCities(String keyword) async {
    try {
      final response = await http.get(Uri.parse('$muslimBaseUrl/sholat/kota/cari/$keyword'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 4. Mengambil Data Tahlil Lengkap (Local Assets)
  static Future<List<Tahlil>> getTahlilList() async {
    try {
      final String response = await rootBundle.loadString('assets/data/tahlil.json');
      final data = await json.decode(response);
      final List<dynamic> tahlilList = data['data'];
      return tahlilList.map((json) => Tahlil.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat data Tahlil Lokal: $e');
    }
  }

  // 5. Mengambil Daftar Doa Harian (API MyQuran)
  static Future<List<Doa>> getDoaList() async {
    try {
      final response = await http.get(Uri.parse('https://api.myquran.com/v2/doa/semua'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> doaList = data['data'];
          return doaList.map((json) => Doa.fromJson(json)).toList();
        }
      }
      throw Exception('Gagal memuat daftar doa');
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi API Doa');
    }
  }

  // Helper untuk mendapatkan jadwal sholat selanjutnya
  static Map<String, dynamic> getNextPrayer(Jadwal jadwal) {
    final now = DateTime.now();
    final Map<String, String> times = {
      'Subuh': jadwal.subuh,
      'Dzuhur': jadwal.dzuhur,
      'Ashar': jadwal.ashar,
      'Maghrib': jadwal.maghrib,
      'Isya': jadwal.isya,
    };

    for (var entry in times.entries) {
      final prayerTime = _parseTime(entry.value);
      if (prayerTime.isAfter(now)) {
        return {'name': entry.key, 'time': entry.value};
      }
    }

    // Jika sudah lewat semua, berarti sholat pertama besok (Subuh)
    return {'name': 'Subuh', 'time': jadwal.subuh};
  }

  // Helper untuk menghitung mundur
  static String getCountdown(String targetTime) {
    final now = DateTime.now();
    final target = _parseTime(targetTime);
    
    var diff = target.difference(now);
    
    // Jika waktu sudah lewat (untuk kasus Subuh besok)
    if (diff.isNegative) {
      diff = diff + const Duration(hours: 24);
    }

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(diff.inHours);
    String minutes = twoDigits(diff.inMinutes.remainder(60));
    String seconds = twoDigits(diff.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  static DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(':');
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}
