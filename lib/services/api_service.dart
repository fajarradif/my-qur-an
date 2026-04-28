import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/surah_detail.dart';
import '../models/jadwal.dart';

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
}
