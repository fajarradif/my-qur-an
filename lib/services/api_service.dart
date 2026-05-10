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

  // 6. Berita berdasarkan Kategori (Data Lokal - Reliable, tidak tergantung API luar)
  static Future<List<Map<String, dynamic>>> getNews({String category = 'terkini'}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi loading

    final String now = DateTime.now().toIso8601String();
    final String yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String();
    final String twoDaysAgo = DateTime.now().subtract(const Duration(days: 2)).toIso8601String();

    final Map<String, List<Map<String, dynamic>>> allNews = {
      'terkini': [
        {'title': 'Ribuan Jamaah Padati Masjid Istiqlal di Malam Nisfu Syaban', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/masjid1/500/300'},
        {'title': 'Pemerintah Tetapkan 1 Syawal Berdasarkan Hisab dan Rukyat', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/syawal2/500/300'},
        {'title': 'KPK Tangkap Tersangka Kasus Korupsi Dana Desa di Jawa Timur', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/kpk3/500/300'},
        {'title': 'BMKG Keluarkan Peringatan Dini Cuaca Ekstrem di 12 Provinsi', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/bmkg4/500/300'},
        {'title': 'Harga BBM Subsidi Tetap Stabil, Pemerintah Jaga Inflasi', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/bbm5/500/300'},
        {'title': 'Indonesia Raih Medali Emas di Kejuaraan Bulu Tangkis Asia', 'pubDate': twoDaysAgo, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/bulutangkis6/500/300'},
      ],
      'islami': [
        {'title': 'Keutamaan Membaca Al-Quran di Sepertiga Malam Terakhir', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/quran1/500/300'},
        {'title': 'Tata Cara dan Doa Sholat Dhuha yang Benar Sesuai Sunnah', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/sholat2/500/300'},
        {'title': 'Pentingnya Menjaga Ukhuwah Islamiyah di Era Digital', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/ukhuwah3/500/300'},
        {'title': 'Adab-adab Berdoa Agar Cepat Dikabulkan Allah SWT', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/doa4/500/300'},
        {'title': 'Kisah Sahabat Nabi yang Dermawan: Teladan Utsman bin Affan', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/sahabat5/500/300'},
        {'title': 'Amalan Sunnah di Hari Jumat yang Perlu Diketahui Muslim', 'pubDate': twoDaysAgo, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/jumat6/500/300'},
        {'title': 'Sejarah Singkat Pembangunan Masjid Nabawi yang Megah', 'pubDate': twoDaysAgo, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/nabawi7/500/300'},
      ],
      'nasional': [
        {'title': 'DPR Sahkan RUU Omnibus Law, Masyarakat Sipil Berikan Respons', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/dpr1/500/300'},
        {'title': 'Presiden Teken Perpres Pembangunan 100 Ribu Rumah Rakyat', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/presiden2/500/300'},
        {'title': 'Inflasi Mei 2026 Terkendali di Bawah Target 3 Persen', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/inflasi3/500/300'},
        {'title': 'Polri Bongkar Jaringan Narkoba Lintas Provinsi', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/polri4/500/300'},
        {'title': 'Proyek Kereta Cepat Jakarta-Surabaya Masuk Tahap Studi Kelayakan', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/kereta5/500/300'},
        {'title': 'Menkes Umumkan Program Vaksinasi Gratis untuk Seluruh Pelajar', 'pubDate': twoDaysAgo, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/vaksin6/500/300'},
      ],
      'internasional': [
        {'title': 'Gencatan Senjata Gaza Ditandatangani, Korban Terus Bertambah', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/gaza1/500/300'},
        {'title': 'PBB Serukan Dialog Damai di Tengah Ketegangan Timur Tengah', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/pbb2/500/300'},
        {'title': 'Arab Saudi Umumkan Rekrutmen Jemaah Haji untuk Musim 1446 H', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/haji3/500/300'},
        {'title': 'Turki dan Iran Perkuat Hubungan Bilateral di Bidang Energi', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/turki4/500/300'},
        {'title': 'AS Kenakan Tarif Baru Produk Impor dari Asia Tenggara', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/tarif5/500/300'},
        {'title': 'Banjir Besar Terjang Pakistan Selatan, Ribuan Warga Mengungsi', 'pubDate': twoDaysAgo, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/banjir6/500/300'},
      ],
      'daerah': [
        {'title': 'Pemkot Surabaya Luncurkan Program Masjid Ramah Difabel', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/surabaya1/500/300'},
        {'title': 'Wisata Religi Makam Wali Songo Kembali Ramai Peziarah', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/walisongo2/500/300'},
        {'title': 'Pesantren di Jawa Timur Inovasi Program Tahfidz Digital', 'pubDate': now, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/pesantren3/500/300'},
        {'title': 'Festival Budaya Islam Nusantara Digelar di Yogyakarta', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/festival4/500/300'},
        {'title': 'Pemda Kalimantan Selatan Bangun 50 Masjid di Pelosok Desa', 'pubDate': yesterday, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/kalsel5/500/300'},
        {'title': 'UMKM Berbasis Halal di Bandung Tembus Pasar Ekspor Timur Tengah', 'pubDate': twoDaysAgo, 'link': 'https://republika.co.id', 'thumbnail': 'https://picsum.photos/seed/halal6/500/300'},
      ],
    };

    return allNews[category.toLowerCase()] ?? allNews['terkini']!;
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
